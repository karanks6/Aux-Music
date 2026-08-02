'use strict';

const { Innertube, Platform } = require('youtubei.js');

// Wire Node.js Function constructor as the JS evaluator for deciphering
// This is required by youtubei.js to decipher YouTube's obfuscated stream URLs
Platform.shim.eval = async (data) => {
  return new Function(data.output)();
};

let _ytInstance = null;

async function getInnertube() {
  if (!_ytInstance) {
    _ytInstance = await Innertube.create({
      generate_session_locally: true,
      retrieve_player: true,
    });
  }
  return _ytInstance;
}

/**
 * Resolves a YouTube video ID to a direct, streamable audio URL.
 * Uses youtubei.js (pure JS) — no binary dependencies, mobile-safe.
 *
 * @param {string} videoId - Raw YouTube video ID (e.g. "dQw4w9WgXcQ")
 * @returns {Promise<string>} - A direct HTTPS audio stream URL
 */
async function resolveStreamUrl(videoId) {
  const yt = await getInnertube();
  const info = await yt.music.getInfo(videoId);
  const streamingData = info.streaming_data;

  if (!streamingData) {
    throw new Error(`[StreamResolver] No streaming data for ${videoId}`);
  }

  // Prefer m4a (audio/mp4) for maximum device compatibility
  // Fall back to webm/opus if m4a not available
  const audioFormats = (streamingData.adaptive_formats || [])
    .filter(f => f.mime_type?.startsWith('audio/'))
    .sort((a, b) => {
      // Prefer mp4/m4a over webm for broader device support
      const aScore = a.mime_type?.includes('mp4') ? 1000 : 0;
      const bScore = b.mime_type?.includes('mp4') ? 1000 : 0;
      return (bScore + (b.bitrate || 0)) - (aScore + (a.bitrate || 0));
    });

  if (audioFormats.length === 0) {
    throw new Error(`[StreamResolver] No audio formats found for ${videoId}`);
  }

  const best = audioFormats[0];
  console.log(`[StreamResolver] ${videoId}: ${best.mime_type}, ${best.bitrate}bps`);

  // URL may be direct or cipher-protected
  if (best.url) {
    return best.url;
  }

  const url = await best.decipher(yt.session.player);
  if (!url || !url.startsWith('https://')) {
    throw new Error(`[StreamResolver] Decipher failed for ${videoId}`);
  }
  return url;
}

module.exports = { resolveStreamUrl };
