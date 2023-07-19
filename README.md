# supabase-postgres-pg_idkit
`docker pull hambergerpls/supabase-postgres-pg_idkit:15.1.0.90`

This docker image builds [pg_idkit](https://github.com/VADOSWARE/pg_idkit) extension and installs it to [supabase-postgres](https://github.com/supabase/postgres) docker image.

This only works for self-hosted supabase (I think).

## Enabling the extension
Copy and paste the following SQL statement into the SQL Editor in Supabase Studio or create it as a migration file e.g. `pg_idkit.sql`
```pgsql
CREATE SCHEMA IF NOT EXISTS "pgtle";
CREATE EXTENSION IF NOT EXISTS pg_tle WITH SCHEMA "pgtle";

CREATE EXTENSION pg_idkit WITH SCHEMA extensions;
```
