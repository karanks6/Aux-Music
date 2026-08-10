import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/pass_the_aux_service.dart';
import '../../data/models/track.dart';

/// Exposes whether the user is currently in an active Pass the Aux session.
final inAuxSessionProvider = Provider<bool>((ref) {
  final state = ref.watch(passTheAuxProvider);
  return state.roomId != null && state.isConnected;
});

/// Exposes whether the user is currently the host of an active Pass the Aux session.
final isAuxHostProvider = Provider<bool>((ref) {
  final state = ref.watch(passTheAuxProvider);
  return state.isHost && state.roomId != null && state.isConnected;
});

/// Helper to add a track to the Aux queue from anywhere.
void addTrackToAuxSession(WidgetRef ref, Track track) {
  final isHost = ref.read(isAuxHostProvider);
  if (isHost) {
    ref.read(passTheAuxProvider.notifier).addTrackAsHost(track);
  } else {
    ref.read(passTheAuxProvider.notifier).addTrack(track);
  }
}
