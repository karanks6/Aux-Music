const YTMusic = require('ytmusic-api');
const fs = require('fs');

async function test() {
  try {
    const yt = new YTMusic();
    await yt.initialize();
    const playlist = await yt.getPlaylist('OLAK5uy_kgZN3Rr0x6ckgKtw7ERfcXweRF-ZIiMQ0');
    fs.writeFileSync('album.json', JSON.stringify(playlist, null, 2));
    console.log('Successfully wrote album.json');
    process.exit(0);
  } catch (e) {
    console.error(e);
    process.exit(1);
  }
}
test();
