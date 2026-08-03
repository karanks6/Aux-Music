const YTMusic = require('ytmusic-api');
const fs = require('fs');

async function test() {
  try {
    const yt = new YTMusic();
    await yt.initialize();
    const sections = await yt.getHomeSections();
    fs.writeFileSync('home_sections.json', JSON.stringify(sections, null, 2));
    console.log('Successfully wrote home_sections.json');
    process.exit(0);
  } catch (e) {
    console.error(e);
    process.exit(1);
  }
}
test();
