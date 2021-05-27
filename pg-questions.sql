-- Get tables

SELECT table_schema, table_name
FROM information_schema.tables
WHERE table_type = 'BASE TABLE' AND table_schema NOT IN ('pg_catalog', 'information_schema');

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
        ,COUNT(*) OVER (PARTITION BY constraint_name) AS num_columns
    FROM
        information_schema.constraint_column_usage AS ccu
        JOIN information_schema.table_constraints AS tc USING (constraint_schema, constraint_name)
    WHERE
        tc.constraint_type = 'UNIQUE'
)
SELECT
    columns.table_schema AS schema -- Schema
    ,columns.table_name AS "table" -- Table
    ,columns.column_name AS name -- Name
    ,columns.data_type AS type_1 -- Type
    ,columns.udt_name AS type_2 -- Type
    ,columns.numeric_precision -- Type
    ,columns.numeric_scale -- Type
    ,NOT columns.is_nullable::BOOLEAN AS not_null -- NotNull
    ,pkey_columns.column_name IS NOT NULL AS is_primary_key -- IsPrimaryKey
    ,fkey_columns.ref_table IS NOT NULL AS is_foreign_key -- IsForeignKey
    ,unique_columns.column_name IS NOT NULL AS is_unique -- IsUnique
    ,COALESCE(columns.is_identity::BOOLEAN OR columns.column_default = format('nextval(''%s_%s_seq''::regclass)', columns.table_name, columns.column_name), FALSE) AS is_autoincrement -- IsAutoincrement
    ,CASE columns.column_default
        WHEN format('nextval(''%s_%s_seq''::regclass)', columns.table_name, columns.column_name) THEN NULL
        ELSE columns.column_default
    END AS "default" -- Default
    ,fkey_columns.ref_schema AS references_schema -- ReferencesSchema
    ,fkey_columns.ref_table AS references_table -- ReferencesTable
    ,fkey_columns.ref_column AS references_column -- ReferencesColumn
    ,fkey_columns.update_rule AS references_on_update -- ReferencesOnUpdate
    ,fkey_columns.delete_rule AS references_on_delete -- ReferencesOnDelete
FROM
    information_schema.columns
    LEFT JOIN pkey_columns USING (table_schema, table_name, column_name)
    LEFT JOIN fkey_columns USING (table_schema, table_name, column_name)
    LEFT JOIN unique_columns ON
        unique_columns.table_schema = columns.table_schema
        AND unique_columns.table_name = columns.table_name
        AND unique_columns.column_name = columns.column_name
        AND unique_columns.num_columns = 1
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
