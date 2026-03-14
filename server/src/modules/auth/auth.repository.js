const { getDb } = require("../../config/db");
const { COLLECTIONS } = require("../../constants/collections");

function usersCollection() {
  return getDb().collection(COLLECTIONS.users);
}

async function findByUsername(username) {
  return usersCollection().findOne({ username });
}

async function createUser(userDoc) {
  await usersCollection().insertOne(userDoc);
  return userDoc;
}

module.exports = {
  findByUsername,
  createUser,
};
