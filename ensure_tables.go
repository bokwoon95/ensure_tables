package ensure_tables

import (
	_ "github.com/mattn/go-sqlite3"
)

type Foo interface {
	GetTableNames() (tableNames []QualifiedName, err error)
	GetColumns(tableName QualifiedName) (columns map[string]Column, err error)
	GetIndices(tableName QualifiedName)
}

type QualifiedName struct{ Schema, Name string }

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
	Table            QualifiedName
	Name             string
	Type             string
	Default          string
	NotNull          bool
	IsPrimaryKey     bool
	IsForeignKey     bool
	IsUnique         bool
	IsAutoincrement  bool
	ReferencesTable  QualifiedName
	ReferencesColumn string
}

type Index struct {
	Table     QualifiedName
	Name      QualifiedName
	Type      string // BTREE | HASH | GIST | SPGIST | GIN | BRIN | FULLTEXT | SPATIAL
	IsUnique  bool
	IsPartial bool
	Columns   []IndexColumn
}

type IndexColumn struct {
	Column     string
	Expression string
	Rank       int
	Modifiers  string
}

type Table struct {
	Schema  string
	Name    string
	Columns []Column
	Indices []Index
}
