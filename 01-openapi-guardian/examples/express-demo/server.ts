import express from "express";
import users from "./routes/users";

const app = express();
app.use(express.json());
app.use(users);

const PORT = Number(process.env.PORT ?? 3000);
app.listen(PORT, () => {
  console.log(`Demo API listening on http://localhost:${PORT}`);
  console.log("Try:");
  console.log(`  curl -X POST http://localhost:${PORT}/users -H 'content-type: application/json' -d '{"email":"alice@example.com","name":"Alice"}'`);
  console.log(`  curl http://localhost:${PORT}/users`);
});
