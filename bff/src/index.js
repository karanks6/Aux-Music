'use strict';

require('dotenv').config();

const Fastify = require('fastify');
const cors = require('@fastify/cors');
const rateLimit = require('@fastify/rate-limit');

const audiusAdapter = require('./adapters/audius');
const internetArchiveAdapter = require('./adapters/internet_archive');
const { SourceHealthMonitor } = require('./adapters/health_monitor');

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

const adapters = [audiusAdapter, internetArchiveAdapter];
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
 * GET /stream-url/:source/:trackId
 * Resolves and returns the direct stream URL for a track.
 * The Flutter app calls this just before playback begins.
 */
fastify.get('/stream-url/:source/:trackId', async (request, reply) => {
  const { source, trackId } = request.params;

  const adapter = adapters.find((a) => a.sourceId === source);
  if (!adapter) {
    return reply.status(404).send({ error: `Unknown source: ${source}` });
  }
  if (!healthMonitor.isHealthy(source)) {
    return reply.status(503).send({
      error: `Source "${source}" is temporarily unavailable.`,
    });
  }

  try {
    const url = await adapter.resolveStreamUrl(trackId);
    return { streamUrl: url, sourceId: source, trackId };
  } catch (err) {
    fastify.log.error(err);
    return reply.status(502).send({ error: 'Failed to resolve stream URL.' });
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

const port = parseInt(process.env.PORT || '3000', 10);
const host = process.env.HOST || '0.0.0.0';

fastify.listen({ port, host }, (err) => {
  if (err) {
    fastify.log.error(err);
    process.exit(1);
  }
  fastify.log.info(`Aux BFF running on ${host}:${port}`);
});
