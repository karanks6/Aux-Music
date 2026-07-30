'use strict';

const YTMusic = require('ytmusic-api');
const youtubedl = require('youtube-dl-exec');
const ytdl = require('@distube/ytdl-core');

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
      const seedTracks = [
        { title: 'Global Pop Mix', videoId: 'XXYlFuWEuKI' }, // The Weeknd
        { title: 'Bollywood Radio', videoId: '5Eqb_-j3FDA' }, // Arijit Singh
        { title: 'Desi Hip-Hop Radio', videoId: 'Ukm86tCq1Gk' }, // AP Dhillon
        { title: 'Punjabi Fire', videoId: '9M4yE3-L7X8' }, // Diljit Dosanjh
        { title: 'Electronic Dance', videoId: 'YykjpeuMNEk' } // Coldplay
      ];

      const shelves = [];
      for (const seed of seedTracks) {
        try {
          const upNexts = await ytmusic.getUpNexts(seed.videoId);
          if (upNexts && upNexts.length > 0) {
            shelves.push({
              title: seed.title,
              tracks: upNexts.map(parseTrack).filter(Boolean)
            });
          }
        } catch (innerError) {
          console.error(`[YouTube Music] Failed to fetch UpNext for seed ${seed.videoId}:`, innerError.message);
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
    
    // Removed ytdl-core since it generates TVHTML5 URLs which get blocked by BotGuard when used with Android User-Agent

    // Fallback to yt-dlp
    try {
      const url = `https://www.youtube.com/watch?v=${nativeId}`;
      const output = await youtubedl(url, {
        dumpJson: true,
        noWarnings: true,
        noCheckCertificate: true,
        preferFreeFormats: true,
        format: 'm4a/bestaudio/best',
        extractorArgs: 'youtube:client=android'
      });
      
      if (!output || !output.url) {
        throw new Error('No stream URL found in youtube-dl response');
      }
      
      return output.url;
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
