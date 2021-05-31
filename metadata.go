package metadata

import (
	"bytes"
	"database/sql"

	_ "github.com/mattn/go-sqlite3"
)

type Table interface {
	GetSchema() string
	GetName() string
}

type Field interface {
	AppendSQLExclude(dialect string, buf *bytes.Buffer, args *[]interface{}, params map[string][]int, excludedTableQualifiers []string) error
	GetName() string
	GetType() string // blob | boolean | json | number | string | time | expr
	// TODO: if a column professes its type to be "\x00", we must ignore it when trawling for the Columns
}

type Predicate interface {
	AppendSQLExclude(dialect string, buf *bytes.Buffer, args *[]interface{}, params map[string][]int, excludedTableQualifiers []string) error
	Not() Predicate
}

type Column struct {
	TableSchema              string
	TableName                string
	ColumnName               string
	ColumnType               string
	Autoincrement            int // None | ROWID | ROWID_AUTOINCREMENT | IDENTITY | SERIAL | AUTO_INCREMENT
	IsNotNull                bool
	IsPrimaryKey             bool // must not be set for multicolumn primary keys
	IsUnique                 bool
	GeneratedStored          bool           // SQLite cannot provide this info, need to parse DDL
	GeneratedExpr            sql.NullString // SQLite cannot provide this info, need to parse DDL
	Collation                sql.NullString // SQLite cannot provide this info, need to parse DDL
	ColumnDefault            sql.NullString
	ReferencesSchema         sql.NullString
	ReferencesTable          sql.NullString
	ReferencesColumn         sql.NullString
	ReferencesOnUpdate       sql.NullString
	ReferencesOnDelete       sql.NullString
	OnUpdateCurrentTimestamp sql.NullBool
}

type TableConstraint struct {
	TableSchema    string
	TableName      string
	ConstraintName string
	ConstraintType string // PRIMARY KEY | UNIQUE | CHECK
	Columns        []string
	CheckExpr      sql.NullString
}

type Index struct {
	TableSchema string
	TableName   string
	IndexSchema string
	IndexName   string
	IndexType   string // BTREE | HASH | GIST | SPGIST | GIN | BRIN | FULLTEXT | SPATIAL
	IsUnique    bool
	IsPartial   bool
	Where       string
	Columns     []string
	Exprs       []string
	Include     []string
}

type GotTables interface {
	GetTables() (tableNames [][2]string, err error)
	GetColumns(tableName [2]string) (columns map[string]Column, err error)
	GetConstraints(tableName [2]string) (constraints map[string]TableConstraint, err error)
	GetIndices(tableName [2]string) (indices map[[2]string]Index, err error)
}

type WantTables interface {
	GotTables
	CreateTable(tableName [2]string) (querylist []string, argslist [][]interface{}, err error)
	CreateColumn(tableName [2]string, columnName string) (query string, args []interface{}, err error)
	CreateIndex(indexName [2]string) (query string, args []interface{}, err error)
}
