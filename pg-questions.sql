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
    columns.table_schema -- TableSchema
    ,columns.table_name -- TableName
    ,columns.column_name -- ColumnName
    ,columns.data_type AS column_type_1 -- ColumnType
    ,columns.udt_name AS column_type_2 -- ColumnType
    ,columns.numeric_precision -- ColumnType
    ,columns.numeric_scale -- ColumnType
    ,NOT columns.is_nullable::BOOLEAN AS not_null -- NotNull
    ,pkey_columns.column_name IS NOT NULL AS is_primary_key -- IsPrimaryKey
    ,unique_columns.column_name IS NOT NULL AS is_unique -- IsUnique
    ,COALESCE(columns.is_identity::BOOLEAN OR columns.column_default = format('nextval(''%s_%s_seq''::regclass)', columns.table_name, columns.column_name), FALSE) AS is_autoincrement -- IsAutoincrement
    ,CASE columns.column_default
        WHEN format('nextval(''%s_%s_seq''::regclass)', columns.table_name, columns.column_name) THEN NULL
        ELSE columns.column_default
    END AS column_default -- ColumnDefault
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

WITH column_names (attnum, attname, attrelid) AS (
    SELECT 0::INT2, NULL, NULL
    UNION
    SELECT attnum, attname, attrelid FROM pg_catalog.pg_attribute
)
,indexed_columns AS (
    SELECT
        table_namespace.nspname AS table_schema
        ,table_info.relname AS table_name
        ,index_namespace.nspname AS index_schema
        ,index_info.relname AS index_name
        ,pg_am.amname AS index_type
        ,pg_index.indisunique AS is_unique
        ,pg_index.indpred IS NOT NULL AS is_partial
        ,COALESCE(column_names.attname, '') AS column_name
    FROM
        pg_catalog.pg_index
        JOIN pg_catalog.pg_class AS index_info ON index_info.oid = pg_index.indexrelid
        JOIN pg_catalog.pg_class AS table_info ON table_info.oid = pg_index.indrelid
        LEFT JOIN column_names ON
            column_names.attnum = ANY(pg_index.indkey)
            AND (column_names.attrelid = table_info.oid OR column_names.attrelid IS NULL)
        JOIN pg_catalog.pg_namespace AS index_namespace ON index_namespace.oid = index_info.relnamespace
        JOIN pg_catalog.pg_namespace AS table_namespace ON table_namespace.oid = table_info.relnamespace
        JOIN pg_catalog.pg_am ON pg_am.oid = index_info.relam
    WHERE
        table_namespace.nspname = 'public'
        AND table_info.relname = 'rental'
        AND NOT pg_index.indisprimary
    ORDER BY
        index_info.relname
        ,array_position(pg_index.indkey, column_names.attnum)
)
SELECT
    table_schema -- TableSchema
    ,table_name -- TableName
    ,index_schema -- IndexSchema
    ,index_name -- IndexName
    ,index_type -- IndexType
    ,is_unique -- IsUnique
    ,is_partial -- IsPartial
    ,json_agg(column_name) AS columns -- Columns
FROM
    indexed_columns
GROUP BY
    table_schema
    ,table_name
    ,index_schema
    ,index_name
    ,index_type
    ,is_unique
    ,is_partial
;
