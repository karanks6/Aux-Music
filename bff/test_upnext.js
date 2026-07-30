const YTMusic = require('ytmusic-api');
const fs = require('fs');

async function test() {
  try {
    const yt = new YTMusic();
    await yt.initialize();
    const upNext = await yt.getUpNexts('dQw4w9WgXcQ');
    fs.writeFileSync('upnext.json', JSON.stringify(upNext, null, 2));
    console.log('Successfully wrote upnext.json');
    process.exit(0);
  } catch (e) {
    console.error(e);
    process.exit(1);
  }
}
test();
