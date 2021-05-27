-- Get tables

SELECT tbl_name AS table_name
FROM sqlite_schema
WHERE type = 'table';

-- Get columns

WITH unique_columns AS (
    SELECT
        ii.cid
        ,ii.name
    FROM
        pragma_index_list('customer') AS il, pragma_index_info(il.name) AS ii
    WHERE
        il."unique" = TRUE
        AND il.origin = 'u'
        AND (
            SELECT COUNT(*)
            FROM pragma_index_list('customer') AS il2, pragma_index_info(il.name) AS ii2
            WHERE il2.name = il.name
            GROUP BY il2.name
        ) = 1
)
SELECT
    'customer' AS "table" -- Table
    ,ti.name -- Name
    ,ti."type" -- Type
    ,ti."notnull" AS not_null -- NotNull
    ,ti.pk AS is_primary_key -- IsPrimaryKey
    ,CASE WHEN unique_columns.name IS NULL THEN FALSE ELSE TRUE END AS is_unique -- IsUnique
    ,ti."type" = 'INTEGER' AND ti.pk AS is_autoincrement -- IsAutoincrement
    ,ti.dflt_value AS "default" -- Default
    ,fkl."table" AS references_table -- ReferencesTable
    ,fkl."to" AS references_column -- ReferencesColumn
    ,fkl.on_update AS references_on_update -- ReferencesOnUpdate
    ,fkl.on_delete AS references_on_delete -- ReferencesOnDelete
FROM
    pragma_table_info('customer') AS ti
    LEFT JOIN  unique_columns ON unique_columns.cid = ti.cid
    LEFT JOIN pragma_foreign_key_list('customer') AS fkl ON fkl."from" = ti.name
;

-- Get indices

WITH indexed_columns AS (
    SELECT
        'customer' AS "table"
        ,il.name
        ,il."unique" AS is_unique
        ,il.partial AS is_partial
        ,CASE ii.cid WHEN -1 THEN '' WHEN -2 THEN '' ELSE ii.name END AS column_name
    FROM
        pragma_index_list('customer') AS il
        CROSS JOIN pragma_index_info(il.name) AS ii
    WHERE
        origin <> 'u'
    ORDER BY
        il.name
        ,ii.seqno
)
SELECT
    "table" -- Table
    ,name -- Name
    ,is_unique -- IsUnique
    ,is_partial -- IsPartial
    ,json_group_array(column_name) AS columns -- Columns
FROM
    indexed_columns
GROUP BY
    "table"
    ,name
    ,is_unique
    ,is_partial
;
