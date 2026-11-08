# Backend runtime and environment

Paths and commands are relative to `backend/` unless stated otherwise.

## Runtime And Environment

- Local full-stack runtime is orchestrated from the monorepo root with `./scripts/run`.
- Direct service runs require the same environment contract described in `backend/README.md` and the root `.env.example`.
- Keep secrets out of source control. Treat Supabase secret keys, SMTP credentials, Firebase service accounts and Zoho values as secrets.
- Configure managed auth, mail, native clients and cutover through [Supabase auth setup](../../../docs/agents/supabase-auth.md).
