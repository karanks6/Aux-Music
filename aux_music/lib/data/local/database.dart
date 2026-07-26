import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';
import 'tables.dart';

part 'database.g.dart';

@DriftDatabase(tables: [
  LikedTracks, 
  Playlists, 
  PlaylistTracks, 
  DownloadedFiles, 
  RecentSearches,
  SubscribedPodcasts,
  PodcastEpisodesProgress,
])
class AuxDatabase extends _$AuxDatabase {
  AuxDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          if (from < 2) {
            await m.addColumn(downloadedFiles, downloadedFiles.title);
            await m.addColumn(downloadedFiles, downloadedFiles.artistName);
            await m.addColumn(downloadedFiles, downloadedFiles.artworkUrl);
          }
        },
      );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'aux_library.sqlite'));

    // Fix for older Android devices where sqlite3 might need to find the correct tmp dir
    if (Platform.isAndroid) {
      await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
      // Also setup temp dir for sqlite3
      final cachebase = (await getTemporaryDirectory()).path;
      sqlite3.tempDirectory = cachebase;
    }

    return NativeDatabase.createInBackground(file);
  });
}
