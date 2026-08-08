import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../../data/models/track.dart';

// ── State ──────────────────────────────────────────────────────────────────

class PassTheAuxState {
  final bool isConnecting;
  final bool isConnected;
  final String? roomId;
  final bool isHost;
  final int guestCount;
  final List<Track> sharedQueue;
  final Track? nowPlaying;
  final bool isPlaying;
  final String? error;
  final bool isSyncModeEnabled;

  // Synced Audio position fields
  final int? position;
  final int? timestamp;

  const PassTheAuxState({
    this.isConnecting = false,
    this.isConnected = false,
    this.roomId,
    this.isHost = false,
    this.guestCount = 0,
    this.sharedQueue = const [],
    this.nowPlaying,
    this.isPlaying = false,
    this.error,
    this.isSyncModeEnabled = false,
    this.position,
    this.timestamp,
  });

  PassTheAuxState copyWith({
    bool? isConnecting,
    bool? isConnected,
    String? roomId,
    bool? isHost,
    int? guestCount,
    List<Track>? sharedQueue,
    Track? nowPlaying,
    bool? isPlaying,
    Object? error = _sentinel,
    bool? isSyncModeEnabled,
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
      sharedQueue: sharedQueue ?? this.sharedQueue,
      nowPlaying: clearNowPlaying ? null : (nowPlaying ?? this.nowPlaying),
      isPlaying: isPlaying ?? this.isPlaying,
      error: identical(error, _sentinel) ? this.error : error as String?,
      isSyncModeEnabled: isSyncModeEnabled ?? this.isSyncModeEnabled,
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

  // Stream: guest track added confirmation (for snackbar etc.)
  final _trackAddedController = StreamController<String>.broadcast();
  Stream<String> get onTrackAddedConfirmation => _trackAddedController.stream;

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

    // ── Event Listeners ──────────────────────────────────────────

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

    // Server asks us (as host) to re-broadcast state immediately
    _socket!.on('sync_requested', (_) {
      _broadcastHostState();
    });

    _socket!.connect();
  }

  // ── Room Management ──────────────────────────────────────────────

  void createRoom() {
    if (_socket == null || !_socket!.connected) return;

    // Let the server generate the room code to avoid collisions
    _socket!.emitWithAck('create_room', null, ack: (response) {
      if (response is Map && response['success'] == true) {
        final roomId = response['roomId'] as String;
        state = state.copyWith(roomId: roomId, isHost: true, guestCount: 0, error: null);
        _startHostSyncTimer();
      } else {
        state = state.copyWith(error: 'Failed to create room. Please try again.');
      }
    });
  }

  void joinRoom(String roomId) {
    if (_socket == null || !_socket!.connected) return;
    final code = roomId.trim().toUpperCase();

    _socket!.emitWithAck('join_room', code, ack: (response) {
      if (response is Map && response['success'] == true) {
        final newQueue = (response['queue'] as List?)
                ?.map((json) => Track.fromJson((json as Map).cast<String, dynamic>()))
                .toList() ??
            [];
        final nowPlaying = response['nowPlaying'] != null
            ? Track.fromJson((response['nowPlaying'] as Map).cast<String, dynamic>())
            : null;

        state = state.copyWith(
          roomId: code,
          isHost: false,
          sharedQueue: newQueue,
          nowPlaying: nowPlaying,
          isPlaying: response['isPlaying'] == true,
          position: response['position'] as int?,
          timestamp: response['timestamp'] as int?,
          guestCount: response['guestCount'] as int? ?? 0,
          error: null,
        );
        // Request immediate re-sync so we jump to the right position
        requestSync();
      } else {
        state = state.copyWith(
          error: (response is Map ? response['error'] as String? : null) ??
              'Room not found. Check the code and try again.',
        );
      }
    });
  }

  void leaveRoom() {
    _hostSyncTimer?.cancel();
    if (state.roomId != null) {
      _socket?.emit('leave_room', state.roomId);
    }
    state = PassTheAuxState(isConnected: state.isConnected);
  }

  // ── Track Management ─────────────────────────────────────────────

  void addTrack(Track track) {
    if (state.roomId == null || _socket == null) return;
    _socket!.emit('add_track', {
      'roomId': state.roomId,
      'track': track.toJson(),
      'guestName': 'Guest',
    });
    // Optimistic confirmation for guest
    if (!state.isHost) {
      _trackAddedController.add('Added "${track.title}" to the host\'s queue!');
    }
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
    // Called by audio_handler to push current state
    // This method is intentionally a no-op here; the audio handler calls hostSyncState directly
  }

  void _startHostSyncTimer() {
    _hostSyncTimer?.cancel();
    // Host broadcasts position every 5 seconds so guests can correct drift
    _hostSyncTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      // audio_handler will call hostSyncState — we just need to trigger it
      // The timer itself is managed in audio_handler via listening to passTheAuxProvider
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
