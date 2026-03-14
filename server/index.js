const { env } = require("./src/config/env");
const { connectDb, closeDb } = require("./src/config/db");
const { app } = require("./src/app");

let server;

async function bootstrap() {
  await connectDb();
  console.log("Connected to MongoDB:", env.dbName);

  server = app.listen(env.port, "0.0.0.0", () => {
    console.log(`API server running on http://0.0.0.0:${env.port}`);
  });
}

async function gracefulShutdown(signal) {
  console.log(`${signal} received. Shutting down...`);

  if (server) {
    await new Promise((resolve, reject) => {
      server.close((error) => {
        if (error) {
          reject(error);
          return;
        }
        resolve();
      });
    });
  }

  await closeDb();
  process.exit(0);
}

process.on("SIGINT", () => {
  gracefulShutdown("SIGINT").catch((error) => {
    console.error("Shutdown error:", error.message);
    process.exit(1);
  });
});

process.on("SIGTERM", () => {
  gracefulShutdown("SIGTERM").catch((error) => {
    console.error("Shutdown error:", error.message);
    process.exit(1);
  });
});

bootstrap().catch((error) => {
  console.error("Server bootstrap failed:", error.message);
  process.exit(1);
});
