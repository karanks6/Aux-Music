const { Innertube, UniversalCache } = require('youtubei.js');

async function test() {
  const yt = await Innertube.create({ cache: new UniversalCache(false) });
  const results = await yt.music.search('future podcast', { type: 'video' });
  
  // Dump the top level structure
  console.log('Results top level:');
  console.log(Object.keys(results));
  console.log(results.contents ? 'Has contents' : 'No contents');
  
  if (results.contents && results.contents.length > 0) {
    console.log('First content type:', results.contents[0].type);
    if (results.contents[0].contents) {
        console.log('Inner contents length:', results.contents[0].contents.length);
        console.log('First inner content type:', results.contents[0].contents[0].type);
        // Dump the first item completely
        console.log('First item:', JSON.stringify(results.contents[0].contents[0], null, 2));
    } else {
        console.log('First content type has no inner contents.');
        console.log('First content:', JSON.stringify(results.contents[0], null, 2));
    }
  }
}

test().catch(console.error);
