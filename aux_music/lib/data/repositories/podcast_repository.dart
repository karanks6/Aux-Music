import 'package:drift/drift.dart';
import 'package:xml/xml.dart';
import 'package:dio/dio.dart';
import 'dart:convert';
import '../../data/models/podcast.dart';
import '../local/database.dart';

class PodcastRepository {
  final AuxDatabase _db;
  final Dio _dio = Dio();

  PodcastRepository(this._db);

  // ── Subscriptions ────────────────────────────────────────────────

  Stream<List<Podcast>> watchSubscriptions() {
    return (_db.select(_db.subscribedPodcasts)
          ..orderBy([(p) => OrderingTerm(expression: p.subscribedAt, mode: OrderingMode.desc)]))
        .watch()
        .map((rows) => rows.map((r) => Podcast(
              id: r.id,
              title: r.title,
              author: r.author,
              description: r.description,
              feedUrl: r.feedUrl,
              artworkUrl: r.artworkUrl,
            )).toList());
  }

  Future<void> subscribe(Podcast podcast) async {
    await _db.into(_db.subscribedPodcasts).insertOnConflictUpdate(
          SubscribedPodcast(
            id: podcast.id,
            title: podcast.title,
            author: podcast.author,
            description: podcast.description,
            artworkUrl: podcast.artworkUrl,
            feedUrl: podcast.feedUrl,
            subscribedAt: DateTime.now(),
          ),
        );
  }

  Future<void> unsubscribe(String podcastId) async {
    await (_db.delete(_db.subscribedPodcasts)..where((p) => p.id.equals(podcastId))).go();
  }

  // ── Parsing ──────────────────────────────────────────────────────

  Future<Podcast> parseFeedUrl(String url) async {
    final response = await _dio.get(url);
    final document = XmlDocument.parse(response.data.toString());
    final channel = document.findAllElements('channel').first;

    final title = channel.findElements('title').firstOrNull?.innerText ?? 'Unknown Podcast';
    final author = channel.findElements('itunes:author').firstOrNull?.innerText ?? 'Unknown Author';
    final description = channel.findElements('description').firstOrNull?.innerText ?? '';
    final image = channel.findElements('itunes:image').firstOrNull?.getAttribute('href') ?? 
                  channel.findElements('image').firstOrNull?.findElements('url').firstOrNull?.innerText;

    // Use feed url as ID
    return Podcast(
      id: url,
      title: title,
      author: author,
      description: description,
      feedUrl: url,
      artworkUrl: image,
    );
  }

  // ── Cache ────────────────────────────────────────────────────────
  final Map<String, List<Podcast>> _searchCache = {};
  final Map<String, List<PodcastEpisode>> _episodeCache = {};

  // ── iTunes API Search ────────────────────────────────────────────

  Future<List<Podcast>> searchPodcasts(String term, {int limit = 10}) async {
    final cacheKey = '$term-$limit';
    if (_searchCache.containsKey(cacheKey)) {
      return _searchCache[cacheKey]!;
    }

    try {
      final url = 'https://itunes.apple.com/search?term=${Uri.encodeComponent(term)}&entity=podcast&limit=$limit';
      final response = await _dio.get(url);
      
      final data = response.data is String ? response.data : response.data.toString();
      Map<String, dynamic> json;
      if (response.data is Map<String, dynamic>) {
        json = response.data;
      } else if (response.data is String) {
        json = jsonDecode(response.data);
      } else {
        json = {};
      }

      final results = json['results'] as List<dynamic>? ?? [];
      
      final podcasts = <Podcast>[];
      for (final r in results) {
        final feedUrl = r['feedUrl'] as String?;
        if (feedUrl == null) continue;

        podcasts.add(Podcast(
          id: feedUrl,
          title: r['collectionName'] as String? ?? 'Unknown Podcast',
          author: r['artistName'] as String? ?? 'Unknown Author',
          description: '',
          feedUrl: feedUrl,
          artworkUrl: r['artworkUrl600'] as String? ?? r['artworkUrl100'] as String?,
        ));
      }
      _searchCache[cacheKey] = podcasts;
      return podcasts;
    } catch (e) {
      print('iTunes search error for $term: $e');
      return [];
    }
  }

  Future<List<PodcastEpisode>> fetchEpisodes(Podcast podcast) async {
    if (_episodeCache.containsKey(podcast.id)) {
      return _episodeCache[podcast.id]!;
    }

    try {
      final response = await _dio.get(podcast.feedUrl);
      final document = XmlDocument.parse(response.data.toString());
      final items = document.findAllElements('item');

      final episodes = <PodcastEpisode>[];
      for (final item in items) {
        final title = item.findElements('title').firstOrNull?.innerText ?? 'Unknown Episode';
        final description = item.findElements('description').firstOrNull?.innerText ?? '';
        final enclosure = item.findElements('enclosure').firstOrNull;
        final streamUrl = enclosure?.getAttribute('url');
        
        if (streamUrl == null) continue;

        final guid = item.findElements('guid').firstOrNull?.innerText ?? streamUrl;
        final pubDateStr = item.findElements('pubDate').firstOrNull?.innerText;
        DateTime? pubDate;
        if (pubDateStr != null) {
          try {
            pubDate = DateTime.parse(pubDateStr);
          } catch (_) {}
        }

        final itunesDuration = item.findElements('itunes:duration').firstOrNull?.innerText;
        int durationMs = 0;
        if (itunesDuration != null) {
          if (itunesDuration.contains(':')) {
            final parts = itunesDuration.split(':');
            if (parts.length == 3) {
              durationMs = (int.parse(parts[0]) * 3600 + int.parse(parts[1]) * 60 + int.parse(parts[2])) * 1000;
            } else if (parts.length == 2) {
              durationMs = (int.parse(parts[0]) * 60 + int.parse(parts[1])) * 1000;
            }
          } else {
            durationMs = (int.tryParse(itunesDuration) ?? 0) * 1000;
          }
        }

        final image = item.findElements('itunes:image').firstOrNull?.getAttribute('href');

        episodes.add(PodcastEpisode(
          id: guid,
          podcastId: podcast.id,
          title: title,
          description: description,
          streamUrl: streamUrl,
          publishedAt: pubDate ?? DateTime.now(),
          durationMs: durationMs,
          artworkUrl: image ?? podcast.artworkUrl,
        ));
      }
      
      _episodeCache[podcast.id] = episodes;
      return episodes;
    } catch (e) {
      print('Fetch episodes error for ${podcast.title}: $e');
      return [];
    }
  }
}
