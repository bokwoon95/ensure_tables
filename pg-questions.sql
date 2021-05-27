-- Get tables

SELECT table_schema, table_name
FROM information_schema.tables
WHERE table_type = 'BASE TABLE' AND table_schema NOT IN ('pg_catalog', 'information_schema');

SELECT schemaname, tablename
FROM pg_catalog.pg_tables
WHERE schemaname NOT IN ('pg_catalog', 'information_schema');

-- Get columns

WITH pkey_columns AS (
    SELECT
        ccu.table_schema
        ,ccu.table_name
        ,ccu.column_name
    FROM
        information_schema.constraint_column_usage AS ccu
        JOIN information_schema.table_constraints AS tc USING (constraint_schema, constraint_name)
    WHERE
        tc.constraint_type = 'PRIMARY KEY'
)
,fkey_columns AS (
    SELECT
        tc.table_schema
        ,tc.table_name
        ,kcu.column_name
        ,ccu.table_schema AS ref_schema
        ,ccu.table_name AS ref_table
        ,ccu.column_name AS ref_column
        ,rc.update_rule
        ,rc.delete_rule
        ,rc.match_option
    FROM
        information_schema.constraint_column_usage AS ccu
        JOIN information_schema.table_constraints AS tc USING (constraint_schema, constraint_name)
        JOIN information_schema.key_column_usage AS kcu USING (constraint_schema, constraint_name)
        JOIN information_schema.referential_constraints AS rc USING (constraint_schema, constraint_name)
    WHERE
        tc.constraint_type = 'FOREIGN KEY'
)
,unique_columns AS (
    SELECT
        ccu.table_schema
        ,ccu.table_name
        ,ccu.column_name
    FROM
        information_schema.constraint_column_usage AS ccu
        JOIN information_schema.table_constraints AS tc USING (constraint_schema, constraint_name)
    WHERE
        tc.constraint_type = 'UNIQUE'
)
SELECT
    columns.column_name -- Name
    ,columns.data_type -- Type
    ,columns.udt_name -- Type
    ,columns.numeric_precision -- Type
    ,columns.numeric_scale -- Type
    ,columns.is_nullable -- NotNull
    ,columns.column_default -- Default / Autoincrement (SERIAL)
    ,CASE WHEN pkey_columns.column_name IS NULL THEN FALSE ELSE TRUE END AS is_primary_key -- PrimaryKey
    ,CASE WHEN unique_columns.column_name IS NULL THEN FALSE ELSE TRUE END AS is_unique -- Unique
    ,columns.is_identity -- Autoincrement (IDENTITY)
    ,fkey_columns.ref_schema -- References
    ,fkey_columns.ref_table -- References
    ,fkey_columns.ref_column -- References
    ,fkey_columns.update_rule -- References
    ,fkey_columns.delete_rule -- References
FROM
    information_schema.columns
    LEFT JOIN pkey_columns USING (table_schema, table_name, column_name)
    LEFT JOIN fkey_columns USING (table_schema, table_name, column_name)
    LEFT JOIN unique_columns USING (table_schema, table_name, column_name)
WHERE
    columns.table_schema = 'public'
    AND columns.table_name = 'actor'
;

-- Get indices

SELECT
    index_info.relname AS name -- Name
    ,pg_index.indisunique AS is_unique -- Mode
    ,pg_am.amname AS "type" -- Type
    ,pg_index.indpred IS NOT NULL AS is_partial -- Predicate
    ,array_position(pg_index.indkey, pg_attribute.attnum) AS seqno -- Column Rank
    ,pg_attribute.attname IS NULL AS is_expression -- Column Expression
    ,pg_attribute.attname AS col_name -- Column Name
FROM
    pg_catalog.pg_index
    JOIN pg_catalog.pg_class AS index_info ON index_info.oid = pg_index.indexrelid
    JOIN pg_catalog.pg_class AS table_info ON table_info.oid = pg_index.indrelid
    LEFT JOIN pg_catalog.pg_attribute ON pg_attribute.attnum = ANY(pg_index.indkey) AND pg_attribute.attrelid = table_info.oid
    JOIN pg_catalog.pg_namespace AS table_namespace ON table_namespace.oid = table_info.relnamespace
    JOIN pg_catalog.pg_am ON pg_am.oid = index_info.relam
WHERE
    table_namespace.nspname = 'public'
    AND table_info.relname = 'rental'
    AND NOT pg_index.indisprimary
ORDER BY
    index_info.relname
    ,seqno
;
