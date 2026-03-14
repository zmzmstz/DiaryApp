const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const { env } = require("../../config/env");
const authRepository = require("./auth.repository");
const { HttpError } = require("../../utils/httpError");

function sanitizeUser(doc) {
  return {
    username: doc.username,
    displayName: doc.displayName,
  };
}

function createAccessToken(user) {
  if (!env.jwtSecret) {
    throw new HttpError(500, "Missing JWT_SECRET environment variable.");
  }

  return jwt.sign(
    {
      username: user.username,
      displayName: user.displayName,
    },
    env.jwtSecret,
    { expiresIn: env.jwtExpiresIn }
  );
}

async function register({ username, displayName, password }) {
  const normalized = username.toLowerCase().trim();
  const normalizedDisplayName = displayName.trim();

  if (!normalized || !normalizedDisplayName || !password) {
    throw new HttpError(400, "Username, display name and password are required.");
  }

  if (password.length < 6) {
    throw new HttpError(400, "Password must be at least 6 characters.");
  }

  const existing = await authRepository.findByUsername(normalized);
  if (existing) {
    throw new HttpError(409, "Username already taken.");
  }

  const passwordHash = await bcrypt.hash(password, 10);
  const userDoc = {
    username: normalized,
    displayName: normalizedDisplayName,
    passwordHash,
    createdAt: new Date().toISOString(),
  };

  const created = await authRepository.createUser(userDoc);
  const user = sanitizeUser(created);

  return {
    user,
    accessToken: createAccessToken(user),
  };
}

async function login({ username, password }) {
  const normalized = username.toLowerCase().trim();

  if (!normalized || !password) {
    throw new HttpError(400, "Username and password are required.");
  }

  const userDoc = await authRepository.findByUsername(normalized);
  if (!userDoc) {
    throw new HttpError(401, "Invalid username or password.");
  }

  const isValid = await bcrypt.compare(password, userDoc.passwordHash || "");
  if (!isValid) {
    throw new HttpError(401, "Invalid username or password.");
  }

  const user = sanitizeUser(userDoc);

  return {
    user,
    accessToken: createAccessToken(user),
  };
}

module.exports = {
  register,
  login,
};
