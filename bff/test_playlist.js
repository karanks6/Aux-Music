const YTMusic = require('ytmusic-api');
const fs = require('fs');

async function test() {
  try {
    const yt = new YTMusic();
    await yt.initialize();
    const playlist = await yt.getPlaylist('RDCLAK5uy_nbTnrBv4CxZys35IAzhO0-fFCiKD58qzo');
    fs.writeFileSync('playlist.json', JSON.stringify(playlist, null, 2));
    console.log('Successfully wrote playlist.json');
    process.exit(0);
  } catch (e) {
    console.error(e);
    process.exit(1);
  }
}
test();
