-- Get tables

SELECT table_schema, table_name
FROM information_schema.tables
WHERE table_type = 'BASE TABLE' AND table_schema NOT IN ('mysql', 'performance_schema', 'sys');

-- Get columns

WITH fkey_columns AS (
    SELECT
        tc.table_schema
        ,tc.table_name
        ,kcu.column_name
        ,kcu.referenced_table_schema
        ,kcu.referenced_table_name
        ,kcu.referenced_column_name
        ,rc.update_rule
        ,rc.delete_rule
        ,rc.match_option
    FROM
        information_schema.table_constraints AS tc
        JOIN information_schema.key_column_usage AS kcu USING (constraint_schema, constraint_name)
        JOIN information_schema.referential_constraints AS rc USING (constraint_schema, constraint_name)
    WHERE
        tc.constraint_type = 'FOREIGN KEY'
)
SELECT
    columns.table_schema -- TableSchema
    ,columns.table_name -- TableName
    ,columns.column_name -- ColumnName
    ,columns.data_type AS column_type_1 -- ColumnType
    ,columns.column_type AS column_type_2 -- ColumnType
    ,columns.numeric_precision -- ColumnType
    ,columns.numeric_scale -- ColumnType
    ,NOT columns.is_nullable AS not_null -- NotNull
    ,columns.column_key = 'PRI' AS is_primary_key -- IsPrimaryKey
    ,columns.column_key = 'UNI' AS is_unique -- IsUnique
    ,columns.extra = 'auto_increment' AS is_autoincrement -- IsAutoincrement
    ,columns.column_default -- ColumnDefault
    ,fkey_columns.referenced_table_schema AS references_schema -- ReferencesSchema
    ,fkey_columns.referenced_table_name AS references_table -- ReferencesTable
    ,fkey_columns.referenced_column_name AS references_column -- ReferencesColumn
    ,fkey_columns.update_rule AS references_on_update -- ReferencesOnUpdate
    ,fkey_columns.delete_rule AS references_on_delete -- ReferencesOnDelete
FROM
    information_schema.columns
    LEFT JOIN fkey_columns USING (table_schema, table_name, column_name)
WHERE
    columns.table_schema = 'db'
    AND columns.table_name = 'actor'
;

-- Get indices

WITH indexed_columns AS (
    SELECT
        index_schema
        ,table_schema
        ,table_name
        ,index_name
        ,index_type
        ,NOT non_unique AS is_unique
        ,CASE WHEN expression IS NOT NULL THEN '' ELSE column_name END AS column_name
    FROM
        information_schema.statistics
    WHERE
        statistics.table_schema = 'db'
        AND statistics.table_name = 'rental'
        AND statistics.index_name <> 'PRIMARY'
    ORDER BY
        index_name
        ,seq_in_index
)
SELECT
    table_schema -- TableSchema
    ,table_name -- TableName
    ,index_schema -- IndexSchema
    ,index_name -- IndexName
    ,index_type -- IndexType
    ,is_unique -- IsUnique
    ,json_arrayagg(column_name) AS columns -- Columns
FROM
    indexed_columns
GROUP BY
    table_schema
    ,table_name
    ,index_schema
    ,index_name
    ,index_type
    ,is_unique
;
