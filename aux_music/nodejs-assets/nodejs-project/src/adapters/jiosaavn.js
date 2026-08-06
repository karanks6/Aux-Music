'use strict';

const axios = require('axios');

/**
 * JioSaavn BFF adapter.
 *
 * Uses JioSaavn's internal (reverse-engineered) endpoints — the same ones
 * used by the well-known open-source "jiosaavn-api" project.
 *
 * For personal / educational use only. Not affiliated with JioSaavn / Reliance.
 */

const BASE_URL = 'https://www.jiosaavn.com/api.php';
const CDN_BASE = 'https://aac.saavncdn.com';

const HEADERS = {
  'User-Agent':
    'Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36 Chrome/120.0.0.0 Mobile Safari/537.36',
  Accept: 'application/json',
};

const des = require('des.js');

// ── Helpers ────────────────────────────────────────────────────────────────

/**
 * Decodes the obfuscated JioSaavn media URL.
 * JioSaavn uses DES in ECB mode to encrypt the CDN URL.
 */
function decodeMediaUrl(encodedUrl) {
  if (!encodedUrl) return null;
  try {
    const key = Buffer.from('38346591');
    const decipher = des.DES.create({
      type: 'decrypt',
      key: key,
      mode: 'ecb'
    });

    const encryptedBuffer = Buffer.from(encodedUrl, 'base64');
    let decryptedBuf = Buffer.from(decipher.update(encryptedBuffer));
    decryptedBuf = Buffer.concat([decryptedBuf, Buffer.from(decipher.final())]);
    
    let decrypted = decryptedBuf.toString('utf-8');

    // Remove padding characters and replace domain
    let url = decrypted
      .replace(/\0/g, '')
      .trim()
      .replace(/&amp;/g, '&')
      .replace(/https?:\/\/[^/]*(aac\.saavncdn\.com|c\.saavncdn\.com)/, CDN_BASE);

    // Try upgrading to 320kbps
    if (url.includes('_96.mp4')) url = url.replace('_96.mp4', '_320.mp4');
    if (url.includes('_160.mp4')) url = url.replace('_160.mp4', '_320.mp4');
    if (url.includes('_128.mp4')) url = url.replace('_128.mp4', '_320.mp4');

    return url;
  } catch (e) {
    // If it fails, maybe it wasn't encrypted (e.g. media_preview_url)
    let url = encodedUrl
      .replace(/&amp;/g, '&')
      .replace(/https?:\/\/[^/]*(aac\.saavncdn\.com|c\.saavncdn\.com)/, CDN_BASE);
    
    if (url.includes('_96.mp4')) url = url.replace('_96.mp4', '_320.mp4');
    return url;
  }
}

async function apiGet(params) {
  const response = await axios.get(BASE_URL, {
    params: {
      ...params,
      _format: 'json',
      _marker: '0',
      api_version: '4',
      ctx: 'web6dot0',
    },
    headers: HEADERS,
    timeout: 8000,
  });
  return response.data;
}

function parseTrack(song) {
  if (!song || !song.id) return null;
  try {
    const mediaUrl = decodeMediaUrl(song.media_preview_url || song.more_info?.encrypted_media_url);
    if (!mediaUrl) return null;

    const artistName =
      song.more_info?.singers ||
      song.primary_artists ||
      song.subtitle ||
      'Unknown Artist';

    const artworkUrl =
      (song.image || '').replace('150x150', '500x500').replace('50x50', '500x500') ||
      null;

    const durationMs = parseInt(song.more_info?.duration || song.duration || '0', 10) * 1000;

    return {
      id: `jiosaavn:${song.id}`,
      title: (song.title || song.song || '').replace(/&amp;/g, '&').replace(/&#039;/g, "'").replace(/&quot;/g, '"'),
      artistName: artistName.replace(/&amp;/g, '&').replace(/&#039;/g, "'").replace(/&quot;/g, '"'),
      artistId: `jiosaavn_artist:${song.more_info?.artistid || ''}`,
      albumName: (song.more_info?.album || '').replace(/&amp;/g, '&').replace(/&quot;/g, '"'),
      artworkUrl,
      thumbnailUrl: song.image ? song.image.replace('150x150', '150x150') : null,
      sourceId: 'jiosaavn',
      licenseType: 'CUSTOM',
      attributionString: `${artistName} · JioSaavn`,
      sourceUrl: `https://www.jiosaavn.com/song/${song.title}/${song.id}`,
      durationMs: isNaN(durationMs) ? 0 : durationMs,
      playCount: parseInt(song.play_count || '0', 10) || 0,
      offlineAllowed: false, // Commercial music — no offline
      streamUrl: mediaUrl,
      genres: song.more_info?.language ? [song.more_info.language] : [],
      language: song.more_info?.language || 'hi',
    };
  } catch (e) {
    return null;
  }
}

// ── Module exports ─────────────────────────────────────────────────────────

module.exports = {
  sourceId: 'jiosaavn',
  displayName: 'JioSaavn',
  isEnabled: true,

  /**
   * Search songs by query.
   */
  async searchTracks(query, { limit = 20, language } = {}) {
    try {
      const data = await apiGet({
        __call: 'search.getResults',
        q: query,
        p: 1,
        n: limit,
      });

      const results = data?.results || data?.data?.results || [];
      return results.map(parseTrack).filter(Boolean);
    } catch (e) {
      console.error('[JioSaavn] searchTracks error:', e.message);
      return [];
    }
  },

  /**
   * Get trending / new releases by language.
   * Falls back to searching for top charts if no trending endpoint is available.
   */
  async trending({ genre, language, limit = 20 } = {}) {
    try {
      if (genre) {
        const genreMap = {
          'bollywood': 'latest bollywood hits',
          'hip-hop': 'hip hop top hits',
          'desi hip-hop': 'desi hip hop',
          'electronic': 'edm top hits',
          'english': 'latest english pop hits',
          'global pop': 'global pop hits',
          'kannada': 'kannada hit songs',
          'classical': 'classical hit songs',
          'rock': 'rock hits',
          'jazz': 'jazz hits',
          'punjabi': 'latest punjabi hits',
          'ambient': 'ambient relaxing music',
        };
        const query = genreMap[genre.toLowerCase()] || `${genre} hits`;
        return this.searchTracks(query, { limit }).catch(() => []);
      }

      // Map language to JioSaavn language codes
      const langMap = {
        hindi: 'hindi',
        english: 'english',
        kannada: 'kannada',
        tulu: 'kannada', // Tulu content is often under Kannada category in JioSaavn
        tamil: 'tamil',
        telugu: 'telugu',
        punjabi: 'punjabi',
        marathi: 'marathi',
        bengali: 'bengali',
      };

      const saavnLang = (language && langMap[language.toLowerCase()]) || 'hindi';

      // Use the new releases / editorial charts endpoint
      const data = await apiGet({
        __call: 'content.getAlbums',
        p: 1,
        n: limit,
        language: saavnLang,
      });

      const albums = data?.data || data?.results || [];
      const trackPromises = albums.slice(0, 5).map((album) =>
        this.getAlbumTracks(album.id).catch(() => [])
      );
      const trackArrays = await Promise.all(trackPromises);
      const tracks = trackArrays.flat().slice(0, limit);
      if (tracks.length > 0) return tracks;

      // Fallback: search popular songs in that language
      const query = saavnLang === 'hindi' ? 'new hindi songs 2024' :
                    saavnLang === 'kannada' ? 'new kannada songs 2024' :
                    saavnLang === 'tamil' ? 'new tamil songs 2024' :
                    saavnLang === 'telugu' ? 'new telugu songs 2024' :
                    saavnLang === 'punjabi' ? 'new punjabi songs 2024' :
                    'new songs 2024';
      return this.searchTracks(query, { limit });
    } catch (e) {
      console.error('[JioSaavn] trending error:', e.message);
      // Fallback to searching
      const query = language ? `new ${language} hit songs` : 'new hindi hit songs';
      return this.searchTracks(query, { limit }).catch(() => []);
    }
  },

  /**
   * Get all tracks in an album.
   */
  async getAlbumTracks(albumId) {
    try {
      const data = await apiGet({
        __call: 'content.getAlbumDetails',
        albumid: albumId,
      });
      const songs = data?.songs || data?.list || [];
      return songs.map(parseTrack).filter(Boolean);
    } catch {
      return [];
    }
  },

  /**
   * Resolve a stream URL for a given track ID.
   * The streamUrl is already embedded in the track object, but this
   * method re-fetches it in case it expired.
   */
  async resolveStreamUrl(trackId) {
    const nativeId = trackId.replace('jiosaavn:', '');
    try {
      const data = await apiGet({
        __call: 'song.getDetails',
        pids: nativeId,
      });
      const song = data?.songs?.[0] || data?.[nativeId] || Object.values(data || {})[0];
      if (!song || Array.isArray(song)) {
         // Fallback if it returned an array in the object values
         const actualSong = Array.isArray(song) ? song[0] : song;
         if (!actualSong) throw new Error('Song not found');
         const url = decodeMediaUrl(
           actualSong.more_info?.encrypted_media_url || actualSong.media_preview_url
         );
         if (!url) throw new Error('No stream URL in response');
         return url;
      }
      if (!song) throw new Error('Song not found');
      const url = decodeMediaUrl(
        song.more_info?.encrypted_media_url || song.media_preview_url
      );
      if (!url) throw new Error('No stream URL in response');
      return url;
    } catch (e) {
      throw new Error(`[JioSaavn] Failed to resolve stream URL for ${trackId}: ${e.message}`);
    }
  },

  async healthCheck() {
    const results = await this.searchTracks('arijit singh', { limit: 1 });
    if (!results.length) throw new Error('JioSaavn returned no results');
  },
};
