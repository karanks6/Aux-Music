const play = require('play-dl');

async function test() {
  try {
    const stream = await play.stream('dQw4w9WgXcQ', { quality: 2, discordPlayerCompatibility: true });
    console.log(stream.url);
  } catch (e) {
    console.error(e);
  }
}
test();
