try { require("dotenv").config({ path: "../.env", override: false }); } catch (_) {}
const express = require("express");
const cors = require("cors");
const crypto = require("crypto");
const { MongoClient } = require("mongodb");

const app = express();
app.use(cors());
app.use(express.json());

const PORT = process.env.PORT || 5038;
const uri = process.env.DB_URI;
const dbName = process.env.DB_NAME || "cse_mobil_diary_app";

let db;

function hashPassword(password) {
  return crypto.createHash("sha256").update(password).digest("hex");
}

async function connectDB() {
  const client = new MongoClient(uri, { serverSelectionTimeoutMS: 10000 });
  await client.connect();
  await client.db(dbName).command({ ping: 1 });
  db = client.db(dbName);
  console.log("Connected to MongoDB:", dbName);
}

// ─── Auth ────────────────────────────────────────────

app.post("/api/auth/register", async (req, res) => {
  try {
    const { username, password, displayName } = req.body;
    if (!username || !password || !displayName) {
      return res.status(400).json({ error: "All fields are required." });
    }

    const users = db.collection("users");
    const normalized = username.toLowerCase().trim();

    const existing = await users.findOne({ username: normalized });
    if (existing) {
      return res.status(409).json({ error: "Username already taken." });
    }

    const doc = {
      username: normalized,
      displayName: displayName.trim(),
      passwordHash: hashPassword(password),
    };
    await users.insertOne(doc);

    res.json({ username: doc.username, displayName: doc.displayName });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.post("/api/auth/login", async (req, res) => {
  try {
    const { username, password } = req.body;
    if (!username || !password) {
      return res.status(400).json({ error: "Username and password required." });
    }

    const users = db.collection("users");
    const doc = await users.findOne({
      username: username.toLowerCase().trim(),
    });

    if (!doc || doc.passwordHash !== hashPassword(password)) {
      return res.status(401).json({ error: "Invalid username or password." });
    }

    res.json({ username: doc.username, displayName: doc.displayName });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// ─── Backlog CRUD ────────────────────────────────────

app.get("/api/backlog/:username", async (req, res) => {
  try {
    const { username } = req.params;
    const items = await db
      .collection("backlog_items")
      .find({ owner: username })
      .toArray();
    const mapped = items.map((i) => {
      const { _id, ...rest } = i;
      return rest;
    });
    res.json(mapped);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.post("/api/backlog", async (req, res) => {
  try {
    const item = req.body;
    await db.collection("backlog_items").insertOne(item);
    res.json({ ok: true });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.put("/api/backlog/:id", async (req, res) => {
  try {
    const { id } = req.params;
    const item = req.body;
    await db.collection("backlog_items").updateOne({ id }, { $set: item });
    res.json({ ok: true });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.delete("/api/backlog/:id", async (req, res) => {
  try {
    const { id } = req.params;
    await db.collection("backlog_items").deleteOne({ id });
    res.json({ ok: true });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// ─── Start ───────────────────────────────────────────

connectDB()
  .then(() => {
    app.listen(PORT, "0.0.0.0", () => {
      console.log(`API server running on http://0.0.0.0:${PORT}`);
    });
  })
  .catch((err) => {
    console.error("Failed to connect to MongoDB:", err.message);
    process.exit(1);
  });
