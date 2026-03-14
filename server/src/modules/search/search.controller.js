const { asyncHandler } = require("../../utils/asyncHandler");
const searchService = require("./search.service");

const searchAll = asyncHandler(async (req, res) => {
  const query = req.query.q || "";
  const results = await searchService.searchAll(query);
  res.status(200).json(results);
});

module.exports = { searchAll };
