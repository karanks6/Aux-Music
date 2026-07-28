const youtubedl = require('youtube-dl-exec');
async function test() {
  try {
    const url = 'https://www.youtube.com/watch?v=dQw4w9WgXcQ';
    const output = await youtubedl(url, {
      dumpJson: true,
      noWarnings: true,
      noCheckCertificate: true,
      preferFreeFormats: true,
      format: 'm4a/bestaudio/best',
      extractorArgs: 'youtube:player-client=tv'
    });
    console.log(output.url);
  } catch(e) {
    console.error(e.message);
  }
}
test();
