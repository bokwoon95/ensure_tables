package ensure_tables

import (
	"database/sql"

	_ "github.com/mattn/go-sqlite3"
)

type QualifiedName struct{ Schema, Name string }

type Foo interface {
	GetTables() (tables []QualifiedName, err error)
	GetColumns(table QualifiedName) (columns map[string]Column, err error)
	GetIndices(table QualifiedName) (indices map[string]Index, err error)
}

/*
'CREATE-ONLY' options:
(tables)
- Collation
- Character set
(columns)
- Collation
- CHECK constraints
- ON UPDATE CURRENT_TIMESTAMP
(indexes) (indices are resolved by their name anyway)
- Collation
- Expressions
- INCLUDE
*/

type Column struct {
	TableSchema        string
	TableName          string
	ColumnName         string
	ColumnType         string
	NotNull            bool
	IsPrimaryKey       bool
	IsUnique           bool
	IsAutoincrement    bool
	ColumnDefault      sql.NullString
	ReferencesSchema   sql.NullString
	ReferencesTable    sql.NullString
	ReferencesColumn   sql.NullString
	ReferencesOnUpdate sql.NullString
	ReferencesOnDelete sql.NullString
}

type Index struct {
	TableSchema string
	TableName   string
	IndexSchema string
	IndexName   string
	IndexType   string // BTREE | HASH | GIST | SPGIST | GIN | BRIN | FULLTEXT | SPATIAL
	IsUnique    bool
	IsPartial   bool
	Columns     []string
}
