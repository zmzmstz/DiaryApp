const { env } = require("../../config/env");

const TMDB_BASE_URL = "https://api.themoviedb.org/3";
const TMDB_IMAGE_BASE = "https://image.tmdb.org/t/p/w500";
const RAWG_BASE_URL = "https://api.rawg.io/api";
const TRAKT_BASE_URL = "https://api.trakt.tv";

async function fetchJson(url, options = {}) {
  const response = await fetch(url, options);
  if (!response.ok) {
    throw new Error(`External API error (${response.status}) for ${url}`);
  }
  return response.json();
}

async function searchTmdb(query) {
  if (!env.tmdbApiKey) {
    return [];
  }

  const url = `${TMDB_BASE_URL}/search/multi?api_key=${env.tmdbApiKey}&query=${encodeURIComponent(query)}&language=tr-TR&page=1`;
  const data = await fetchJson(url);
  const results = Array.isArray(data.results) ? data.results : [];

  return results
    .filter((item) => item.media_type === "movie" || item.media_type === "tv")
    .map((item) => {
      const isMovie = item.media_type === "movie";
      const posterPath = item.poster_path;
      return {
        externalId: `tmdb_${item.id}`,
        title: isMovie ? item.title : item.name,
        overview: item.overview || null,
        imageUrl: posterPath ? `${TMDB_IMAGE_BASE}${posterPath}` : null,
        releaseDate: isMovie ? item.release_date || null : item.first_air_date || null,
        rating: typeof item.vote_average === "number" ? item.vote_average : null,
        type: isMovie ? "movie" : "series",
        source: "tmdb",
      };
    })
    .filter((item) => item.title);
}

async function searchRawg(query) {
  if (!env.rawgApiKey) {
    return [];
  }

  const url = `${RAWG_BASE_URL}/games?key=${env.rawgApiKey}&search=${encodeURIComponent(query)}&page_size=15`;
  const data = await fetchJson(url);
  const results = Array.isArray(data.results) ? data.results : [];

  return results
    .map((item) => ({
      externalId: `rawg_${item.id}`,
      title: item.name,
      overview: null,
      imageUrl: item.background_image || null,
      releaseDate: item.released || null,
      rating: typeof item.rating === "number" ? item.rating : null,
      type: "game",
      source: "rawg",
    }))
    .filter((item) => item.title);
}

async function searchTrakt(query) {
  if (!env.traktClientId) {
    return [];
  }

  const url = `${TRAKT_BASE_URL}/search/movie,show?query=${encodeURIComponent(query)}&limit=15&extended=full`;
  const data = await fetchJson(url, {
    headers: {
      "Content-Type": "application/json",
      "trakt-api-version": "2",
      "trakt-api-key": env.traktClientId,
    },
  });

  const results = Array.isArray(data) ? data : [];

  return results
    .map((item) => {
      const type = item.type;
      const media = item[type] || {};
      const ids = media.ids || {};
      const isMovie = type === "movie";

      return {
        externalId: `trakt_${ids.trakt || media.title || Date.now()}`,
        title: media.title,
        overview: media.overview || null,
        imageUrl: ids.tmdb ? TMDB_IMAGE_BASE : null,
        releaseDate: isMovie ? media.released || null : media.first_aired || null,
        rating: typeof media.rating === "number" ? media.rating : null,
        type: isMovie ? "movie" : "series",
        source: "trakt",
      };
    })
    .filter((item) => item.title);
}

async function searchAll(query) {
  const cleanQuery = (query || "").trim();
  if (!cleanQuery) {
    return [];
  }

  const [tmdbResults, rawgResults, traktResults] = await Promise.allSettled([
    searchTmdb(cleanQuery),
    searchRawg(cleanQuery),
    searchTrakt(cleanQuery),
  ]);

  const tmdb = tmdbResults.status === "fulfilled" ? tmdbResults.value : [];
  const rawg = rawgResults.status === "fulfilled" ? rawgResults.value : [];
  const trakt = traktResults.status === "fulfilled" ? traktResults.value : [];

  const tmdbTitles = new Set(tmdb.map((item) => item.title.toLowerCase()));
  const uniqueTrakt = trakt.filter((item) => !tmdbTitles.has(item.title.toLowerCase()));

  return [...tmdb, ...rawg, ...uniqueTrakt];
}

module.exports = {
  searchAll,
};
