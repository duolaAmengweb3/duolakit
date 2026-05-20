import { Router } from "express";
import type { components } from "../types/api";

const router = Router();

// In-memory store for demo purposes
const users = new Map<string, components["schemas"]["User"]>();

// GET /users — listUsers
router.get("/users", (_req, res) => {
  res.json([...users.values()]);
});

// POST /users — createUser
router.post("/users", (req, res) => {
  const input = req.body as components["schemas"]["CreateUserInput"];
  const user: components["schemas"]["User"] = {
    id: crypto.randomUUID(),
    email: input.email,
    name: input.name,
    createdAt: new Date().toISOString(),
  };
  users.set(user.id, user);
  res.status(201).json(user);
});

// GET /users/:id — getUser
router.get("/users/:id", (req, res) => {
  const user = users.get(req.params.id);
  if (!user) return res.status(404).end();
  res.json(user);
});

// NOTE: DELETE /users/:id is in the spec but NOT implemented here yet.
// This is intentional drift — running /openapi-check will catch it.

export default router;
