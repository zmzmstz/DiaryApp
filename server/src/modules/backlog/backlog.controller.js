const { asyncHandler } = require("../../utils/asyncHandler");
const backlogService = require("./backlog.service");

const getMyBacklog = asyncHandler(async (req, res) => {
  const items = await backlogService.getUserBacklog(req.auth.username);
  res.status(200).json(items);
});

const addItem = asyncHandler(async (req, res) => {
  const item = await backlogService.addBacklogItem(req.auth.username, req.body);
  res.status(201).json(item);
});

const updateItem = asyncHandler(async (req, res) => {
  const item = await backlogService.updateBacklogItem(
    req.auth.username,
    req.params.id,
    req.body
  );
  res.status(200).json(item);
});

const deleteItem = asyncHandler(async (req, res) => {
  await backlogService.deleteBacklogItem(req.auth.username, req.params.id);
  res.status(204).send();
});

module.exports = {
  getMyBacklog,
  addItem,
  updateItem,
  deleteItem,
};
