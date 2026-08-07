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

  PassTheAuxState({
    this.isConnected = false,
    this.roomId,
    this.isHost = false,
    this.sharedQueue = const [],
    this.nowPlaying,
    this.isPlaying = false,
    this.error,
  });

  PassTheAuxState copyWith({
    bool? isConnected,
    String? roomId,
    bool? isHost,
    List<Track>? sharedQueue,
    Track? nowPlaying,
    bool? isPlaying,
    String? error,
  }) {
    return PassTheAuxState(
      isConnected: isConnected ?? this.isConnected,
      roomId: roomId ?? this.roomId,
      isHost: isHost ?? this.isHost,
      sharedQueue: sharedQueue ?? this.sharedQueue,
      nowPlaying: nowPlaying ?? this.nowPlaying,
      isPlaying: isPlaying ?? this.isPlaying,
      error: error, // Can be set to null intentionally
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

  void connect() {
    if (_socket != null && _socket!.connected) return;

    _socket = IO.io(_serverUrl, IO.OptionBuilder()
        .setTransports(['websocket'])
        .disableAutoConnect()
        .build());

    _socket!.onConnect((_) {
      print('[PassTheAux] Connected to relay server');
      state = state.copyWith(isConnected: true, error: null);
    });

    _socket!.onDisconnect((_) {
      print('[PassTheAux] Disconnected from relay server');
      state = state.copyWith(isConnected: false, roomId: null, sharedQueue: []);
    });

    _socket!.onConnectError((err) {
      print('[PassTheAux] Connection Error: $err');
      state = state.copyWith(error: 'Failed to connect to relay server');
    });

    // ── Listeners ──

    _socket!.on('queue_updated', (data) {
      if (data is List) {
        final newQueue = data.map((json) => Track.fromJson(json)).toList();
        state = state.copyWith(sharedQueue: newQueue);
        
        // If I am the Host, update the actual audio player queue
        if (state.isHost) {
          // We must be careful not to create a circular dependency here,
          // but we can invoke methods on the audioHandler directly if we have access to it.
          // Since we are the Host, the sharedQueue IS our queue.
        }
      }
    });

    _socket!.on('state_synced', (data) {
      if (data is Map) {
        final nowPlaying = data['nowPlaying'] != null ? Track.fromJson(data['nowPlaying']) : null;
        final isPlaying = data['isPlaying'] as bool? ?? false;
        final newQueue = (data['queue'] as List?)?.map((json) => Track.fromJson(json)).toList() ?? state.sharedQueue;
        
        state = state.copyWith(
          nowPlaying: nowPlaying,
          isPlaying: isPlaying,
          sharedQueue: newQueue,
        );
      }
    });

    _socket!.on('room_closed', (_) {
      leaveRoom();
      state = state.copyWith(error: 'The host closed the room.');
    });

    _socket!.connect();
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
        
        state = state.copyWith(
          roomId: roomId,
          isHost: false,
          sharedQueue: newQueue,
          nowPlaying: nowPlaying,
          isPlaying: response['isPlaying'] == true,
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
    state = state.copyWith(roomId: null, isHost: false, sharedQueue: [], nowPlaying: null);
  }

  void addTrack(Track track) {
    if (state.roomId == null || _socket == null) return;
    
    _socket!.emit('add_track', {
      'roomId': state.roomId,
      'track': track.toJson(),
    });
  }

  void hostSyncState({Track? nowPlaying, bool? isPlaying, List<Track>? queue}) {
    if (!state.isHost || state.roomId == null || _socket == null) return;

    _socket!.emit('host_sync_state', {
      'roomId': state.roomId,
      'nowPlaying': nowPlaying?.toJson(),
      'isPlaying': isPlaying,
      'queue': queue?.map((t) => t.toJson()).toList(),
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
