const { Router } = require("express");
const { authMiddleware } = require("../../middlewares/authMiddleware");
const backlogController = require("./backlog.controller");

const backlogRouter = Router();

backlogRouter.use(authMiddleware);
backlogRouter.get("/", backlogController.getMyBacklog);
backlogRouter.post("/", backlogController.addItem);
backlogRouter.put("/:id", backlogController.updateItem);
backlogRouter.delete("/:id", backlogController.deleteItem);

module.exports = { backlogRouter };
