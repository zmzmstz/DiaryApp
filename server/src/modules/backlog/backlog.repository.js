const { getDb } = require("../../config/db");
const { COLLECTIONS } = require("../../constants/collections");

function backlogCollection() {
  return getDb().collection(COLLECTIONS.backlogItems);
}

async function findByOwner(owner) {
  return backlogCollection().find({ owner }).toArray();
}

async function findByOwnerAndItemId(owner, id) {
  return backlogCollection().findOne({ owner, id });
}

async function createItem(doc) {
  await backlogCollection().insertOne(doc);
  return doc;
}

async function updateItem(owner, id, doc) {
  const updateResult = await backlogCollection().updateOne(
    { owner, id },
    { $set: doc }
  );

  if (!updateResult.matchedCount) {
    return null;
  }

  return findByOwnerAndItemId(owner, id);
}

async function deleteItem(owner, id) {
  return backlogCollection().deleteOne({ owner, id });
}

module.exports = {
  findByOwner,
  findByOwnerAndItemId,
  createItem,
  updateItem,
  deleteItem,
};
