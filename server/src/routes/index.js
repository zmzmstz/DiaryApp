const { Router } = require("express");
const { authRouter } = require("../modules/auth/auth.routes");
const { backlogRouter } = require("../modules/backlog/backlog.routes");
const { searchRouter } = require("../modules/search/search.routes");

const apiRouter = Router();

apiRouter.get("/health", (_req, res) => {
  res.status(200).json({ ok: true });
});

apiRouter.use("/auth", authRouter);
apiRouter.use("/backlog", backlogRouter);
apiRouter.use("/search", searchRouter);

module.exports = { apiRouter };
