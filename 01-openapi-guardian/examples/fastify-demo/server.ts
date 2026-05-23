import Fastify from "fastify";
import usersRoutes from "./routes/users";

const app = Fastify({ logger: false });

app.register(usersRoutes);

const PORT = Number(process.env.PORT ?? 3000);
app.listen({ port: PORT, host: "0.0.0.0" }, (err, address) => {
  if (err) {
    console.error(err);
    process.exit(1);
  }
  console.log(`Demo API (Fastify) listening on ${address}`);
  console.log("Try:");
  console.log(`  curl -X POST http://localhost:${PORT}/users -H 'content-type: application/json' -d '{"email":"alice@example.com","name":"Alice"}'`);
  console.log(`  curl http://localhost:${PORT}/users`);
});
