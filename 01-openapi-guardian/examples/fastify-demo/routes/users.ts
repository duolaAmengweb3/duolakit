import type { FastifyInstance } from "fastify";
import type { components } from "../types/api";

type User = components["schemas"]["User"];
type CreateUserInput = components["schemas"]["CreateUserInput"];

// In-memory store for demo purposes
const users = new Map<string, User>();

export default async function usersRoutes(app: FastifyInstance) {
  // GET /users — listUsers
  app.get("/users", async () => {
    return [...users.values()];
  });

  // POST /users — createUser
  app.post<{ Body: CreateUserInput }>("/users", async (req, reply) => {
    const input = req.body;
    const user: User = {
      id: crypto.randomUUID(),
      email: input.email,
      name: input.name,
      createdAt: new Date().toISOString(),
    };
    users.set(user.id, user);
    reply.code(201);
    return user;
  });

  // GET /users/:id — getUser
  app.get<{ Params: { id: string } }>("/users/:id", async (req, reply) => {
    const user = users.get(req.params.id);
    if (!user) {
      reply.code(404);
      return;
    }
    return user;
  });

  // NOTE: DELETE /users/:id is in the spec but NOT implemented here yet.
  // Intentional drift — Pro-tier /openapi-check will catch it (Free skips Fastify entirely).
}
