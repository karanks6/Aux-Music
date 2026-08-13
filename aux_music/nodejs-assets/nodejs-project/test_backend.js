const youtubeMusic = require('./src/adapters/youtube_music');

async function run() {
  const res = await youtubeMusic.searchPodcasts('future');
  console.log(JSON.stringify(res, null, 2));
}

run();
