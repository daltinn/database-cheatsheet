-- create distributed table by column
SELECT create_distributed_table('table_name', 'column_name');

-- find all distributed column in table
SELECT column_to_column_name(logicalrelid, partkey) AS dist_col_name
  FROM pg_dist_partition
 WHERE logicalrelid='distributed_table_name'::regclass;

-- get sharded tables
SELECT * FROM pg_catalog.pg_dist_partition;

--
-- add citus node (on devel)
-- on all nodes:
CREATE DATABASE xxxx;
CREATE EXTENSION citus;
-- on master-node
SELECT * from master_add_node('10.0.3.237', 5432);
SELECT * from master_add_node('10.0.3.179', 5432);
-- 

-- create extension on all shards
SELECT master_modify_multiple_shards('create extension if not exist pg_trgm');

-- get citus worker nodes
SELECT * FROM master_get_active_worker_nodes();
