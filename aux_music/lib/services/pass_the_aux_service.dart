import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../../data/models/track.dart';

// State model
class PassTheAuxState {
  final bool isConnected;
  final String? roomId;
  final bool isHost;
  final List<Track> sharedQueue;
  final Track? nowPlaying;
  final bool isPlaying;
  final String? error;
  
  // Synced Audio Fields
  final int? position;
  final int? timestamp;
  final bool isSyncModeEnabled;

  PassTheAuxState({
    this.isConnected = false,
    this.roomId,
    this.isHost = false,
    this.sharedQueue = const [],
    this.nowPlaying,
    this.isPlaying = false,
    this.error,
    this.position,
    this.timestamp,
    this.isSyncModeEnabled = false,
  });

  PassTheAuxState copyWith({
    bool? isConnected,
    String? roomId,
    bool? isHost,
    List<Track>? sharedQueue,
    Track? nowPlaying,
    bool? isPlaying,
    String? error,
    int? position,
    int? timestamp,
    bool? isSyncModeEnabled,
  }) {
    return PassTheAuxState(
      isConnected: isConnected ?? this.isConnected,
      roomId: roomId ?? this.roomId,
      isHost: isHost ?? this.isHost,
      sharedQueue: sharedQueue ?? this.sharedQueue,
      nowPlaying: nowPlaying ?? this.nowPlaying,
      isPlaying: isPlaying ?? this.isPlaying,
      error: error, // Can be set to null intentionally
      position: position ?? this.position,
      timestamp: timestamp ?? this.timestamp,
      isSyncModeEnabled: isSyncModeEnabled ?? this.isSyncModeEnabled,
    );
  }
}

class PassTheAuxNotifier extends StateNotifier<PassTheAuxState> {
  PassTheAuxNotifier(this.ref) : super(PassTheAuxState());
  final Ref ref;

  IO.Socket? _socket;

  // The deployed Render URL goes here eventually!
  // For now, using localhost for simulator testing. 
  // (Note: use 10.0.2.2 for Android emulator to host machine localhost)
  final String _serverUrl = 'https://aux-music-bff.onrender.com';

  final _guestTrackController = StreamController<Track>.broadcast();
  Stream<Track> get onGuestAddedTrack => _guestTrackController.stream;

  void connect() {
    if (_socket != null) return;
    state = state.copyWith(error: null);

    _socket = IO.io(_serverUrl, IO.OptionBuilder()
      .setTransports(['websocket'])
      .disableAutoConnect()
      .build()
    );

    _socket!.onConnect((_) {
      print('[PassTheAux] Connected to Relay Server');
      state = state.copyWith(isConnected: true, error: null);
    });

    _socket!.onDisconnect((_) {
      print('[PassTheAux] Disconnected from Relay Server');
      state = state.copyWith(isConnected: false, roomId: null, isHost: false);
    });

    _socket!.onConnectError((err) {
      print('[PassTheAux] Connection Error: $err');
      state = state.copyWith(error: 'Failed to connect to relay server');
    });

    // ── Listeners ──

    _socket!.on('guest_added_track', (data) {
      if (data is Map) {
        try {
          final track = Track.fromJson(data.cast<String, dynamic>());
          _guestTrackController.add(track);
        } catch (_) {}
      }
    });

    _socket!.on('state_synced', (data) {
      if (data is Map) {
        final nowPlaying = data['nowPlaying'] != null ? Track.fromJson(data['nowPlaying']) : null;
        final isPlaying = data['isPlaying'] as bool? ?? false;
        final newQueue = (data['queue'] as List?)?.map((json) => Track.fromJson(json)).toList() ?? state.sharedQueue;
        final position = data['position'] as int?;
        final timestamp = data['timestamp'] as int?;
        
        state = state.copyWith(
          nowPlaying: nowPlaying,
          isPlaying: isPlaying,
          sharedQueue: newQueue,
          position: position,
          timestamp: timestamp,
        );
      }
    });

    _socket!.on('room_closed', (_) {
      leaveRoom();
      state = state.copyWith(error: 'The host closed the room.');
    });

    _socket!.connect();
  }

  void toggleSyncMode(bool enabled) {
    state = state.copyWith(isSyncModeEnabled: enabled);
  }

  void createRoom() {
    if (_socket == null || !_socket!.connected) return;
    
    // Generate a simple 4 digit code for the room
    final code = (1000 + (DateTime.now().millisecondsSinceEpoch % 9000)).toString();
    
    _socket!.emitWithAck('create_room', code, ack: (response) {
      if (response['success'] == true) {
        state = state.copyWith(roomId: code, isHost: true, error: null);
      }
    });
  }

  void joinRoom(String roomId) {
    if (_socket == null || !_socket!.connected) return;

    _socket!.emitWithAck('join_room', roomId, ack: (response) {
      if (response['success'] == true) {
        final newQueue = (response['queue'] as List?)?.map((json) => Track.fromJson(json)).toList() ?? [];
        final nowPlaying = response['nowPlaying'] != null ? Track.fromJson(response['nowPlaying']) : null;
        final position = response['position'] as int?;
        final timestamp = response['timestamp'] as int?;
        
        state = state.copyWith(
          roomId: roomId,
          isHost: false,
          sharedQueue: newQueue,
          nowPlaying: nowPlaying,
          isPlaying: response['isPlaying'] == true,
          position: position,
          timestamp: timestamp,
          error: null,
        );
      } else {
        state = state.copyWith(error: response['error'] ?? 'Failed to join room');
      }
    });
  }

  void leaveRoom() {
    if (state.roomId != null) {
      _socket?.emit('leave_room', state.roomId); // Optional, server cleans up on disconnect anyway
    }
    state = state.copyWith(roomId: null, isHost: false, sharedQueue: [], nowPlaying: null, isSyncModeEnabled: false);
  }

  void addTrack(Track track) {
    if (state.roomId == null || _socket == null) return;
    
    _socket!.emit('add_track', {
      'roomId': state.roomId,
      'track': track.toJson(),
    });
  }

  void hostSyncState({Track? nowPlaying, bool? isPlaying, List<Track>? queue, int? position, int? timestamp}) {
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

  @override
  void dispose() {
    _socket?.dispose();
    super.dispose();
  }
}

final passTheAuxProvider = StateNotifierProvider<PassTheAuxNotifier, PassTheAuxState>((ref) {
  return PassTheAuxNotifier();
});
