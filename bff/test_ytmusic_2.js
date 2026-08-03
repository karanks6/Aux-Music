const YTMusic = require('ytmusic-api');
const ytmusic = new YTMusic();

async function test() {
  await ytmusic.initialize();
  try {
    const res = await ytmusic.getUpNexts('dQw4w9WgXcQ');
    console.log(JSON.stringify(res[0], null, 2));
  } catch (e) {
    console.error('dQ error:', e.message);
  }
}
test();
