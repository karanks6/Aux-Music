const ytdl = require('@distube/ytdl-core');

async function test() {
  try {
    const info = await ytdl.getInfo('dQw4w9WgXcQ');
    const format = ytdl.chooseFormat(info.formats, { quality: 'highestaudio' });
    console.log("Success! URL:");
    console.log(format.url);
  } catch (e) {
    console.error("Error:", e.message);
  }
}
test();
