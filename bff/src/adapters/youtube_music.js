'use strict';

const YTMusic = require('ytmusic-api');
const youtubedl = require('youtube-dl-exec');
const ytdl = require('@distube/ytdl-core');

const ytmusic = new YTMusic();
let isInitialized = false;

// ── Helpers ────────────────────────────────────────────────────────────────

function parseTrack(song) {
  if (!song || song.type !== 'SONG' && song.type !== 'VIDEO') return null;
  if (!song.videoId || !song.name || !song.artist) return null;

  try {
    let artworkUrl = song.thumbnails?.length
      ? song.thumbnails[song.thumbnails.length - 1].url
      : null;
      
    if (artworkUrl) {
      artworkUrl = artworkUrl.replace(/w\d+-h\d+/, 'w500-h500');
    }

    return {
      id: `youtube_music:${song.videoId}`,
      title: song.name,
      artistName: song.artist.name,
      artistId: song.artist.artistId ? `youtube_music_artist:${song.artist.artistId}` : null,
      albumName: song.album?.name || '',
      artworkUrl: artworkUrl,
      thumbnailUrl: song.thumbnails?.[0]?.url || null,
      sourceId: 'youtube_music',
      licenseType: 'CUSTOM',
      attributionString: `${song.artist.name} · YouTube Music`,
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

  async getAlbumTracks(albumId) {
    // ytmusic-api does not have a direct getAlbumTracks exposed easily without playlist ID
    return [];
  },

  async resolveStreamUrl(trackId) {
    const nativeId = trackId.replace('youtube_music:', '');
    
    // Try ytdl-core first as it might bypass BotGuard better than yt-dlp on Datacenter IPs
    try {
      const info = await ytdl.getInfo(nativeId);
      const format = ytdl.chooseFormat(info.formats, { quality: 'highestaudio' });
      if (format && format.url) {
        return format.url;
      }
    } catch (err) {
      console.warn(`[YouTube Music] ytdl-core failed for ${nativeId}:`, err.message);
    }

    // Fallback to yt-dlp
    try {
      const url = `https://www.youtube.com/watch?v=${nativeId}`;
      const output = await youtubedl(url, {
        dumpJson: true,
        noWarnings: true,
        noCheckCertificate: true,
        preferFreeFormats: true,
        format: 'm4a/bestaudio/best',
        extractorArgs: 'youtube:player-client=ios'
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
