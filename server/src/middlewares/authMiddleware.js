const jwt = require("jsonwebtoken");
const { env } = require("../config/env");
const { HttpError } = require("../utils/httpError");

function authMiddleware(req, _res, next) {
  const authHeader = req.headers.authorization || "";
  const [scheme, token] = authHeader.split(" ");

  if (scheme !== "Bearer" || !token) {
    return next(new HttpError(401, "Authorization token is required."));
  }

  if (!env.jwtSecret) {
    return next(new HttpError(500, "Server JWT secret is not configured."));
  }

  try {
    const payload = jwt.verify(token, env.jwtSecret);
    req.auth = {
      username: payload.username,
      displayName: payload.displayName,
    };
    return next();
  } catch (_) {
    return next(new HttpError(401, "Invalid or expired token."));
  }
}

module.exports = { authMiddleware };
