# Backend runtime and environment

Paths and commands are relative to `backend/` unless stated otherwise.

## Runtime And Environment

- Local full-stack runtime is orchestrated from the monorepo root with `./scripts/run`.
- Direct service runs require the same environment contract described in `backend/README.md` and the root `.env.example`.
- Keep secrets out of source control. Treat Firebase and Zoho values as secrets.
