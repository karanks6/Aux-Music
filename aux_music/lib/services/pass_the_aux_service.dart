import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../../data/models/track.dart';
import 'auth_service.dart';

// ── State ──────────────────────────────────────────────────────────────────

class PassTheAuxState {
  final bool isConnecting;
  final bool isConnected;
  final String? roomId;
  final bool isHost;
  final int guestCount;
  final List<String> guestNames; // NEW: display names of connected guests
  final List<Track> sharedQueue;
  final Track? nowPlaying;
  final bool isPlaying;
  final String? error;
  final bool isSyncModeEnabled;
  final bool isCreatingRoom;

  // Synced Audio position fields
  final int? position;
  final int? timestamp;

  const PassTheAuxState({
    this.isConnecting = false,
    this.isConnected = false,
    this.roomId,
    this.isHost = false,
    this.guestCount = 0,
    this.guestNames = const [],
    this.sharedQueue = const [],
    this.nowPlaying,
    this.isPlaying = false,
    this.error,
    this.isSyncModeEnabled = false,
    this.isCreatingRoom = false,
    this.position,
    this.timestamp,
  });

  PassTheAuxState copyWith({
    bool? isConnecting,
    bool? isConnected,
    String? roomId,
    bool? isHost,
    int? guestCount,
    List<String>? guestNames,
    List<Track>? sharedQueue,
    Track? nowPlaying,
    bool? isPlaying,
    Object? error = _sentinel,
    bool? isSyncModeEnabled,
    bool? isCreatingRoom,
    int? position,
    int? timestamp,
    bool clearNowPlaying = false,
  }) {
    return PassTheAuxState(
      isConnecting: isConnecting ?? this.isConnecting,
      isConnected: isConnected ?? this.isConnected,
      roomId: roomId ?? this.roomId,
      isHost: isHost ?? this.isHost,
      guestCount: guestCount ?? this.guestCount,
      guestNames: guestNames ?? this.guestNames,
      sharedQueue: sharedQueue ?? this.sharedQueue,
      nowPlaying: clearNowPlaying ? null : (nowPlaying ?? this.nowPlaying),
      isPlaying: isPlaying ?? this.isPlaying,
      error: identical(error, _sentinel) ? this.error : error as String?,
      isSyncModeEnabled: isSyncModeEnabled ?? this.isSyncModeEnabled,
      isCreatingRoom: isCreatingRoom ?? this.isCreatingRoom,
      position: position ?? this.position,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}

const _sentinel = Object();

// ── Notifier ───────────────────────────────────────────────────────────────

class PassTheAuxNotifier extends StateNotifier<PassTheAuxState> {
  PassTheAuxNotifier(this.ref) : super(const PassTheAuxState());
  final Ref ref;

  IO.Socket? _socket;
  Timer? _hostSyncTimer;

  static const String _serverUrl = 'https://aux-music-bff.onrender.com';

  // Stream: host receives a track added by a guest
  final _guestTrackController = StreamController<Track>.broadcast();
  Stream<Track> get onGuestAddedTrack => _guestTrackController.stream;

  // Stream: confirmation messages (for snackbar etc.)
  final _trackAddedController = StreamController<String>.broadcast();
  Stream<String> get onTrackAddedConfirmation => _trackAddedController.stream;

  String get _displayName => ref.read(authServiceProvider).displayName;

  // ── Connect ──────────────────────────────────────────────────────

  void connect() {
    if (_socket != null && _socket!.connected) return;
    state = state.copyWith(isConnecting: true, error: null);

    _socket = IO.io(
      _serverUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setTimeout(10000)
          .build(),
    );

    _socket!.onConnect((_) {
      state = state.copyWith(isConnecting: false, isConnected: true, error: null);
    });

    _socket!.onDisconnect((_) {
      _hostSyncTimer?.cancel();
      state = PassTheAuxState(); // full reset
    });

    _socket!.onConnectError((err) {
      state = state.copyWith(
        isConnecting: false,
        error: 'Could not reach server. Check your connection and try again.',
      );
    });

    // ── Event Listeners ────────────────────────────────────────

    _socket!.on('guest_added_track', (data) {
      if (data is Map) {
        try {
          final track = Track.fromJson((data['track'] as Map).cast<String, dynamic>());
          final guestName = data['guestName'] as String? ?? 'A guest';
          _guestTrackController.add(track);
          _trackAddedController.add('$guestName added "${track.title}"');
        } catch (e) {
          // ignore malformed payloads
        }
      }
    });

    _socket!.on('state_synced', (data) {
      if (data is Map) {
        final nowPlaying = data['nowPlaying'] != null
            ? Track.fromJson((data['nowPlaying'] as Map).cast<String, dynamic>())
            : null;
        final newQueue = (data['queue'] as List?)
                ?.map((json) => Track.fromJson((json as Map).cast<String, dynamic>()))
                .toList() ??
            state.sharedQueue;

        state = state.copyWith(
          nowPlaying: nowPlaying,
          isPlaying: data['isPlaying'] as bool? ?? state.isPlaying,
          sharedQueue: newQueue,
          position: data['position'] as int?,
          timestamp: data['timestamp'] as int?,
        );
      }
    });

    // NEW: guest_list_changed replaces guest_count_changed
    _socket!.on('guest_list_changed', (data) {
      if (data is Map) {
        final names = (data['guests'] as List?)?.map((e) => e.toString()).toList() ?? [];
        state = state.copyWith(
          guestCount: data['count'] as int? ?? names.length,
          guestNames: names,
        );
      }
    });

    // Fallback for old servers that still send guest_count_changed
    _socket!.on('guest_count_changed', (data) {
      if (data is Map) {
        state = state.copyWith(guestCount: data['count'] as int? ?? state.guestCount);
      }
    });

    _socket!.on('room_closed', (data) {
      _hostSyncTimer?.cancel();
      final reason = data is Map ? (data['reason'] as String?) : null;
      state = PassTheAuxState(
        isConnected: true,
        error: reason ?? 'The host ended the session.',
      );
    });

    _socket!.on('sync_requested', (_) {
      _broadcastHostState();
    });

    _socket!.connect();
  }

  // ── Room Management ──────────────────────────────────────────────

  void createRoom() {
    final code = _generateRoomCode();
    state = state.copyWith(
      roomId: code,
      isHost: true,
      guestCount: 0,
      guestNames: const [],
      isCreatingRoom: false,
      error: null,
    );
    _startHostSyncTimer();

    if (_socket != null && _socket!.connected) {
      _socket!.emit('create_room', {
        'roomId': code,
        'hostName': _displayName,
      });
    }
  }

  String _generateRoomCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rng = Random.secure();
    return List.generate(6, (_) => chars[rng.nextInt(chars.length)]).join();
  }

  void joinRoom(String roomId) {
    if (!state.isConnected || _socket == null) {
      state = state.copyWith(error: 'Not connected. Please wait or retry.');
      return;
    }
    final code = roomId.trim().toUpperCase();

    _socket!.emitWithAck(
      'join_room',
      {'roomId': code, 'displayName': _displayName},
      ack: (response) {
        final data = _unwrapAck(response);
        if (data != null && data['success'] == true) {
          final newQueue = (data['queue'] as List?)
                  ?.map((json) =>
                      Track.fromJson((json as Map).cast<String, dynamic>()))
                  .toList() ??
              [];
          final nowPlaying = data['nowPlaying'] != null
              ? Track.fromJson(
                  (data['nowPlaying'] as Map).cast<String, dynamic>())
              : null;

          state = state.copyWith(
            roomId: code,
            isHost: false,
            sharedQueue: newQueue,
            nowPlaying: nowPlaying,
            isPlaying: data['isPlaying'] == true,
            position: data['position'] as int?,
            timestamp: data['timestamp'] as int?,
            guestCount: data['guestCount'] as int? ?? 0,
            error: null,
          );
          requestSync();
        } else {
          state = state.copyWith(
            error: data?['error'] as String? ??
                'Room not found. Check the code and try again.',
          );
        }
      },
    );
  }

  Map<String, dynamic>? _unwrapAck(dynamic response) {
    if (response is Map<String, dynamic>) return response;
    if (response is Map) return response.cast<String, dynamic>();
    if (response is List && response.isNotEmpty) {
      final first = response.first;
      if (first is Map<String, dynamic>) return first;
      if (first is Map) return first.cast<String, dynamic>();
    }
    return null;
  }

  void leaveRoom() {
    _hostSyncTimer?.cancel();
    if (state.roomId != null) {
      _socket?.emit('leave_room', state.roomId);
    }
    state = PassTheAuxState(isConnected: state.isConnected);
  }

  // ── Track Management ─────────────────────────────────────────────

  /// Guest adds a track to the shared queue.
  void addTrack(Track track) {
    if (state.roomId == null || _socket == null) return;
    _socket!.emit('add_track', {
      'roomId': state.roomId,
      'track': track.toJson(),
      'guestName': _displayName,
    });
    // Optimistic update for guest (so queue updates instantly)
    if (!state.isHost) {
      final newQueue = [...state.sharedQueue, track];
      state = state.copyWith(sharedQueue: newQueue);
      _trackAddedController.add('Added "${track.title}" to the party queue!');
    }
  }

  /// Host adds a track directly to the room queue.
  void addTrackAsHost(Track track) {
    if (!state.isHost || state.roomId == null || _socket == null) return;
    _socket!.emit('add_track_by_host', {
      'roomId': state.roomId,
      'track': track.toJson(),
    });
    // Optimistic update
    final newQueue = [...state.sharedQueue, track];
    state = state.copyWith(sharedQueue: newQueue);
    _trackAddedController.add('Added "${track.title}" to the queue!');
  }

  void kickTrack(int index) {
    if (!state.isHost || state.roomId == null || _socket == null) return;
    _socket!.emit('kick_track', {'roomId': state.roomId, 'trackIndex': index});
    // Optimistic update
    final newQueue = List<Track>.from(state.sharedQueue)..removeAt(index);
    state = state.copyWith(sharedQueue: newQueue);
  }

  // ── Sync ─────────────────────────────────────────────────────────

  void toggleSyncMode(bool enabled) {
    state = state.copyWith(isSyncModeEnabled: enabled);
    if (enabled) requestSync();
  }

  void requestSync() {
    if (state.roomId == null || _socket == null || state.isHost) return;
    _socket!.emitWithAck('request_sync', state.roomId, ack: (_) {});
  }

  void hostSyncState({
    Track? nowPlaying,
    bool? isPlaying,
    List<Track>? queue,
    int? position,
    int? timestamp,
  }) {
    if (!state.isHost || state.roomId == null || _socket == null) return;

    // Update local state so host UI reflects current playback
    state = state.copyWith(
      nowPlaying: nowPlaying,
      isPlaying: isPlaying,
      position: position,
      timestamp: timestamp,
    );

    _socket!.emit('host_sync_state', {
      'roomId': state.roomId,
      'nowPlaying': nowPlaying?.toJson(),
      'isPlaying': isPlaying,
      'queue': queue?.map((t) => t.toJson()).toList(),
      'position': position,
      'timestamp': timestamp,
    });
  }

  void _broadcastHostState() {
    // No-op: audio_handler calls hostSyncState directly
  }

  void _startHostSyncTimer() {
    _hostSyncTimer?.cancel();
    _hostSyncTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      // audio_handler drives the actual sync
    });
  }

  // ── Disconnect ───────────────────────────────────────────────────

  void disconnect() {
    _hostSyncTimer?.cancel();
    _socket?.dispose();
    _socket = null;
    state = const PassTheAuxState();
  }

  @override
  void dispose() {
    _hostSyncTimer?.cancel();
    _guestTrackController.close();
    _trackAddedController.close();
    _socket?.dispose();
    super.dispose();
  }
}

final passTheAuxProvider =
    StateNotifierProvider<PassTheAuxNotifier, PassTheAuxState>((ref) {
  return PassTheAuxNotifier(ref);
});
