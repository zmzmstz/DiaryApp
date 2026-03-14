const path = require("path");
const dotenv = require("dotenv");

// Prefer project root .env, fall back to server/.env.
dotenv.config({ path: path.resolve(process.cwd(), "../.env"), override: false });
dotenv.config({ path: path.resolve(process.cwd(), ".env"), override: false });

const env = {
  nodeEnv: process.env.NODE_ENV || "development",
  port: Number(process.env.PORT || 5038),
  dbUri: process.env.DB_URI || "",
  dbName: process.env.DB_NAME || "cse_mobil_diary_app",
  jwtSecret: process.env.JWT_SECRET || "dev_jwt_secret_change_me",
  jwtExpiresIn: process.env.JWT_EXPIRES_IN || "7d",
  tmdbApiKey: process.env.TMDB_API_KEY || "",
  rawgApiKey: process.env.RAWG_API_KEY || "",
  traktClientId: process.env.TRAKT_CLIENT_ID || "",
};

module.exports = { env };
