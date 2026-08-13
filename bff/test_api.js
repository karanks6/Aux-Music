const { getInnertube } = require('./src/adapters/stream_resolver.js');
const { parseTrack } = require('./src/adapters/youtube_music.js');

async function main() {
  const yt = await getInnertube();
  const results = await yt.music.getUpNext('aGKDEs0_ZwA');
  
  let rawTracks = [];
  if (results && results.contents && results.contents.length > 0) {
    if (results.contents[0].type === 'MusicShelf' || results.contents[0].type === 'SectionList') {
      rawTracks = results.contents.flatMap(shelf => shelf.contents || []).filter(item => item.type === 'MusicResponsiveListItem' || item.type === 'PlaylistPanelVideo');
    } else {
      rawTracks = results.contents.filter(item => item.type === 'MusicResponsiveListItem' || item.type === 'PlaylistPanelVideo');
    }
  }
  
  if (rawTracks.length > 0) {
    const rawTrack = rawTracks[0];
    const parsed = parseTrack(rawTrack);
    console.log("Parsed result:", parsed);
  }
}

main().catch(console.error);
