import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/podcast_repository.dart';
import '../../data/models/podcast.dart';
import 'library_providers.dart';

final podcastRepositoryProvider = Provider<PodcastRepository>((ref) {
  return PodcastRepository(ref.watch(databaseProvider));
});

final subscribedPodcastsProvider = StreamProvider<List<Podcast>>((ref) {
  return ref.watch(podcastRepositoryProvider).watchSubscriptions();
});

final podcastEpisodesProvider = FutureProvider.family<List<PodcastEpisode>, Podcast>((ref, podcast) async {
  return ref.watch(podcastRepositoryProvider).fetchEpisodes(podcast);
});
