const youtubedl = require('youtube-dl-exec');
async function test() {
  try {
    const url = 'https://www.youtube.com/watch?v=dQw4w9WgXcQ';
    const output = await youtubedl(url, {
      listFormats: true,
      extractorArgs: 'youtube:player-client=ios'
    });
    console.log(output);
  } catch(e) {
    console.error(e.message);
  }
}
test();
