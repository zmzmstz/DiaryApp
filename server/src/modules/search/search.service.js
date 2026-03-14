const { env } = require("../../config/env");

const TMDB_BASE_URL = "https://api.themoviedb.org/3";
const TMDB_IMAGE_BASE = "https://image.tmdb.org/t/p/w500";
const RAWG_BASE_URL = "https://api.rawg.io/api";
const TRAKT_BASE_URL = "https://api.trakt.tv";
const SPOTIFY_ACCOUNTS_BASE_URL = "https://accounts.spotify.com";
const SPOTIFY_BASE_URL = "https://api.spotify.com/v1";
const OPEN_LIBRARY_BASE_URL = "https://openlibrary.org";

const spotifyTokenCache = {
  token: "",
  expiresAt: 0,
};

async function fetchJson(url, options = {}) {
  const response = await fetch(url, options);
  if (!response.ok) {
    throw new Error(`External API error (${response.status}) for ${url}`);
  }
  return response.json();
}

async function getSpotifyAccessToken() {
  if (!env.spotifyClientId || !env.spotifyClientSecret) {
    return "";
  }

  const now = Date.now();
  if (spotifyTokenCache.token && spotifyTokenCache.expiresAt > now + 10_000) {
    return spotifyTokenCache.token;
  }

  const auth = Buffer.from(`${env.spotifyClientId}:${env.spotifyClientSecret}`).toString("base64");
  const response = await fetch(`${SPOTIFY_ACCOUNTS_BASE_URL}/api/token`, {
    method: "POST",
    headers: {
      Authorization: `Basic ${auth}`,
      "Content-Type": "application/x-www-form-urlencoded",
    },
    body: new URLSearchParams({ grant_type: "client_credentials" }),
  });

  if (!response.ok) {
    throw new Error(`Spotify token error (${response.status})`);
  }

  const payload = await response.json();
  const token = payload.access_token || "";
  const expiresInSeconds = Number(payload.expires_in || 0);

  if (!token || !expiresInSeconds) {
    return "";
  }

  spotifyTokenCache.token = token;
  spotifyTokenCache.expiresAt = now + expiresInSeconds * 1000;

  return token;
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

async function searchSpotify(query) {
  try {
    if (!env.spotifyClientId || !env.spotifyClientSecret) {
      return [];
    }

    const token = await getSpotifyAccessToken();
    if (!token) {
      return [];
    }

    const url = `${SPOTIFY_BASE_URL}/search?type=track&limit=15&market=TR&q=${encodeURIComponent(query)}`;
    const data = await fetchJson(url, {
      headers: {
        Authorization: `Bearer ${token}`,
      },
    });

    const tracks = Array.isArray(data.tracks?.items) ? data.tracks.items : [];

    return tracks
      .map((track) => {
        const artists = Array.isArray(track.artists) ? track.artists.map((artist) => artist.name).filter(Boolean) : [];
        const album = track.album || {};
        const images = Array.isArray(album.images) ? album.images : [];
        const imageUrl = images.length > 0 ? images[0].url : null;

        return {
          externalId: `spotify_${track.id}`,
          title: track.name,
          overview: artists.length > 0 ? artists.join(", ") : null,
          imageUrl,
          releaseDate: album.release_date || null,
          rating: null,
          type: "song",
          source: "spotify",
        };
      })
      .filter((item) => item.title);
  } catch (error) {
    console.error("Spotify API error:", error.message);
    return [];
  }
}

async function searchBooks(query) {
  try {
    const url = `${OPEN_LIBRARY_BASE_URL}/search.json?title=${encodeURIComponent(query)}&limit=15`;
    const data = await fetchJson(url);
    const docs = Array.isArray(data.docs) ? data.docs : [];

    return docs
      .map((doc) => {
        const title = doc.title;
        const authors = Array.isArray(doc.author_name) ? doc.author_name.filter(Boolean) : [];
        const coverId = doc.cover_i;
        const imageUrl = coverId ? `https://covers.openlibrary.org/b/id/${coverId}-M.jpg` : null;
        const firstPublishYear = doc.first_publish_year;
        const releaseDate = firstPublishYear ? String(firstPublishYear) : null;
        const rating = typeof doc.ratings_average === "number" ? doc.ratings_average : null;

        return {
          externalId: `openlibrary_${doc.key || title || Date.now()}`,
          title,
          overview: authors.length > 0 ? `Yazar: ${authors.join(", ")}` : null,
          imageUrl,
          releaseDate,
          rating,
          type: "book",
          source: "open_library",
        };
      })
      .filter((result) => result.title);
  } catch (error) {
    console.error("Open Library API error:", error.message);
    return [];
  }
}

function dedupeByTypeAndTitle(items) {
  const seen = new Set();
  return items.filter((item) => {
    const key = `${item.type}:${String(item.title || "").trim().toLowerCase()}`;
    if (seen.has(key)) {
      return false;
    }
    seen.add(key);
    return true;
  });
}

async function searchAll(query) {
  const cleanQuery = (query || "").trim();
  if (!cleanQuery) {
    return [];
  }

  const [tmdbResults, rawgResults, traktResults, spotifyResults, booksResults] = await Promise.allSettled([
    searchTmdb(cleanQuery),
    searchRawg(cleanQuery),
    searchTrakt(cleanQuery),
    searchSpotify(cleanQuery),
    searchBooks(cleanQuery),
  ]);

  const tmdb = tmdbResults.status === "fulfilled" ? tmdbResults.value : [];
  const rawg = rawgResults.status === "fulfilled" ? rawgResults.value : [];
  const trakt = traktResults.status === "fulfilled" ? traktResults.value : [];
  const spotify = spotifyResults.status === "fulfilled" ? spotifyResults.value : [];
  const books = booksResults.status === "fulfilled" ? booksResults.value : [];

  const tmdbTitles = new Set(tmdb.map((item) => item.title.toLowerCase()));
  const uniqueTrakt = trakt.filter((item) => !tmdbTitles.has(item.title.toLowerCase()));

  return dedupeByTypeAndTitle([...tmdb, ...rawg, ...uniqueTrakt, ...spotify, ...books]);
}

module.exports = {
  searchAll,
};
