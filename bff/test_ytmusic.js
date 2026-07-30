const YTMusic = require('ytmusic-api');
const ytmusic = new YTMusic();

async function test() {
  await ytmusic.initialize();
  try {
    const res = await ytmusic.getUpNexts('dQw4w9WgXcQ');
    console.log('dQw4w9WgXcQ up nexts:', res.length);
  } catch (e) {
    console.error('dQ error:', e.message);
  }

  try {
    const res2 = await ytmusic.getUpNexts('XXYlFuWEuKI');
    console.log('XXYlFuWEuKI up nexts:', res2.length);
  } catch (e) {
    console.error('XXY error:', e.message);
  }
}
test();
