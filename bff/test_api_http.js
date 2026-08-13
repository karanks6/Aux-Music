const http = require('http');

http.get('http://127.0.0.1:3000/recommendations/home', (res) => {
  let data = '';
  res.on('data', (chunk) => {
    data += chunk;
  });
  res.on('end', () => {
    try {
      const json = JSON.parse(data);
      console.log(`Received ${json.data.length} shelves`);
      json.data.forEach(shelf => {
        console.log(`Shelf: ${shelf.title}`);
        if (shelf.tracks && shelf.tracks.length > 0) {
          console.log(`  Tracks: ${shelf.tracks.length}, First: ${shelf.tracks[0].title}`);
        } else {
          console.log(`  No tracks!`);
        }
      });
    } catch (e) {
      console.error('Failed to parse:', e.message);
      console.log(data);
    }
  });
}).on('error', (err) => {
  console.log('Error:', err.message);
});
