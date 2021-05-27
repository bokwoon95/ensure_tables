-- Get tables

SELECT tbl_name FROM sqlite_schema WHERE type = 'table';

-- Get columns

SELECT
    ti.name AS col_name -- Name
    ,ti.type -- Type
    ,ti."notnull" -- NotNull
    ,ti.dflt_value -- Default
    ,ti.pk -- PrimaryKey
    ,CASE WHEN il."unique" = 1 AND il.origin = 'u' THEN TRUE ELSE FALSE END AS "unique" -- Unique
    ,fkl."table" AS ref_table -- References
    ,fkl."to" AS ref_col -- References
    ,fkl.on_update -- References
    ,fkl.on_delete -- References
FROM
    pragma_table_info('staff') AS ti
    LEFT JOIN (pragma_index_list('staff') AS il, pragma_index_info(il.name) AS ii) ON ii.cid = ti.cid
    LEFT JOIN pragma_foreign_key_list('staff') AS fkl ON fkl."from" = ti.name
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
