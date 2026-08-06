'use strict';

const { resolveStreamUrl: _resolveStream, getInnertube } = require('./stream_resolver');

// Cache to prevent needing a full API call during fallback
const metadataCache = new Map();

function parseTrack(song) {
  if (!song || (!song.id && !song.video_id)) return null;

  // youtubei.js returns song titles sometimes as strings, sometimes as Text object
  let title = song.title || song.name;
  if (typeof title === 'object' && title.text) {
    title = title.text;
  } else if (typeof title === 'object') {
    title = title.toString();
  }

  const videoId = song.id || song.video_id;
  if (!videoId || !title) return null;

  try {
    let artworkUrl = null;
    let thumbnailUrl = null;

    if (song.thumbnails?.length) {
      artworkUrl = song.thumbnails[song.thumbnails.length - 1].url;
      thumbnailUrl = song.thumbnails[0].url;
    } else if (song.thumbnail) {
      artworkUrl = song.thumbnail[0]?.url || song.thumbnail;
      thumbnailUrl = artworkUrl;
    }

    if (artworkUrl && typeof artworkUrl === 'string') {
      artworkUrl = artworkUrl.replace(/w\d+-h\d+/, 'w500-h500');
    }

    let artistName = 'Unknown Artist';
    let artistId = null;

    if (song.artists && song.artists.length > 0) {
      artistName = song.artists.map(a => a.name).join(', ');
      if (song.artists[0].channel_id) {
        artistId = `youtube_music_artist:${song.artists[0].channel_id}`;
      }
    } else if (song.author) {
      artistName = typeof song.author === 'string' ? song.author : (song.author.name || 'Unknown Artist');
    }

    const parsed = {
      id: `youtube_music:${videoId}`,
      title: title,
      artistName: artistName,
      artistId: artistId,
      albumName: song.album?.name || '',
      artworkUrl: artworkUrl,
      thumbnailUrl: thumbnailUrl,
      sourceId: 'youtube_music',
      licenseType: 'CUSTOM',
      attributionString: `${artistName} · YouTube Music`,
      sourceUrl: `https://music.youtube.com/watch?v=${videoId}`,
      durationMs: song.duration?.seconds ? song.duration.seconds * 1000 : 0,
      playCount: 0,
      offlineAllowed: false,
      streamUrl: null,
      genres: [],
      language: '',
    };

    // Cache for fallback mechanism
    metadataCache.set(videoId, { title: parsed.title, artistName: parsed.artistName });

    return parsed;
  } catch (e) {
    console.error('parseTrack error for song', song.id || song.video_id, e);
    return null;
  }
}

function getTracksFromResult(res) {
  if (!res) return [];
  if (res.contents && res.contents.length > 0) {
    if (res.contents[0].type === 'MusicShelf' || res.contents[0].type === 'SectionList') {
      return res.contents.flatMap(shelf => shelf.contents || []).filter(item => item.type === 'MusicResponsiveListItem' || item.type === 'PlaylistPanelVideo');
    }
    return res.contents.filter(item => item.type === 'MusicResponsiveListItem' || item.type === 'PlaylistPanelVideo');
  }
  return [];
}

module.exports = {
  sourceId: 'youtube_music',
  displayName: 'YouTube Music',
  isEnabled: true,

  async searchTracks(query, { limit = 20, genre, language } = {}) {
    try {
      const yt = await getInnertube();

      let finalQuery = query;
      if (!query && genre) {
        finalQuery = `${genre} top hits`;
      } else if (!query && language) {
        finalQuery = `${language} top hits`;
      }

      const results = await yt.music.search(finalQuery, { type: 'song' });
      const tracks = getTracksFromResult(results);
      return tracks.slice(0, limit).map(parseTrack).filter(Boolean);
    } catch (e) {
      console.error('[YouTube Music] searchTracks error:', e.message);
      return [];
    }
  },

  async trending({ genre, language, limit = 20 } = {}) {
    try {
      const yt = await getInnertube();
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
        const results = await yt.music.search(query, { type: 'song' });
        return getTracksFromResult(results).slice(0, limit).map(parseTrack).filter(Boolean);
      }

      const query = language ? `top ${language} songs` : 'global top 50 songs';
      const results = await yt.music.search(query, { type: 'song' });
      return getTracksFromResult(results).slice(0, limit).map(parseTrack).filter(Boolean);
    } catch (e) {
      console.error('[YouTube Music] trending error:', e.message);
      return [];
    }
  },

  async getUpNext(trackId) {
    try {
      const yt = await getInnertube();
      const nativeId = trackId.replace('youtube_music:', '');
      const results = await yt.music.getUpNext(nativeId);
      return getTracksFromResult(results).map(parseTrack).filter(Boolean);
    } catch (e) {
      console.error(`[YouTube Music] getUpNext error for ${trackId}:`, e.message);
      return [];
    }
  },

  async getHomeRecommendations() {
    try {
      const yt = await getInnertube();

      const categories = [
        {
          title: 'Bollywood Hits',
          queries: ['New bollywood hits', 'new bollywood songs', 'top bollywood', 'trending bollywood', 'bollywood romantic']
        },
        {
          title: 'Global Hits',
          queries: ['Latest Top Global hits', 'top international songs', 'billboard hot 100', 'viral global hits']
        },
        {
          title: 'Desi Hip-Hop',
          queries: ['Emiway bantai', 'Emiway', 'Karma', 'Young Stunners', 'Divine', 'Kr$na', 'Talha anjum', 'King', 'Raftaar', 'Yo Yo Honey singh', 'Seedhe maut', 'MC Stan', 'Faris Shafi', 'top desi hip hop']
        },
        {
          title: 'Lofi',
          queries: ['Top Lofi', 'Bollywood lofi', 'lofi hip hop', 'lofi chill']
        },
        {
          title: 'English Hip-Hop',
          queries: ['NF', 'Drake', 'Khalid', 'J Cole', 'Eminem', 'Logic', 'G-Eazy', 'Travis scott', 'Kanye West', 'The Weeknd', 'Dax', 'Lil Nas X', '21 Savage']
        },
        {
          title: 'Indie',
          queries: ['indian indie music', 'indie pop', 'best indie songs', 'indie acoustic']
        },
        {
          title: 'Trending Today',
          queries: ['trending music today', 'viral hits', 'top songs right now']
        },
        {
          title: 'Acoustic',
          queries: ['acoustic covers', 'best acoustic songs', 'chill acoustic', 'unplugged versions']
        },
        {
          title: 'Punjabi Hits',
          queries: ['latest punjabi songs', 'punjabi hits', 'top punjabi music', 'punjabi party songs']
        }
      ];

      // Fetch categories sequentially to avoid rate limits and timeouts
      const fetchedShelves = [];
      for (const [index, cat] of categories.entries()) {
        // Shuffle the queries so it's random, but we can iterate through all of them as fallbacks
        const shuffledQueries = [...cat.queries].sort(() => 0.5 - Math.random());
        let categoryTracks = [];
        
        for (const query of shuffledQueries) {
          try {
            const results = await yt.music.search(query, { type: 'song' });
            let tracks = getTracksFromResult(results).map(parseTrack).filter(Boolean);
            
            if (tracks.length >= 5) {
              // We got a good amount of tracks, use this query
              // Shuffle tracks and pick top 25
              categoryTracks = tracks.sort(() => 0.5 - Math.random()).slice(0, 25);
              break; // Stop trying other queries for this category
            }
          } catch (e) {
            console.error(`Failed to fetch query "${query}" for category ${cat.title}:`, e.message);
          }
        }
        
        if (categoryTracks.length > 0) {
          fetchedShelves.push({
            title: cat.title,
            tracks: categoryTracks,
            _order: index // Retain fixed order
          });
        } else {
          console.error(`All queries failed for category ${cat.title}`);
        }
      }

      // Filter nulls, sort by original order so categories don't shuffle, and clean up
      return fetchedShelves
        .filter(Boolean)
        .sort((a, b) => a._order - b._order)
        .map(shelf => {
          delete shelf._order;
          return shelf;
        });

    } catch (e) {
      console.error('[YouTube Music] getHomeRecommendations error:', e.message);
      return [];
    }
  },

  async getAlbumTracks(albumId) {
    return [];
  },

  async resolveStreamUrl(trackId, options = {}) {
    const nativeId = trackId.replace('youtube_music:', '');
    try {
      return await _resolveStream(nativeId, options.poToken, options.visitorData);
    } catch (e) {
      throw new Error(`[YouTube Music] Failed to resolve stream URL for ${trackId}: ${e.message}`);
    }
  },

  async getTrackInfo(trackId) {
    const nativeId = trackId.replace('youtube_music:', '');
    if (metadataCache.has(nativeId)) {
      return metadataCache.get(nativeId);
    }

    try {
      const yt = await getInnertube();
      const info = await yt.music.getInfo(nativeId);
      return {
        title: info.basic_info.title,
        artistName: info.basic_info.author,
      };
    } catch (e) {
      throw new Error(`[YouTube Music] Failed to get track info for ${trackId}: ${e.message}`);
    }
  },

  async healthCheck() {
    const yt = await getInnertube();
    const results = await yt.music.search('adele', { type: 'song' });
    if (!results.contents || !results.contents.length) throw new Error('YouTube Music returned no results');
  },
};
