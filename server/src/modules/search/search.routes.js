const { Router } = require("express");
const { authMiddleware } = require("../../middlewares/authMiddleware");
const searchController = require("./search.controller");

const searchRouter = Router();

// searchRouter.use(authMiddleware); // Temporarily disabled for testing
searchRouter.get("/", searchController.searchAll);

module.exports = { searchRouter };
