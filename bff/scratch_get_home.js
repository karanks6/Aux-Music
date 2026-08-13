const { getInnertube } = require('./src/adapters/stream_resolver.js');

async function main() {
  const yt = await getInnertube();
  // Trending playlist ID for testing
  const playlist = await yt.music.getPlaylist('PL4fGSI1pccs4yL1U9K-t0jD_3B8H_D9yU'); // Global Top 100
  console.log('Playlist items count:', playlist.items?.length);
  if (playlist.items && playlist.items.length > 0) {
    console.log('First item type:', playlist.items[0].type, playlist.items[0].title);
  }
}

main().catch(console.error);
