SELECT * FROM pg_catalog.pg_stat_user_tables  ORDER BY seq_scan desc;

SELECT * FROM pg_catalog.pg_statio_user_tables  ORDER BY heap_blks_read desc;

-- reset statistics
select pg_stat_reset()

-- autovacuum status
select v.*, a.query from pg_stat_progress_vacuum v inner join pg_stat_activity a on  a.pid = v.pid ;

-- list of active running query
SELECT pid, state,  age(clock_timestamp(), query_start), query_start, client_addr, usename, datname, query FROM pg_stat_activity
WHERE query != '<IDLE>' AND query NOT ILIKE '%pg_stat_activity%' AND state = 'active' ORDER BY query_start desc;

-- cancel connections to database
SELECT pg_terminate_backend(pid) 
FROM pg_stat_activity
WHERE state != 'active'  
    AND query NOT ILIKE '%pg_stat_activity%' 
    AND datname = 'inet_structure_10' 
    AND query LIKE 'DEALLOCATE%' 
ORDER BY query_start 
LIMIT 100;

-- TABLE SIZE (filter by like)
SELECT  *, pg_size_pretty(total_bytes) AS total
    , pg_size_pretty(index_bytes) AS INDEX
    , pg_size_pretty(toast_bytes) AS toast
    , pg_size_pretty(table_bytes) AS TABLE
  FROM (
  SELECT *, total_bytes-index_bytes-COALESCE(toast_bytes,0) AS table_bytes FROM (
      SELECT c.oid,nspname AS table_schema, relname AS TABLE_NAME
              , c.reltuples AS row_estimate
              , pg_total_relation_size(c.oid) AS total_bytes
              , pg_indexes_size(c.oid) AS index_bytes
              , pg_total_relation_size(reltoastrelid) AS toast_bytes
          FROM pg_class c
          LEFT JOIN pg_namespace n ON n.oid = c.relnamespace
          WHERE relkind = 'r' 
  ) a
) a
ORDER BY total_bytes DESC;

-- total tables size by LIKE
SELECT SUM(pg_total_relation_size(c.oid)) FROM pg_class c WHERE relkind = 'r' AND relname LIKE '%_remove' ORDER BY 1 DESC;

-- Find unused tables
Select relname from
pg_stat_user_tables
WHERE (idx_tup_fetch + seq_tup_read + seq_scan )= 0;

Select relname from
pg_stat_user_tables
WHERE n_live_tup = 0; 

-- change owner on all tables
SELECT 'ALTER TABLE '|| schemaname || '.' || tablename ||' OWNER TO my_new_owner;'
FROM pg_tables WHERE NOT schemaname IN ('pg_catalog', 'information_schema')
ORDER BY schemaname, tablename;

