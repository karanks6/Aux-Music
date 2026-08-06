'use strict';

require('dotenv').config();

// Polyfill Intl for Android nodejs-mobile engine (which lacks ICU)
if (typeof global.Intl === 'undefined') {
  global.Intl = require('intl');
}

process.env.NODE_TLS_REJECT_UNAUTHORIZED = '0';

const dns = require('dns');
// Android 11+ restricts reading net.dns1 property, which breaks Node's c-ares DNS resolver.
// Hardcode public DNS servers to fix ENOTFOUND and 'fetch failed' errors on Android.
try {
  dns.setServers(['8.8.8.8', '1.1.1.1', '8.8.4.4']);
  
  // Override dns.lookup because axios/http module uses getaddrinfo by default,
  // which ignores dns.setServers and fails on Android 11+ inside nodejs-mobile.
  const originalLookup = dns.lookup;
  dns.lookup = function(hostname, options, callback) {
    if (typeof options === 'function') {
      callback = options;
      options = {};
    }
    dns.resolve4(hostname, (err, addresses) => {
      if (err) {
        return originalLookup(hostname, options, callback);
      }
      if (options && options.all) {
        callback(null, addresses.map(a => ({ address: a, family: 4 })));
      } else {
        callback(null, addresses[0], 4);
      }
    });
  };
} catch(e) {
  console.error("Failed to set DNS servers:", e);
}

const Fastify = require('fastify');
const cors = require('@fastify/cors');
const rateLimit = require('@fastify/rate-limit');

// Adapters removed
const youtubeMusicAdapter = require('./adapters/youtube_music');
const jiosaavnAdapter = require('./adapters/jiosaavn');
const { SourceHealthMonitor } = require('./adapters/health_monitor');
const axios = require('axios');

// ── Server setup ──────────────────────────────────────────────────────

const fastify = Fastify({
  logger: {
    level: process.env.LOG_LEVEL || 'info',
  },
});

// CORS — Flutter app will call from any origin during dev
fastify.register(cors, {
  origin: true,
  methods: ['GET', 'POST', 'OPTIONS'],
});

// Rate limiting — protect the free Render instance
fastify.register(rateLimit, {
  max: 100,
  timeWindow: '1 minute',
  errorResponseBuilder: () => ({
    error: 'Too many requests. Please slow down.',
    code: 'RATE_LIMITED',
  }),
});

// ── Health monitor (runs every 5 minutes) ─────────────────────────────

const adapters = [youtubeMusicAdapter, jiosaavnAdapter];
const healthMonitor = new SourceHealthMonitor(adapters);
healthMonitor.start();

// ── Routes ────────────────────────────────────────────────────────────

/**
 * GET /health
 * Quick health check — used by Flutter app keepalive ping to reduce cold starts.
 */
fastify.get('/health', async (request, reply) => {
  return {
    status: 'ok',
    timestamp: new Date().toISOString(),
    sources: healthMonitor.getStatuses(),
  };
});

/**
 * GET /trending?genre=&language=&limit=20
 * Returns trending tracks from all healthy adapters, merged and deduplicated.
 */
fastify.get('/trending', async (request, reply) => {
  const { genre, language, limit = '20' } = request.query;
  const limitNum = Math.min(parseInt(limit, 10) || 20, 50);

  const healthyAdapters = adapters.filter((a) => a.isEnabled && healthMonitor.isHealthy(a.sourceId));

  const results = await Promise.allSettled(
    healthyAdapters.map((a) =>
      a.trending({ genre, language, limit: limitNum }).catch(() => [])
    )
  );

  const tracks = results
    .filter((r) => r.status === 'fulfilled')
    .flatMap((r) => r.value);

  return { data: deduplicateTracks(tracks), count: tracks.length };
});

/**
 * GET /search?q=&genre=&language=&limit=20
 * Fans out search to all healthy adapters, returns merged + deduplicated results.
 */
fastify.get('/search', async (request, reply) => {
  const { q, genre, language, limit = '20' } = request.query;

  if (!q || q.trim().length < 1) {
    return reply.status(400).send({ error: 'Query parameter "q" is required.' });
  }

  const limitNum = Math.min(parseInt(limit, 10) || 20, 50);
  const healthyAdapters = adapters.filter((a) => a.isEnabled && healthMonitor.isHealthy(a.sourceId));

  const results = await Promise.allSettled(
    healthyAdapters.map((a) =>
      a.searchTracks(q.trim(), { genre, language, limit: limitNum }).catch(() => [])
    )
  );

  const tracks = results
    .filter((r) => r.status === 'fulfilled')
    .flatMap((r) => r.value);

  return { data: deduplicateTracks(tracks), count: tracks.length };
});

/**
 * GET /recommendations/home
 * Returns personalized / curated shelves (like "Radio") using YouTube Music's UpNext algorithm.
 */
fastify.get('/recommendations/home', async (request, reply) => {
  try {
    const shelves = await youtubeMusicAdapter.getHomeRecommendations();
    return { data: shelves };
  } catch (err) {
    fastify.log.error(err);
    return reply.status(502).send({ error: 'Failed to fetch home recommendations.' });
  }
});

/**
 * GET /recommendations/upnext/:videoId
 * Returns an infinite radio / up-next queue for a given video ID.
 */
fastify.get('/recommendations/upnext/:videoId', async (request, reply) => {
  const { videoId } = request.params;
  try {
    const tracks = await youtubeMusicAdapter.getUpNext(videoId);
    return { data: deduplicateTracks(tracks), count: tracks.length };
  } catch (err) {
    fastify.log.error(err);
    return reply.status(502).send({ error: 'Failed to fetch up-next recommendations.' });
  }
});

/**
 * GET /stream-url/:source/:trackId
 * Resolves and returns the direct stream URL for a track.
 * The Flutter app calls this just before playback begins.
 */
fastify.get('/stream-url/:source/:trackId', async (request, reply) => {
  const { source, trackId } = request.params;
  const { poToken, visitorData } = request.query;

  const adapter = adapters.find((a) => a.sourceId === source);
  if (!adapter) {
    return reply.status(404).send({ error: `Unknown source: ${source}` });
  }

  try {
    const url = await adapter.resolveStreamUrl(trackId, { poToken, visitorData });
    return { streamUrl: url, sourceId: source, trackId };
  } catch (err) {
    fastify.log.error(err);
    return reply.status(502).send({ error: 'Failed to resolve stream URL.' });
  }
});

/**
 * GET /proxy-stream/:source/:trackId
 * Streams the actual audio data from the resolved URL.
 * Bypasses YouTube's IP-binding restrictions by fetching from the backend's IP.
 */
fastify.get('/proxy-stream/:source/:trackId', async (request, reply) => {
  const { source, trackId } = request.params;
  const { poToken, visitorData } = request.query;

  const adapter = adapters.find((a) => a.sourceId === source);
  if (!adapter) {
    return reply.status(404).send({ error: `Unknown source: ${source}` });
  }

  try {
    let url;
    let response;
    let reqMethod = request.method.toLowerCase();
    
    let headers = {
      'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
    };
    if (request.headers.range) {
      headers['Range'] = request.headers.range;
    }

    try {
      url = await adapter.resolveStreamUrl(trackId, { poToken, visitorData });
      response = await axios({
        method: reqMethod,
        url: url,
        responseType: 'stream',
        headers: headers,
        validateStatus: () => true // Allow all statuses so we can forward 206 Partial Content
      });
    } catch (resolveErr) {
      // If resolving the stream URL throws (e.g. BotGuard decipher failure)
      if (source === 'youtube_music') {
        response = { status: 403 }; // Force fallback
      } else {
        throw resolveErr;
      }
    }

    // YouTube BotGuard Fallback: if 403 Forbidden or decipher failed, fallback to JioSaavn
    if (response && response.status === 403 && source === 'youtube_music') {
       fastify.log.warn(`[YouTube Music] 403 Forbidden (or decipher failed) for ${trackId}. Attempting JioSaavn fallback...`);
       try {
         let fallbackTitle = request.query.title;
         let fallbackArtist = request.query.artist;
         
         if (!fallbackTitle) {
           const trackInfo = await adapter.getTrackInfo(trackId);
           fallbackTitle = trackInfo.title;
           fallbackArtist = trackInfo.artistName;
         }
         
         const jiosaavn = adapters.find((a) => a.sourceId === 'jiosaavn');
         if (jiosaavn) {
            const results = await jiosaavn.searchTracks(`${fallbackTitle} ${fallbackArtist || ''}`, { limit: 1 });
            if (results && results.length > 0) {
               url = await jiosaavn.resolveStreamUrl(results[0].id);
               response = await axios({
                 method: reqMethod,
                 url: url,
                 responseType: 'stream',
                 headers: headers,
                 validateStatus: () => true
               });
               fastify.log.info(`[JioSaavn Fallback] Successfully fetched stream for ${trackId}`);
            } else {
               fastify.log.warn(`[JioSaavn Fallback] Track not found on JioSaavn: ${fallbackTitle}`);
               response = { status: 502, data: { error: 'JioSaavn fallback failed: Track not found', headers: {} } };
            }
         }
       } catch (fallbackErr) {
         fastify.log.error(`[JioSaavn Fallback] Failed for ${trackId}: ${fallbackErr.message}`);
         response = { status: 502, data: { error: `JioSaavn fallback failed: ${fallbackErr.message}`, headers: {} } };
       }
    }

    if (!response) {
      return reply.status(502).send({ error: 'Failed to resolve stream URL and fallback failed.' });
    }

    reply.status(response.status);
    if (response.headers && response.headers['content-type']) reply.header('Content-Type', response.headers['content-type']);
    if (response.headers && response.headers['content-length']) reply.header('Content-Length', response.headers['content-length']);
    if (response.headers && response.headers['content-range']) reply.header('Content-Range', response.headers['content-range']);
    reply.header('Accept-Ranges', 'bytes');
    
    return reply.send(response.data);
  } catch (err) {
    fastify.log.error(err);
    return reply.status(502).send({ error: 'Failed to proxy stream data.' });
  }
});

/**
 * GET /sources/health
 * Returns per-source health status for the Settings screen.
 */
fastify.get('/sources/health', async () => {
  return { sources: healthMonitor.getStatuses() };
});

// ── Fuzzy deduplication ───────────────────────────────────────────────

function normalizeKey(str) {
  return str
    .toLowerCase()
    .replace(/[^\w\s]/g, '')
    .replace(/\s+/g, ' ')
    .trim();
}

function jaccardSimilarity(a, b) {
  const wordsA = new Set(a.split(' '));
  const wordsB = new Set(b.split(' '));
  const intersection = [...wordsA].filter((w) => wordsB.has(w)).length;
  const union = new Set([...wordsA, ...wordsB]).size;
  return union === 0 ? 0 : intersection / union;
}

function deduplicateTracks(tracks) {
  const seen = [];
  const result = [];
  for (const track of tracks) {
    const key = normalizeKey(`${track.title} ${track.artistName}`);
    const isDuplicate = seen.some((k) => jaccardSimilarity(k, key) > 0.8);
    if (!isDuplicate) {
      seen.push(key);
      result.push(track);
    }
  }
  return result;
}

// ── Start ─────────────────────────────────────────────────────────────

// When running embedded on device, always bind to localhost only for security.
// HOST env var can override for development PC usage.
const port = parseInt(process.env.PORT || '3000', 10);
const host = process.env.HOST || '0.0.0.0';

fastify.listen({ port, host }, (err) => {
  if (err) {
    fastify.log.error(err);
    process.exit(1);
  }
  fastify.log.info(`Aux BFF running on ${host}:${port}`);
});
