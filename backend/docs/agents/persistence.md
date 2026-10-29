# Persistence and migrations

Paths and commands are relative to `backend/` unless stated otherwise.

## Persistence And Migrations

- Postgres is the runtime database.
- Liquibase changelogs live in `lib/persistence/src/main/resources/db/changelog/`.
- Add new changelogs incrementally. Do not edit existing applied changelogs unless the user explicitly asks and the migration has not been shared.
- Add DAO/repository tests for persistence behavior and migration-sensitive changes.
