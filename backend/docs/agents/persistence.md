# Persistence and migrations

Paths and commands are relative to `backend/` unless stated otherwise.

## Persistence And Migrations

- Postgres is the runtime database.
- Liquibase changelogs live in `lib/persistence/src/main/resources/db/changelog/`.
- Add new changelogs incrementally. Do not edit existing applied changelogs unless the user explicitly asks and the migration has not been shared.
- Add DAO/repository tests for persistence behavior and migration-sensitive changes.

For database-specific query plans, indexing, connection management, and locking, consult [Postgres best practices](../../../.agents/skills/supabase-postgres-best-practices/SKILL.md). Keep Exposed repositories and incremental Liquibase changelogs as the implementation owners. Evaluate recommendations against actual queries, constraints, and plans; example speedups are not measurements of this application. The skill does not select Supabase hosting, an auth provider, or a new RLS architecture.
