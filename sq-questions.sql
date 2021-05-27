-- Get tables

SELECT tbl_name AS table_name
FROM sqlite_schema
WHERE type = 'table';

-- Get columns

SELECT
    '' AS schema -- Schema
    ,'customer' AS "table" -- Table
    ,ti.name -- Name
    ,ti."type" -- Type
    ,ti."notnull" AS not_null -- NotNull
    ,ti.pk AS is_primary_key -- IsPrimaryKey
    ,fkl."table" IS NOT NULL AS is_foreign_key -- IsForeignKey
    ,CASE WHEN unique_columns.cid IS NULL THEN FALSE ELSE TRUE END AS is_unique -- IsUnique
    ,ti."type" = 'INTEGER' AND ti.pk AS is_autoincrement -- IsAutoincrement
    ,ti.dflt_value AS "default" -- Default
    ,fkl."table" AS references_table -- ReferencesTable
    ,fkl."to" AS references_column -- ReferencesColumn
    ,fkl.on_update AS references_on_update -- ReferencesOnUpdate
    ,fkl.on_delete AS references_on_delete -- ReferencesOnDelete
FROM
    pragma_table_info('customer') AS ti
    LEFT JOIN (
        SELECT
            *
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
    ) AS unique_columns ON unique_columns.cid = ti.cid
    LEFT JOIN pragma_foreign_key_list('customer') AS fkl ON fkl."from" = ti.name
;

-- Get indices

SELECT
	il.name -- Name
	,il."unique" -- Mode
	,il.partial -- Predicate
	,ii.seqno -- Column Rank
	,ii.cid -- Column Expression
	,ii.name AS col_name -- Column Name
FROM
	pragma_index_list(?) AS il
	CROSS JOIN pragma_index_info(il.name) AS ii
WHERE
	origin <> 'u'
ORDER BY
	il.name
	,ii.seqno
;
