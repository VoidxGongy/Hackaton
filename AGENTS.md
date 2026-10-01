# Agent Instructions

## Project
NestJS (monolito modular) + TypeScript + Prisma + PostgreSQL backend for the
"Supervisión Inteligente" hackathon.

## Commands
- `npm run build` — type-check via tsc, generate Prisma client, emit to dist/
- `npm start` — start the compiled backend (port 3000)
- `npm run prisma:db:push` — sync schema to DB (dev)
- `npm run prisma:migrate:dev` — create + apply a migration
- `npm run prisma:migrate:deploy` — apply migrations (prod/Docker)
- `npm run prisma:seed` / `npx prisma db seed` — seed demo data
  - Coordinador: coordinador@empresa.com / password123
  - Supervisor:  supervisor@empresa.com / password123
- `npm test` — Jest integration tests
- `npm run lint` — no linter; run `npx tsc --noEmit` for type-checking

## Docker
- `docker compose up -d` — starts Postgres + backend
- `.env` local (localhost DB); `.env.docker` for compose (service host `db`)

## Notes
- Auth: JWT access (15m) + refresh (7d). Global JwtAuthGuard (first) then RolesGuard.
  Public routes use `@Public()` (e.g. /auth/login).
- Passwords hashed with bcrypt; never returned in responses.
- FCM readiness: `FCM_JSON_KEY` optional env var (JSON service account). If unset,
  push is skipped gracefully (no crash, no check-in rollback).
