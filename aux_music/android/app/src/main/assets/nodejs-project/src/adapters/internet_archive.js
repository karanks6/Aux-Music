'use strict';

const axios = require('axios');

const SEARCH_URL = 'https://archive.org/advancedsearch.php';
const BASE_URL = 'https://archive.org';
let lastRequestTime = 0;
const RATE_LIMIT_MS = 350; // ~3 req/sec

function parseLicenseFromUrl(url) {
  if (!url) return null;
  const u = url.toLowerCase();
  if (u.includes('zero') || u.includes('cc0')) return { type: 'CC0', label: 'CC0' };
  if (u.includes('by-nc-sa')) return { type: 'CC-BY-NC-SA', label: 'CC BY-NC-SA' };
  if (u.includes('by-nc-nd')) return { type: 'CC-BY-NC-ND', label: 'CC BY-NC-ND' };
  if (u.includes('by-nc')) return { type: 'CC-BY-NC', label: 'CC BY-NC' };
  if (u.includes('by-sa')) return { type: 'CC-BY-SA', label: 'CC BY-SA' };
  if (u.includes('by-nd')) return { type: 'CC-BY-ND', label: 'CC BY-ND' };
  if (u.includes('/by')) return { type: 'CC-BY', label: 'CC BY' };
  if (u.includes('publicdomain') || u.includes('public_domain')) return { type: 'PUBLIC_DOMAIN', label: 'Public Domain' };
  return null;
}

async function rateLimitedGet(url, params) {
  const now = Date.now();
  const wait = RATE_LIMIT_MS - (now - lastRequestTime);
  if (wait > 0) await new Promise((r) => setTimeout(r, wait));
  lastRequestTime = Date.now();
  return axios.get(url, {
    params,
    timeout: 10000,
    headers: { 'User-Agent': 'AuxMusic/1.0 (https://auxmusic.app)' },
  });
}

function itemToTrack(item) {
  const license = parseLicenseFromUrl(item.licenseurl);
  if (!license) return null;
  const creator = item.creator || 'Unknown Artist';
  return {
    id: `internet_archive:${item.identifier}:__auto__`,
    title: item.title || item.identifier,
    artistName: creator,
    artworkUrl: null,
    thumbnailUrl: null,
    sourceId: 'internet_archive',
    licenseType: license.type,
    attributionString: `${creator} via Internet Archive · ${license.label}`,
    sourceUrl: `${BASE_URL}/details/${item.identifier}`,
    durationMs: 0,
    offlineAllowed: true,
    genres: [],
    tags: [],
  };
}

module.exports = {
  sourceId: 'internet_archive',
  displayName: 'Internet Archive',
  isEnabled: true,

  async trending({ limit = 20 } = {}) {
    const res = await rateLimitedGet(SEARCH_URL, {
      q: 'mediatype:audio AND licenseurl:*',
      'fl[]': ['identifier', 'title', 'creator', 'licenseurl'],
      'sort[]': 'publicdate desc',
      rows: limit,
      output: 'json',
    });
    const docs = res.data?.response?.docs || [];
    return docs.map(itemToTrack).filter(Boolean);
  },

  async searchTracks(query, { limit = 20 } = {}) {
    const res = await rateLimitedGet(SEARCH_URL, {
      q: `(${query}) AND mediatype:audio`,
      'fl[]': ['identifier', 'title', 'creator', 'licenseurl'],
      'sort[]': 'downloads desc',
      rows: limit,
      output: 'json',
    });
    const docs = res.data?.response?.docs || [];
    return docs.map(itemToTrack).filter(Boolean);
  },

  async resolveStreamUrl(trackId) {
    // trackId: 'internet_archive:{identifier}:{filename}'
    const parts = trackId.replace('internet_archive:', '').split(':');
    if (parts.length < 2 || parts[1] === '__auto__') {
      // Need to resolve the best audio file from the item
      const identifier = parts[0];
      const res = await axios.get(`${BASE_URL}/metadata/${identifier}`, { timeout: 8000 });
      const files = res.data?.files || [];
      const audioFile = files.find((f) =>
        /\.(mp3|ogg|opus|flac|m4a)$/i.test(f.name)
      );
      if (!audioFile) throw new Error(`No audio file found in IA item: ${identifier}`);
      return `${BASE_URL}/download/${identifier}/${audioFile.name}`;
    }
    return `${BASE_URL}/download/${parts[0]}/${parts.slice(1).join(':')}`;
  },

  async healthCheck() {
    await rateLimitedGet(SEARCH_URL, {
      q: 'mediatype:audio',
      'fl[]': ['identifier'],
      rows: 1,
      output: 'json',
    });
  },
};
