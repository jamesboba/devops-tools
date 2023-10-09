Prometheus exporter for PostgreSQL server metrics.

CI Tested PostgreSQL versions: 10, 11, 12, 13, 14, 15


https://github.com/prometheus-community/postgres_exporter



#### Running as non-superuser
To be able to collect metrics from pg_stat* views as non-superuser in PostgreSQL server versions >= 10 you can grant the pg_monitor or pg_read_all_stats built-in roles to the user. If you need to monitor older PostgreSQL servers, you will have to create functions and views as a superuser, and assign permissions separately to those.

```shell!
-- To use IF statements, hence to be able to check if the user exists before
-- attempting creation, we need to switch to procedural SQL (PL/pgSQL)
-- instead of standard SQL.
-- More: https://www.postgresql.org/docs/9.3/plpgsql-overview.html
-- To preserve compatibility with <9.0, DO blocks are not used; instead,
-- a function is created and dropped.
CREATE OR REPLACE FUNCTION __tmp_create_user() returns void as $$
BEGIN
  IF NOT EXISTS (
          SELECT                       -- SELECT list can stay empty for this
          FROM   pg_catalog.pg_user
          WHERE  usename = 'postgres_exporter') THEN
    CREATE USER postgres_exporter;
  END IF;
END;
$$ language plpgsql;

SELECT __tmp_create_user();
DROP FUNCTION __tmp_create_user();

ALTER USER postgres_exporter WITH PASSWORD 'password';
ALTER USER postgres_exporter SET SEARCH_PATH TO postgres_exporter,pg_catalog;

-- If deploying as non-superuser (for example in AWS RDS), uncomment the GRANT
-- line below and replace <MASTER_USER> with your root user.
-- GRANT postgres_exporter TO <MASTER_USER>;

```

GRANT CONNECT ON DATABASE postgres TO postgres_exporter;
Run following command if you use PostgreSQL versions >= 10

```
GRANT pg_monitor to postgres_exporter;
```

Run following SQL commands only if you use PostgreSQL versions older than 10. In PostgreSQL, views run with the permissions of the user that created them so they can act as security barriers. Functions need to be created to share this data with the non-superuser. Only creating the views will leave out the most important bits of data.

```shell!
CREATE SCHEMA IF NOT EXISTS postgres_exporter;
GRANT USAGE ON SCHEMA postgres_exporter TO postgres_exporter;

CREATE OR REPLACE FUNCTION get_pg_stat_activity() RETURNS SETOF pg_stat_activity AS
$$ SELECT * FROM pg_catalog.pg_stat_activity; $$
LANGUAGE sql
VOLATILE
SECURITY DEFINER;

CREATE OR REPLACE VIEW postgres_exporter.pg_stat_activity
AS
  SELECT * from get_pg_stat_activity();

GRANT SELECT ON postgres_exporter.pg_stat_activity TO postgres_exporter;

CREATE OR REPLACE FUNCTION get_pg_stat_replication() RETURNS SETOF pg_stat_replication AS
$$ SELECT * FROM pg_catalog.pg_stat_replication; $$
LANGUAGE sql
VOLATILE
SECURITY DEFINER;

CREATE OR REPLACE VIEW postgres_exporter.pg_stat_replication
AS
  SELECT * FROM get_pg_stat_replication();
```

```shell!
GRANT SELECT ON postgres_exporter.pg_stat_replication TO postgres_exporter;
```

```shell!

CREATE EXTENSION IF NOT EXISTS pg_stat_statements;
CREATE OR REPLACE FUNCTION get_pg_stat_statements() RETURNS SETOF pg_stat_statements AS
$$ SELECT * FROM public.pg_stat_statements; $$
LANGUAGE sql
VOLATILE
SECURITY DEFINER;

CREATE OR REPLACE VIEW postgres_exporter.pg_stat_statements
AS
  SELECT * FROM get_pg_stat_statements();

GRANT SELECT ON postgres_exporter.pg_stat_statements TO postgres_exporter;
Note
```

```
Remember to use postgres database name in the connection string:

DATA_SOURCE_NAME=postgresql://postgres_exporter:password@localhost:5432/postgres?sslmode=disable

```