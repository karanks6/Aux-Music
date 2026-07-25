'use strict';

const axios = require('axios');

const FALLBACK_NODES = [
  'https://discoveryprovider.audius.co',
  'https://discoveryprovider2.audius.co',
  'https://discoveryprovider3.audius.co',
];
const REGISTRY_URL = 'https://api.audius.co';
const APP_NAME = 'AuxMusic';

let nodes = [...FALLBACK_NODES];
let currentNodeIndex = 0;

// Discover healthy nodes at startup
async function discoverNodes() {
  try {
    const res = await axios.get(REGISTRY_URL, { timeout: 3000 });
    if (res.data?.data?.length) {
      nodes = res.data.data.filter((url) => url.startsWith('https://'));
      currentNodeIndex = 0;
    }
  } catch {
    // Use fallback nodes
  }
}
discoverNodes();

function getBaseUrl() {
  return nodes[currentNodeIndex];
}

function rotateNode() {
  currentNodeIndex = (currentNodeIndex + 1) % nodes.length;
}

async function apiGet(path, params = {}) {
  let attempts = 0;
  while (attempts < nodes.length) {
    try {
      const res = await axios.get(`${getBaseUrl()}${path}`, {
        params: { ...params, app_name: APP_NAME },
        timeout: 8000,
        headers: { 'User-Agent': 'AuxMusic/1.0 (https://auxmusic.app)' },
      });
      return res.data;
    } catch (err) {
      if (!err.response || err.response.status >= 500) {
        rotateNode();
        attempts++;
      } else {
        throw err;
      }
    }
  }
  throw new Error('All Audius nodes exhausted');
}

function parseLicense(item) {
  const license = (item.license || '').toLowerCase();
  if (license.includes('all rights reserved') || license.includes('arr')) return null; // skip
  if (license.includes('cc0') || license.includes('zero')) return { type: 'CC0', label: 'CC0' };
  if (license.includes('by-nc-sa')) return { type: 'CC-BY-NC-SA', label: 'CC BY-NC-SA' };
  if (license.includes('by-nc-nd')) return { type: 'CC-BY-NC-ND', label: 'CC BY-NC-ND' };
  if (license.includes('by-nc')) return { type: 'CC-BY-NC', label: 'CC BY-NC' };
  if (license.includes('by-sa')) return { type: 'CC-BY-SA', label: 'CC BY-SA' };
  if (license.includes('by-nd')) return { type: 'CC-BY-ND', label: 'CC BY-ND' };
  if (license.includes('by')) return { type: 'CC-BY', label: 'CC BY' };
  // Audius default — independent artist, treated as CC BY
  return { type: 'CC-BY', label: 'CC BY' };
}

function parseTrack(item) {
  const license = parseLicense(item);
  if (!license) return null; // All Rights Reserved — skip

  const artistName = item.user?.name || 'Unknown Artist';
  const artwork = item.artwork || {};
  return {
    id: `audius:${item.id}`,
    title: item.title || '',
    artistName,
    artistId: `audius:${item.user?.id || ''}`,
    artworkUrl: artwork['1000x1000'] || artwork['480x480'] || null,
    thumbnailUrl: artwork['150x150'] || null,
    sourceId: 'audius',
    licenseType: license.type,
    attributionString: `${artistName} via Audius · ${license.label}`,
    sourceUrl: `https://audius.co/tracks/${item.id}`,
    durationMs: (item.duration || 0) * 1000,
    playCount: item.play_count || 0,
    offlineAllowed: item.downloadable || true,
    genres: item.genre ? [item.genre] : [],
    tags: (item.tags || '').split(',').map((t) => t.trim()).filter(Boolean),
  };
}

module.exports = {
  sourceId: 'audius',
  displayName: 'Audius',
  isEnabled: true,

  async trending({ genre, limit = 20 } = {}) {
    const params = { limit };
    if (genre) params.genre = genre;
    const data = await apiGet('/v1/tracks/trending', params);
    return (data?.data || []).map(parseTrack).filter(Boolean);
  },

  async searchTracks(query, { limit = 20 } = {}) {
    const data = await apiGet('/v1/tracks/search', { query, limit });
    return (data?.data || []).map(parseTrack).filter(Boolean);
  },

  async resolveStreamUrl(trackId) {
    const nativeId = trackId.replace('audius:', '');
    return `${getBaseUrl()}/v1/tracks/${nativeId}/stream?app_name=${APP_NAME}`;
  },

  async healthCheck() {
    await apiGet('/v1/tracks/trending', { limit: 1 });
  },
};
