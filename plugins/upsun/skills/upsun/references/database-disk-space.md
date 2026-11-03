# Database disk space

Use this workflow when a MySQL, MariaDB, or PostgreSQL service is running out of disk, or when the user asks to reclaim database space. Diagnose with read-only queries first. Any statement that rewrites or locks a table needs the user's confirmation, as described in [Safety rules](#safety-rules).

Run SQL with `upsun sql -p PROJECT_ID -e ENV_ID [-r RELATIONSHIP] "QUERY"`. It gets credentials from the environment, so never put passwords or connection strings in commands or output. It connects over SSH: follow the skill's production access guidance.

## Safety rules

- Diagnose before proposing changes. Report sizes as estimates, with their source.
- Get explicit confirmation before each statement that rewrites, locks, or deletes data: `ALTER TABLE`, `OPTIMIZE TABLE`, `VACUUM FULL`, `REINDEX`, `TRUNCATE`, `DELETE`, and `upsun db:mysql-optimize --execute`. Show the exact statement, the target environment, and the expected lock and disk use.
- Try a rebuild on a preview environment first. Previews are cloned from the parent's storage, so they have the same files and fragmentation, and show how long a rebuild takes and how much it frees. Statistics views may be reset in a new preview.
- Before a rebuild on production, check `upsun backup:list` and suggest `upsun backup:create --live` if there is no recent backup (see the skill's backup retention caveat).
- Never run a rewrite on production without the user's explicit consent for that environment.
- Rebuild one table at a time, the smallest first: each rebuild frees space for the next.

## 1. Check disk usage against the limit

```bash
upsun disk -p PROJECT_ID -e ENV_ID --service DB_SERVICE --latest
upsun disk -p PROJECT_ID -e ENV_ID --service DB_SERVICE --latest --tmp
upsun db:size -p PROJECT_ID -e ENV_ID [-r RELATIONSHIP]
```

`upsun disk` (`metrics:disk-usage`) reports the service's disk and `/tmp` usage from the metrics API. `upsun db:size` estimates the database's share; the real size on disk is usually higher. `upsun resources:get` shows the allocated disk.

Increasing the disk (`upsun resources:set --disk DB_SERVICE:SIZE_MB`) is often the simplest fix, and may be needed before any rebuild if the disk is nearly full. It triggers a deployment and changes the project's cost: confirm first.

Deleting rows does not shrink files. It leaves free space inside the table, which the database reuses for new rows. To reduce the disk used, the table must be rebuilt. Before rebuilding, check whether the application can purge data it does not need (logs, caches, sessions, queues), using its own tools, with the user's confirmation.

## 2. Diagnose MySQL and MariaDB

Largest tables, with their free extents:

```sql
SELECT TABLE_SCHEMA, TABLE_NAME, ENGINE, TABLE_ROWS,
       ROUND(DATA_LENGTH / 1048576) AS data_mib,
       ROUND(INDEX_LENGTH / 1048576) AS index_mib,
       ROUND(DATA_FREE / 1048576) AS free_mib
  FROM information_schema.TABLES
 WHERE TABLE_TYPE = 'BASE TABLE'
   AND TABLE_SCHEMA NOT IN ('mysql', 'information_schema', 'performance_schema', 'sys')
 ORDER BY DATA_LENGTH + INDEX_LENGTH + DATA_FREE DESC
 LIMIT 20;
```

Interpret these columns with care:

- `DATA_FREE` counts only free extents (whole blocks of about 1 MiB) in the table's file. It misses space freed inside pages, so a table with most rows deleted can show a small `DATA_FREE` and still shrink a lot when rebuilt. Tables with many deletes or updates, such as logs and redirects, can have most of their file as free space.
- `TABLE_ROWS` is an estimate for InnoDB, often off by 10–20%, and can be stale on small tables.
- MySQL 8 caches these statistics for `information_schema_stats_expiry` seconds (default 86400). Prefix the query with `SET SESSION information_schema_stats_expiry = 0;` to read current values (MariaDB has no such variable). `ANALYZE TABLE` refreshes them, but it changes the statistics used for query plans, so it is not a read-only command.

To estimate space freed inside pages, compare the table's size with its live data: average row bytes from a sample of rows (sum of `LENGTH()` of each column), times `TABLE_ROWS`, times about 1.5 for InnoDB overhead. Treat the result as a rough figure. A sample of the first rows can be biased, and reading rows with large `BLOB` or `TEXT` values has a cost.

`upsun db:mysql-optimize` does this estimate and the checks below. It is a beta in [upsun/cli#290](https://github.com/upsun/cli/pull/290), not yet released: check that `upsun db:mysql-optimize --help` works before relying on it. Without `--execute`, it only reports.

## 3. Diagnose PostgreSQL

Largest tables, with dead tuples and vacuum history (current database only):

```sql
SELECT s.schemaname, s.relname,
       pg_size_pretty(pg_total_relation_size(s.relid)) AS total_size,
       pg_size_pretty(pg_indexes_size(s.relid)) AS index_size,
       s.n_live_tup, s.n_dead_tup,
       s.last_vacuum, s.last_autovacuum, s.last_autoanalyze
  FROM pg_stat_user_tables s
 ORDER BY pg_total_relation_size(s.relid) DESC
 LIMIT 20;
```

`pg_total_relation_size` includes indexes and TOAST data. Many dead tuples and an old or empty `last_autovacuum` mean autovacuum is not keeping up, or is blocked. Check for what holds back cleanup:

```sql
SELECT pid, usename, state, age(backend_xmin) AS xmin_age,
       now() - xact_start AS xact_age, left(query, 60) AS query
  FROM pg_stat_activity
 WHERE backend_xmin IS NOT NULL OR backend_xid IS NOT NULL
 ORDER BY greatest(age(backend_xmin), age(backend_xid)) DESC
 LIMIT 10;
SELECT slot_name, active, age(xmin) AS xmin_age, age(catalog_xmin) AS catalog_xmin_age
  FROM pg_replication_slots;
```

Long-running or `idle in transaction` sessions prevent vacuum from removing dead tuples; the oldest are listed first, with the largest `xmin_age`. Without superuser or `pg_read_all_stats` privileges, other roles' sessions show `<insufficient privilege>` and no `state` or `xact_start`, but still show their `xmin_age`: to see what they run, repeat the query with an endpoint with `admin` privileges. A replication slot with an old `xmin` (a large `xmin_age`) also holds back cleanup of all tables; an old `catalog_xmin` holds back only system catalogs. A slot with neither does not block vacuum. Fixing these comes before any rewrite.

Free space inside a table is different from dead tuples: after a plain `VACUUM`, dead tuples become free space that PostgreSQL reuses, but the file keeps its size. A rough estimate from statistics compares the table's size with its live rows:

```sql
SELECT c.relname,
       pg_size_pretty(pg_relation_size(c.oid)) AS heap_size,
       pg_size_pretty((c.reltuples * (28 + w.row_width))::bigint) AS est_live_size
  FROM pg_class c
  JOIN pg_namespace n ON n.oid = c.relnamespace
  JOIN (SELECT schemaname, tablename, sum(avg_width * (1 - null_frac)) AS row_width
          FROM pg_stats WHERE NOT inherited GROUP BY 1, 2) w
    ON w.schemaname = n.nspname AND w.tablename = c.relname
 WHERE c.relkind = 'r' AND c.reltuples > 0
   AND n.nspname NOT IN ('pg_catalog', 'information_schema')
 ORDER BY pg_relation_size(c.oid) DESC
 LIMIT 20;
```

This ignores alignment, page headers, and fillfactor, and depends on recent `ANALYZE` statistics. For a measurement, use the `pgstattuple` extension. The user must enable it in the service configuration, which needs a deployment:

```yaml
services:
  db:
    type: postgresql:<VERSION>
    configuration:
      extensions:
        - pgstattuple
```

Then:

```sql
SELECT * FROM pgstattuple_approx('public.my_table');  -- Uses the visibility map; cheaper.
SELECT * FROM pgstatindex('public.my_table_pkey');    -- B-tree index density.
```

`pgstattuple()` itself reads the whole table: avoid it on large tables in production. If a function fails with a permission error, try an endpoint with `admin` privileges, or use the statistics estimate.

## 4. Check before any rewrite

A rebuild writes a full copy of the table and its indexes before it frees the old one.

- **Disk headroom:** free disk on the service must exceed the rebuilt size (live data plus indexes), with a margin of at least 10% of the disk. For PostgreSQL, add the WAL that the rewrite generates, about the size of the new table, which is on the same disk.
- **`/tmp` headroom (MySQL and MariaDB):** index builds sort in the server's temporary directory, and online rebuilds log concurrent writes there. Check `upsun disk --tmp`.
- **Galera (MariaDB):** `SHOW GLOBAL STATUS LIKE 'wsrep_cluster_size';`. A value above 1 means a Galera cluster, used on Dedicated Generation 2. There, DDL blocks writes on all nodes while it runs, even with `LOCK=NONE`. Do not rebuild unless the user accepts a write outage; suggest a maintenance window or Upsun support.
- **Read-only replicas:** check the services config for `mariadb-replica` or `postgresql-replica` services. MariaDB replicas run the same `ALTER TABLE` after the primary finishes, so they lag by its duration. PostgreSQL replicas replay the rewrite's WAL and its `ACCESS EXCLUSIVE` lock, so reads of that table on the replicas block too, and replica queries may be canceled.
- **Shared tablespace (MySQL and MariaDB):** tables in the shared system tablespace do not have their own file. Rebuilding them does not shrink the shared file, and with `innodb_file_per_table` on, moves the table to its own file, using more disk. Do not rebuild them. With the `PROCESS` privilege, tables with `SPACE = 0` in `information_schema.INNODB_TABLES` (MySQL 8) or `INNODB_SYS_TABLES` (MariaDB) are in it. Without it, use a heuristic: several tables reporting the same non-zero `DATA_FREE` are probably in a shared tablespace, especially if `SELECT @@innodb_file_per_table;` is off or was off when they were created.

## 5. Rebuild MySQL and MariaDB tables

Prefer:

```sql
SET SESSION lock_wait_timeout = 5;
ALTER TABLE `my_table` FORCE, ALGORITHM=INPLACE, LOCK=NONE;
```

- `ALGORITHM=INPLACE, LOCK=NONE` fails instead of locking the table when an online rebuild is not possible. `OPTIMIZE TABLE` falls back to a table copy that blocks writes when an online rebuild is not possible (for example with `FULLTEXT` indexes), so do not use it.
- Tables with `FULLTEXT` or `SPATIAL` indexes cannot be rebuilt online. Check with `SELECT TABLE_NAME, INDEX_NAME, INDEX_TYPE FROM information_schema.STATISTICS WHERE INDEX_TYPE IN ('FULLTEXT', 'SPATIAL');`. Rebuilding them blocks writes: treat this like `VACUUM FULL` below.
- An online rebuild still needs a brief metadata lock at its start and end. While it waits for that lock, for example behind a long query, new queries on the table wait too. A low `lock_wait_timeout` makes it fail instead. If the timeout is reached at the end, the rebuild fails after copying the whole table, and the work is lost. Before rebuilding a large table, check for long transactions and queries (`SHOW FULL PROCESSLIST;`, which shows only the user's own sessions without the `PROCESS` privilege), and do not retry a failed rebuild without telling the user why it failed.
- A rebuild fails if concurrent writes exceed `innodb_online_alter_log_max_size`. Run it when write traffic is low.
- After each table, check the disk again with `upsun disk` before the next one.

When available, `upsun db:mysql-optimize --execute` runs these rebuilds, smallest first, after checking disk and `/tmp` headroom, and refuses on a Galera cluster or a probable shared tablespace. Its `--table` option limits it to specific tables.

## 6. Reclaim PostgreSQL space

- **Plain `VACUUM`** (`VACUUM (VERBOSE, ANALYZE) my_table;`) does not block reads or writes. It makes dead tuples reusable, which stops the table from growing, but returns space to the disk only from empty pages at the end of the file. Run it first, and fix whatever blocks autovacuum. Truncating those pages takes a brief `ACCESS EXCLUSIVE` lock, only if it is free, and stops when other sessions wait for it. Replicas replay that lock, which can cancel their queries: with replicas, consider `VACUUM (VERBOSE, ANALYZE, TRUNCATE false) my_table;`, which frees no disk.
- **`VACUUM FULL`** rewrites the table and its indexes and returns the space. It takes an `ACCESS EXCLUSIVE` lock, which blocks reads as well as writes for its whole duration, needs disk for a full copy, and its WAL is replayed on replicas. Use it only for small tables on a quiet site, with the user's explicit confirmation, and with a lock timeout so that it does not queue behind other sessions:

  ```bash
  upsun sql -p PROJECT_ID -e ENV_ID <<'EOF'
  SET lock_timeout = '5s';
  VACUUM FULL public.my_table;
  EOF
  ```

  Pipe statements on stdin as above. `upsun sql "..."` runs multiple statements in one transaction, and `VACUUM` cannot run inside a transaction.
- **Index bloat:** `REINDEX INDEX CONCURRENTLY my_index;` (PostgreSQL 12+) rebuilds an index without blocking reads or writes. It needs disk for a copy of the index, not of the table. Like `VACUUM`, it cannot run inside a transaction: run it alone in `upsun sql "..."`, or pipe it on stdin after `SET lock_timeout = '5s';` as above, since it still waits for locks held by long transactions. If it fails, it can leave an invalid index with a `_ccnew` or `_ccold` suffix, which must be dropped.
- `pg_repack` and `pg_squeeze` are not available on Upsun.

## Report

Report what was checked, each table's size and estimated reclaimable space with its source, the headroom, and any blockers (Galera, replicas, shared tablespace, long transactions). After changes, report the disk usage before and after, and anything left to do.
