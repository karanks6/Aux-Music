'use strict';

const YTMusic = require('ytmusic-api');
const { resolveStreamUrl: _resolveStream } = require('./stream_resolver');

const ytmusic = new YTMusic();
let isInitialized = false;

// ── Helpers ────────────────────────────────────────────────────────────────

function parseTrack(song) {
  if (!song || (song.type !== 'SONG' && song.type !== 'VIDEO')) return null;
  
  const title = song.name || song.title;
  if (!song.videoId || !title) return null;

  try {
    let artworkUrl = null;
    let thumbnailUrl = null;
    
    if (song.thumbnails?.length) {
       artworkUrl = song.thumbnails[song.thumbnails.length - 1].url;
       thumbnailUrl = song.thumbnails[0].url;
    } else if (song.thumbnail) {
       artworkUrl = song.thumbnail;
       thumbnailUrl = song.thumbnail;
    }
      
    if (artworkUrl) {
      artworkUrl = artworkUrl.replace(/w\d+-h\d+/, 'w500-h500');
    }

    let artistName = 'Unknown Artist';
    let artistId = null;
    
    if (song.artist) {
      artistName = song.artist.name || song.artist;
      artistId = song.artist.artistId ? `youtube_music_artist:${song.artist.artistId}` : null;
    } else if (song.artists) {
      // In getUpNexts, artists is sometimes an array, or a string
      if (Array.isArray(song.artists)) {
         artistName = song.artists.map(a => a.name || a).join(', ');
      } else {
         artistName = typeof song.artists === 'string' ? song.artists : 'Unknown Artist';
      }
    }

    return {
      id: `youtube_music:${song.videoId}`,
      title: title,
      artistName: artistName,
      artistId: artistId,
      albumName: song.album?.name || '',
      artworkUrl: artworkUrl,
      thumbnailUrl: thumbnailUrl,
      sourceId: 'youtube_music',
      licenseType: 'CUSTOM',
      attributionString: `${artistName} · YouTube Music`,
      sourceUrl: `https://music.youtube.com/watch?v=${song.videoId}`,
      durationMs: 0, 
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

async function ensureInitialized() {
  if (!isInitialized) {
    await ytmusic.initialize();
    isInitialized = true;
  }
}

// ── Module exports ─────────────────────────────────────────────────────────

module.exports = {
  sourceId: 'youtube_music',
  displayName: 'YouTube Music',
  isEnabled: true,

  async searchTracks(query, { limit = 20, genre, language } = {}) {
    try {
      await ensureInitialized();
      
      let finalQuery = query;
      // If no query but genre/language exists, it's being used for trending fallback
      if (!query && genre) {
          finalQuery = `${genre} top hits`;
      } else if (!query && language) {
          finalQuery = `${language} top hits`;
      }

      const results = await ytmusic.searchSongs(finalQuery);
      return results.slice(0, limit).map(parseTrack).filter(Boolean);
    } catch (e) {
      console.error('[YouTube Music] searchTracks error:', e.message);
      return [];
    }
  },

  async trending({ genre, language, limit = 20 } = {}) {
    try {
      await ensureInitialized();
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
        const results = await ytmusic.searchSongs(query);
        return results.slice(0, limit).map(parseTrack).filter(Boolean);
      }

      // Default trending if no genre
      const query = language ? `top ${language} songs` : 'global top 50 songs';
      const results = await ytmusic.searchSongs(query);
      return results.slice(0, limit).map(parseTrack).filter(Boolean);
    } catch (e) {
      console.error('[YouTube Music] trending error:', e.message);
      return [];
    }
  },

  async getUpNext(trackId) {
    try {
      await ensureInitialized();
      const nativeId = trackId.replace('youtube_music:', '');
      const results = await ytmusic.getUpNexts(nativeId);
      return results.map(parseTrack).filter(Boolean);
    } catch (e) {
      console.error(`[YouTube Music] getUpNext error for ${trackId}:`, e.message);
      return [];
    }
  },

  async getHomeRecommendations() {
    try {
      await ensureInitialized();
      // We will generate a few personalized / rich shelves based on "seed" tracks.
      // Since unauthenticated getHomeSections() returns mostly RDCL playlists which are hard to parse,
      // we generate "Radio" shelves from popular songs across different genres to simulate it.
      const allSeedTracks = [
        { title: 'Global Pop Mix', videoId: 'XXYlFuWEuKI' },
        { title: 'Bollywood Hits', videoId: '5Eqb_-j3FDA' },
        { title: 'Desi Hip Hop', searchQuery: 'Top Desi Hip Hop songs KRSNA Divine Seedhe Maut' },
        { title: 'Lofi Beats to Relax', videoId: '1fueZCTYkpA' },
        { title: 'Punjabi Fire', videoId: 'VNs_cCtdbPc' },
        { title: 'Electronic Dance', videoId: 'YykjpeuMNEk' },
        { title: 'Rock Classics', videoId: '1w7OgIMMRc4' },
        { title: 'R&B / Soul', videoId: 'fHI8X4OXluQ' },
        { title: 'New Hindi Releases', searchQuery: 'Latest brand new hindi songs bollywood' },
        { title: 'Trending Global', searchQuery: 'Global top songs trending now' },
        { title: 'Indie Vibes', searchQuery: 'Best indie pop acoustic' },
      ];

      // Shuffle categories and pick top 6
      const shuffledSeeds = allSeedTracks.sort(() => 0.5 - Math.random()).slice(0, 6);

      const shelves = [];
      for (const seed of shuffledSeeds) {
        try {
          let tracks = [];
          if (seed.searchQuery) {
            tracks = await ytmusic.searchSongs(seed.searchQuery);
          } else if (seed.videoId) {
            tracks = await ytmusic.getUpNexts(seed.videoId);
          }
          if (tracks && tracks.length > 0) {
            let parsedTracks = tracks.map(parseTrack).filter(Boolean);
            // Shuffle the tracks inside the shelf to keep it fresh
            parsedTracks = parsedTracks.sort(() => 0.5 - Math.random());
            
            shelves.push({
              title: seed.title,
              tracks: parsedTracks
            });
          }
        } catch (innerError) {
          console.error(`[YouTube Music] Failed to fetch shelf for ${seed.title}:`, innerError.message);
        }
      }
      return shelves;
    } catch (e) {
      console.error('[YouTube Music] getHomeRecommendations error:', e.message);
      return [];
    }
  },

  async getAlbumTracks(albumId) {
    // ytmusic-api does not have a direct getAlbumTracks exposed easily without playlist ID
    return [];
  },

  async resolveStreamUrl(trackId) {
    const nativeId = trackId.replace('youtube_music:', '');
    try {
      return await _resolveStream(nativeId);
    } catch (e) {
      throw new Error(`[YouTube Music] Failed to resolve stream URL for ${trackId}: ${e.message}`);
    }
  },

  async healthCheck() {
    await ensureInitialized();
    const results = await ytmusic.searchSongs('adele');
    if (!results.length) throw new Error('YouTube Music returned no results');
  },
};

// Eager initialization to prevent initial timeout
ensureInitialized().catch(e => console.error('[YouTube Music] Failed to eager initialize:', e.message));
