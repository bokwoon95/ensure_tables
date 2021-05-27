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
    columns.table_schema AS "schema" -- Schema
    ,columns.table_name AS "table" -- Table
    ,columns.column_name AS name -- Name
    ,columns.data_type AS type_1 -- Type
    ,columns.column_type AS type_2 -- Type
    ,columns.numeric_precision -- Type
    ,columns.numeric_scale -- Type
    ,NOT columns.is_nullable AS not_null -- NotNull
    ,columns.column_key = 'PRI' AS is_primary_key -- IsPrimaryKey
    ,columns.column_key = 'UNI' AS is_unique -- IsUnique
    ,columns.extra = 'auto_increment' AS is_autoincrement -- IsAutoincrement
    ,columns.column_default AS "default" -- Default
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

SELECT
    statistics.index_name -- Name
    ,statistics.non_unique -- Mode
    ,statistics.index_type -- Type
    ,statistics.seq_in_index -- Column Rank
    ,statistics.expression -- Column Expression
    ,statistics.column_name -- Column Name
FROM
    information_schema.statistics
WHERE
    statistics.table_schema = 'db'
    AND statistics.table_name = 'rental'
;
