'use strict';

/**
 * Server-side YouTube poToken generator.
 * The token is cached for ~5 minutes and auto-refreshed in the background.
 */

let _cachedToken = null;
let _cacheTime = 0;
const CACHE_TTL_MS = 5 * 60 * 1000; // 5 minutes

let _generatingPromise = null;

async function generatePoToken() {
  const { generate } = require('youtube-po-token-generator');
  console.log('[PoTokenGen] Generating poToken via youtube-po-token-generator...');
  const result = await generate();
  console.log('[PoTokenGen] poToken generated successfully!');
  return result;
}

/**
 * Get a valid (cached) poToken. Will regenerate if expired.
 * @returns {{ poToken: string, visitorData: string }}
 */
async function getCachedPoToken() {
  const now = Date.now();

  // Return cached token if still valid
  if (_cachedToken && (now - _cacheTime) < CACHE_TTL_MS) {
    return _cachedToken;
  }

  // If already generating, wait for that promise
  if (_generatingPromise) {
    try { return await _generatingPromise; } catch (_) {}
  }

  // Generate a new token
  _generatingPromise = generatePoToken().then(token => {
    _cachedToken = token;
    _cacheTime = Date.now();
    _generatingPromise = null;
    console.log('[PoTokenGen] Token cached.');
    return token;
  }).catch(err => {
    _generatingPromise = null;
    console.error('[PoTokenGen] Token generation failed:', err.message);
    // Return the old cached token if available, even if expired
    if (_cachedToken) {
      console.warn('[PoTokenGen] Using expired cached token as fallback.');
      return _cachedToken;
    }
    return { poToken: '', visitorData: '' };
  });

  return _generatingPromise;
}

// Pre-warm the token on startup
getCachedPoToken().catch(() => {});

module.exports = { getCachedPoToken };
