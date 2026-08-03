'use strict';

const { resolveStreamUrl: _resolveStream, getInnertube } = require('./stream_resolver');

function parseTrack(song) {
  if (!song || !song.id) return null;
  
  // youtubei.js returns song titles sometimes as strings, sometimes as Text object
  let title = song.title || song.name;
  if (typeof title === 'object' && title.text) {
    title = title.text;
  } else if (typeof title === 'object') {
    title = title.toString();
  }

  const videoId = song.id || song.video_id;
  if (!videoId || !title) return null;

  try {
    let artworkUrl = null;
    let thumbnailUrl = null;
    
    if (song.thumbnails?.length) {
       artworkUrl = song.thumbnails[song.thumbnails.length - 1].url;
       thumbnailUrl = song.thumbnails[0].url;
    } else if (song.thumbnail) {
       artworkUrl = song.thumbnail[0]?.url || song.thumbnail;
       thumbnailUrl = artworkUrl;
    }
      
    if (artworkUrl && typeof artworkUrl === 'string') {
      artworkUrl = artworkUrl.replace(/w\d+-h\d+/, 'w500-h500');
    }

    let artistName = 'Unknown Artist';
    let artistId = null;
    
    if (song.artists && song.artists.length > 0) {
      artistName = song.artists.map(a => a.name).join(', ');
      if (song.artists[0].channel_id) {
         artistId = `youtube_music_artist:${song.artists[0].channel_id}`;
      }
    } else if (song.author) {
      artistName = typeof song.author === 'string' ? song.author : (song.author.name || 'Unknown Artist');
    }

    return {
      id: `youtube_music:${videoId}`,
      title: title,
      artistName: artistName,
      artistId: artistId,
      albumName: song.album?.name || '',
      artworkUrl: artworkUrl,
      thumbnailUrl: thumbnailUrl,
      sourceId: 'youtube_music',
      licenseType: 'CUSTOM',
      attributionString: `${artistName} · YouTube Music`,
      sourceUrl: `https://music.youtube.com/watch?v=${videoId}`,
      durationMs: song.duration?.seconds ? song.duration.seconds * 1000 : 0, 
      playCount: 0,
      offlineAllowed: false,
      streamUrl: null,
      genres: [],
      language: '',
    };
  } catch (e) {
    return null;
  }
}

function getTracksFromResult(res) {
  if (!res) return [];
  if (res.contents && res.contents.length > 0) {
    if (res.contents[0].type === 'MusicShelf' || res.contents[0].type === 'SectionList') {
      return res.contents.flatMap(shelf => shelf.contents || []).filter(item => item.type === 'MusicResponsiveListItem' || item.type === 'PlaylistPanelVideo');
    }
    return res.contents.filter(item => item.type === 'MusicResponsiveListItem' || item.type === 'PlaylistPanelVideo');
  }
  return [];
}

module.exports = {
  sourceId: 'youtube_music',
  displayName: 'YouTube Music',
  isEnabled: true,

  async searchTracks(query, { limit = 20, genre, language } = {}) {
    try {
      const yt = await getInnertube();
      
      let finalQuery = query;
      if (!query && genre) {
          finalQuery = `${genre} top hits`;
      } else if (!query && language) {
          finalQuery = `${language} top hits`;
      }

      const results = await yt.music.search(finalQuery, { type: 'song' });
      const tracks = getTracksFromResult(results);
      return tracks.slice(0, limit).map(parseTrack).filter(Boolean);
    } catch (e) {
      console.error('[YouTube Music] searchTracks error:', e.message);
      return [];
    }
  },

  async trending({ genre, language, limit = 20 } = {}) {
    try {
      const yt = await getInnertube();
      if (genre) {
        const genreMap = {
          'bollywood': 'top bollywood songs',
          'hip-hop': 'top hip hop music',
          'desi hip-hop': 'desi hip hop hits',
          'electronic': 'top edm hits',
          'english': 'top global english pop hits',
          'global pop': 'global pop music',
          'kannada': 'top kannada songs',
          'classical': 'top classical music',
          'rock': 'top rock songs',
          'jazz': 'top jazz songs',
          'punjabi': 'top punjabi hits',
          'ambient': 'relaxing ambient music',
        };
        const query = genreMap[genre.toLowerCase()] || `${genre} hit songs`;
        const results = await yt.music.search(query, { type: 'song' });
        return getTracksFromResult(results).slice(0, limit).map(parseTrack).filter(Boolean);
      }

      const query = language ? `top ${language} songs` : 'global top 50 songs';
      const results = await yt.music.search(query, { type: 'song' });
      return getTracksFromResult(results).slice(0, limit).map(parseTrack).filter(Boolean);
    } catch (e) {
      console.error('[YouTube Music] trending error:', e.message);
      return [];
    }
  },

  async getUpNext(trackId) {
    try {
      const yt = await getInnertube();
      const nativeId = trackId.replace('youtube_music:', '');
      const results = await yt.music.getUpNext(nativeId);
      return getTracksFromResult(results).map(parseTrack).filter(Boolean);
    } catch (e) {
      console.error(`[YouTube Music] getUpNext error for ${trackId}:`, e.message);
      return [];
    }
  },

  async getHomeRecommendations() {
    try {
      const yt = await getInnertube();
      const currentYear = new Date().getFullYear();
      const currentMonth = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'][new Date().getMonth()];
      
      const allSeedTracks = [
        { title: 'Global Pop Mix', videoId: 'XXYlFuWEuKI' },
        { title: 'Bollywood Hits', videoId: '5Eqb_-j3FDA' },
        { videoId: 'dQw4w9WgXcQ', title: 'Pop Classics' },
        { searchQuery: 'lofi hip hop radio', title: 'Lofi & Chill' },
        { searchQuery: 'top hits english', title: 'Top Hits' },
        { searchQuery: 'bollywood trending', title: 'Bollywood Hits' },
        { searchQuery: 'electronic dance music', title: 'EDM Party' },
        { searchQuery: 'acoustic covers', title: 'Acoustic Vibes' },
        { searchQuery: 'indie folk', title: 'Indie Vibes' },
        { searchQuery: 'synthwave mix', title: 'Synthwave' },
        { searchQuery: 'jazz classics', title: 'Jazz Classics' },
        { searchQuery: 'viral hits', title: 'Viral Hits' },
        { searchQuery: 'rap caviar', title: 'Hip Hop & Rap' },
        { searchQuery: 'r&b soul mix', title: 'R&B Classics' },
        { searchQuery: 'workout motivation music', title: 'Workout' },
        { searchQuery: 'sleep ambient', title: 'Sleep & Ambient' },
        { searchQuery: 'kpop trending', title: 'K-Pop Hits' },
        { searchQuery: 'rock anthems', title: 'Rock Anthems' },
        { searchQuery: 'punjabi hits', title: 'Punjabi Hits' },
        { searchQuery: 'telugu hit songs', title: 'Tollywood Hits' },
        { searchQuery: 'spanish pop hits', title: 'Latin Hits' },
        { searchQuery: 'classical masterpieces', title: 'Classical' },
      ];

      // Pick 8 random seed tracks to create 8 shelves
      const selectedSeeds = allSeedTracks.sort(() => 0.5 - Math.random()).slice(0, 8);

      const shelves = await Promise.all(selectedSeeds.map(async (seed) => {
        try {
          let tracks = [];
          if (seed.videoId) {
            const results = await yt.music.getUpNext(seed.videoId);
            tracks = getTracksFromResult(results).slice(0, 10).map(parseTrack).filter(Boolean);
          } else {
            const results = await yt.music.search(seed.searchQuery, { type: 'song' });
            tracks = getTracksFromResult(results).slice(0, 10).map(parseTrack).filter(Boolean);
          }
          if (tracks.length > 0) {
            tracks.sort(() => 0.5 - Math.random());
            return {
              title: seed.title,
              tracks: tracks
            };
          }
        } catch (innerError) {
          console.error(`[YouTube Music] Failed to fetch shelf for ${seed.title}:`, innerError.message);
          return null;
        }
      }));
      return shelves.filter(Boolean);
    } catch (e) {
      console.error('[YouTube Music] getHomeRecommendations error:', e.message);
      return [];
    }
  },

  async getAlbumTracks(albumId) {
    return [];
  },

  async resolveStreamUrl(trackId, options = {}) {
    const nativeId = trackId.replace('youtube_music:', '');
    try {
      return await _resolveStream(nativeId, options.poToken, options.visitorData);
    } catch (e) {
      throw new Error(`[YouTube Music] Failed to resolve stream URL for ${trackId}: ${e.message}`);
    }
  },

  async healthCheck() {
    const yt = await getInnertube();
    const results = await yt.music.search('adele', { type: 'song' });
    if (!results.contents || !results.contents.length) throw new Error('YouTube Music returned no results');
  },
};
