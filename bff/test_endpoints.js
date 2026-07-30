const axios = require('axios');
async function test() {
  try {
    const res = await axios.get('http://127.0.0.1:3000/recommendations/upnext/dQw4w9WgXcQ');
    console.log('UpNext Tracks:', res.data.data.length);
    
    const res2 = await axios.get('http://127.0.0.1:3000/recommendations/home');
    console.log('Home Shelves:', res2.data.data.length);
    console.log('First Shelf Title:', res2.data.data[0].title);
    console.log('First Shelf Tracks:', res2.data.data[0].tracks.length);
  } catch (e) {
    console.error('Error:', e.message);
  }
}
test();
