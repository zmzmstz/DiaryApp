const { MongoClient } = require("mongodb");
const { env } = require("./env");

let client;
let database;

async function connectDb() {
  if (database) {
    return database;
  }

  if (!env.dbUri) {
    throw new Error("Missing DB_URI environment variable.");
  }

  client = new MongoClient(env.dbUri, {
    serverSelectionTimeoutMS: 10000,
  });

  await client.connect();
  await client.db(env.dbName).command({ ping: 1 });
  database = client.db(env.dbName);

  return database;
}

function getDb() {
  if (!database) {
    throw new Error("Database not connected. Call connectDb() first.");
  }
  return database;
}

async function closeDb() {
  if (client) {
    await client.close();
    client = null;
    database = null;
  }
}

module.exports = {
  connectDb,
  getDb,
  closeDb,
};
