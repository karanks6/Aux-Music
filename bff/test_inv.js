const fetch = require('axios');
async function test() {
  try {
    const res = await fetch('https://api.invidious.io/instances.json');
    const instances = res.data;
    const working = instances.filter(i => i[1].type === 'https' && i[1].api && i[1].cors);
    working.sort((a,b) => a[1].health - b[1].health);
    for (let i=0; i<3; i++) {
      const uri = working[i][1].uri;
      try {
        const testRes = await fetch(uri + '/api/v1/videos/dQw4w9WgXcQ', { timeout: 3000 });
        if (testRes.status === 200) console.log(uri + ' works!');
      } catch(e) {}
    }
  } catch(e) { console.error(e.message); }
}
test();
