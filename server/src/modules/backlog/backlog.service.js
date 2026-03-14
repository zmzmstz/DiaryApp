const backlogRepository = require("./backlog.repository");
const { HttpError } = require("../../utils/httpError");

function sanitizeBacklogItem(doc) {
  const { _id, ...safeDoc } = doc;
  return safeDoc;
}

function validateBacklogItem(item) {
  if (!item || typeof item !== "object") {
    throw new HttpError(400, "Backlog item payload is required.");
  }

  if (!item.id || typeof item.id !== "string") {
    throw new HttpError(400, "Backlog item id is required.");
  }

  if (!item.title || typeof item.title !== "string") {
    throw new HttpError(400, "Backlog item title is required.");
  }
}

async function getUserBacklog(owner) {
  const docs = await backlogRepository.findByOwner(owner);
  return docs.map(sanitizeBacklogItem);
}

async function addBacklogItem(owner, item) {
  validateBacklogItem(item);

  const existing = await backlogRepository.findByOwnerAndItemId(owner, item.id);
  if (existing) {
    throw new HttpError(409, "Backlog item already exists.");
  }

  const doc = {
    ...item,
    owner,
    createdAt: item.createdAt || new Date().toISOString(),
  };

  await backlogRepository.createItem(doc);
  return sanitizeBacklogItem(doc);
}

async function updateBacklogItem(owner, id, item) {
  validateBacklogItem({ ...item, id });

  const doc = {
    ...item,
    id,
    owner,
  };

  const updated = await backlogRepository.updateItem(owner, id, doc);
  if (!updated) {
    throw new HttpError(404, "Backlog item not found.");
  }

  return sanitizeBacklogItem(updated);
}

async function deleteBacklogItem(owner, id) {
  const result = await backlogRepository.deleteItem(owner, id);
  if (!result.deletedCount) {
    throw new HttpError(404, "Backlog item not found.");
  }
}

module.exports = {
  getUserBacklog,
  addBacklogItem,
  updateBacklogItem,
  deleteBacklogItem,
};
