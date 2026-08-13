const { getInnertube } = require('./src/adapters/stream_resolver');

async function test() {
  const yt = await getInnertube();
  const res = await yt.music.search('technology', { type: 'podcasts' });
  console.log(JSON.stringify(res.contents, null, 2));
}

test().catch(console.error);
