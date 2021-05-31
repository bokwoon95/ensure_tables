package metadata

import "bytes"

type tableinfo [2]string

func (t tableinfo) GetSchema() string { return t[0] }
func (t tableinfo) GetName() string   { return t[1] }

type field string
type blobfield struct{ field }
type booleanfield struct{ field }
type jsonfield struct{ field }
type numberfield struct{ field }
type stringfield struct{ field }
type timefield struct{ field }

func (f field) GetName() string { return string(f) }
func (f field) AppendSQLExclude(dialect string, buf *bytes.Buffer, args *[]interface{}, params map[string][]int, excludedTableQualifiers []string) error {
	buf.WriteString(string(f))
	return nil
}
func (f blobfield) GetType() string    { return "blob" }
func (f booleanfield) GetType() string { return "boolean" }
func (f jsonfield) GetType() string    { return "json" }
func (f numberfield) GetType() string  { return "number" }
func (f stringfield) GetType() string  { return "string" }
func (f timefield) GetType() string    { return "time" }

type _ACTOR struct {
	tableinfo          `ddl:"name=actor"`
	ACTOR_ID           numberfield `ddl:"type=INTEGER primarykey"`
	FIRST_NAME         stringfield `ddl:"notnull"`
	LAST_NAME          stringfield `ddl:"notnull index"`
	FULL_NAME          stringfield `ddl:"generated={{first_name || ' ' || last_name} virtual}"`
	FULL_NAME_REVERSED stringfield `ddl:"generated={{last_name || ' ' || first_name} stored}"`
	LAST_UPDATE        timefield   `ddl:"default=DATETIME('now') notnull"`
}

func (ACTOR _ACTOR) Constraints(dialect string, c *C) {
	switch dialect {
	case "postgres":
		c.TableSchema("public")
		c.Col(ACTOR.ACTOR_ID, c.Autoincrement(AutoincrementDefaultIdentity))
		c.Col(ACTOR.FULL_NAME_REVERSED, c.Generated("last_name || ' ' || first_name", true))
		c.Col(ACTOR.LAST_UPDATE, c.Type("TIMESTAMPTZ"), c.Default("NOW()"))
	case "mysql":
		c.TableSchema("db")
		c.Col(ACTOR.ACTOR_ID, c.Autoincrement(AutoincrementMySQL))
		c.Col(ACTOR.FIRST_NAME, c.Type("VARCHAR(45)"))
		c.Col(ACTOR.LAST_NAME, c.Type("VARCHAR(45)"))
		c.Col(ACTOR.FULL_NAME, c.Type("VARCHAR(45)"), c.Generated("CONCAT(first_name, ' ', last_name)", false))
		c.Col(ACTOR.FULL_NAME_REVERSED, c.Type("VARCHAR(45)"), c.Generated("CONCAT(last_name, ' ', first_name)", true))
		c.Col(ACTOR.LAST_UPDATE, c.Type("TIMESTAMP"), c.Default("CURRENT_TIMESTAMP"), c.OnUpdateCurrentTimestamp)
	}
}

type _CATEGORY struct {
	tableinfo   `ddl:"name=category"`
	CATEGORY_ID numberfield `ddl:"type=INTEGER primarykey"`
	NAME        stringfield `ddl:"notnull"`
	LAST_UPDATE timefield   `ddl:"default=DATETIME('now') notnull"`
}

func (CATEGORY _CATEGORY) Constraints(dialect string, c *C) {
	switch dialect {
	case "postgres":
		c.TableSchema("public")
		c.Col(CATEGORY.CATEGORY_ID, c.Autoincrement(AutoincrementDefaultIdentity))
		c.Col(CATEGORY.LAST_UPDATE, c.Type("TIMESTAMPTZ"), c.Default("NOW()"))
	case "mysql":
		c.TableSchema("db")
		c.Col(CATEGORY.CATEGORY_ID, c.Autoincrement(AutoincrementMySQL))
		c.Col(CATEGORY.NAME, c.Type("VARCHAR(25)"))
		c.Col(CATEGORY.LAST_UPDATE, c.Type("TIMESTAMP"), c.Default("CURRENT_TIMESTAMP"), c.OnUpdateCurrentTimestamp)
	}
}

type _COUNTRY struct {
	tableinfo   `ddl:"name=country"`
	COUNTRY_ID  numberfield `ddl:"type=INTEGER primarykey"`
	COUNTRY     stringfield `ddl:"notnull"`
	LAST_UPDATE timefield   `ddl:"default=DATETIME('now') notnull"`
}

func (COUNTRY _COUNTRY) Constraints(dialect string, c *C) {
	switch dialect {
	case "postgres":
		c.TableSchema("public")
		c.Col(COUNTRY.COUNTRY_ID, c.Autoincrement(AutoincrementDefaultIdentity))
		c.Col(COUNTRY.LAST_UPDATE, c.Type("TIMESTAMPTZ"), c.Default("NOW()"))
	case "mysql":
		c.TableSchema("db")
		c.Col(COUNTRY.COUNTRY_ID, c.Autoincrement(AutoincrementMySQL))
		c.Col(COUNTRY.COUNTRY, c.Type("VARCHAR(50)"))
		c.Col(COUNTRY.LAST_UPDATE, c.Type("TIMESTAMP"), c.Default("CURRENT_TIMESTAMP"), c.OnUpdateCurrentTimestamp)
	}
}

type _CITY struct {
	tableinfo   `ddl:"name=city"`
	CITY_ID     numberfield `ddl:"type=INTEGER primarykey"`
	CITY        stringfield `ddl:"notnull"`
	COUNTRY_ID  numberfield `ddl:"notnull references={country onupdate=cascade ondelete=restrict} index"`
	LAST_UPDATE timefield   `ddl:"default=DATETIME('now') notnull"`
}

func (CITY _CITY) Constraints(dialect string, c *C) {
	switch dialect {
	case "postgres":
		c.TableSchema("public")
		c.Col(CITY.CITY_ID, c.Autoincrement(AutoincrementDefaultIdentity))
		c.Col(CITY.LAST_UPDATE, c.Type("TIMESTAMPTZ"), c.Default("NOW()"))
	case "mysql":
		c.TableSchema("db")
		c.Col(CITY.CITY_ID, c.Autoincrement(AutoincrementMySQL))
		c.Col(CITY.CITY, c.Type("VARCHAR(50)"))
		c.Col(CITY.LAST_UPDATE, c.Type("TIMESTAMP"), c.Default("CURRENT_TIMESTAMP"), c.OnUpdateCurrentTimestamp)
	}
}

type _ADDRESS struct {
	tableinfo   `ddl:"name=address"`
	ADDRESS_ID  numberfield `ddl:"type=INTEGER primarykey"`
	ADDRESS     stringfield `ddl:"notnull"`
	ADDRESS2    stringfield
	DISTRICT    stringfield `ddl:"notnull"`
	CITY_ID     numberfield `ddl:"notnull references={city onupdate=cascade ondelete=restrict} index"`
	POSTAL_CODE stringfield
	PHONE       stringfield `ddl:"notnull"`
	LAST_UPDATE timefield   `ddl:"default=DATETIME('now') notnull"`
}

func (ADDRESS _ADDRESS) Constraints(dialect string, c *C) {
	switch dialect {
	case "postgres":
		c.TableSchema("public")
		c.Col(ADDRESS.ADDRESS_ID, c.Autoincrement(AutoincrementDefaultIdentity))
		c.Col(ADDRESS.LAST_UPDATE, c.Type("TIMESTAMPTZ"), c.Default("NOW()"))
	case "mysql":
		c.TableSchema("db")
		c.Col(ADDRESS.ADDRESS_ID, c.Autoincrement(AutoincrementMySQL))
		c.Col(ADDRESS.ADDRESS, c.Type("VARCHAR(50)"))
		c.Col(ADDRESS.ADDRESS2, c.Type("VARCHAR(50)"))
		c.Col(ADDRESS.DISTRICT, c.Type("VARCHAR(20)"))
		c.Col(ADDRESS.POSTAL_CODE, c.Type("VARCHAR(10)"))
		c.Col(ADDRESS.PHONE, c.Type("VARCHAR(20)"))
		c.Col(ADDRESS.LAST_UPDATE, c.Type("TIMESTAMP"), c.Default("CURRENT_TIMESTAMP"), c.OnUpdateCurrentTimestamp)
	}
}

type _LANGUAGE struct {
	tableinfo   `ddl:"name=language"`
	LANGUAGE_ID numberfield `ddl:"type=INTEGER primarykey"`
	NAME        stringfield `ddl:"notnull"`
	LAST_UPDATE timefield   `ddl:"default=DATETIME('now') notnull"`
}

func (LANGUAGE _LANGUAGE) Constraints(dialect string, c *C) {
	switch dialect {
	case "postgres":
		c.TableSchema("public")
		c.Col(LANGUAGE.LANGUAGE_ID, c.Autoincrement(AutoincrementDefaultIdentity))
		c.Col(LANGUAGE.LAST_UPDATE, c.Type("TIMESTAMPTZ"), c.Default("NOW()"))
	case "mysql":
		c.TableSchema("db")
		c.Col(LANGUAGE.LANGUAGE_ID, c.Autoincrement(AutoincrementMySQL))
		c.Col(LANGUAGE.NAME, c.Type("CHAR(20)"))
		c.Col(LANGUAGE.LAST_UPDATE, c.Type("TIMESTAMP"), c.Default("CURRENT_TIMESTAMP"), c.OnUpdateCurrentTimestamp)
	}
}

type _FILM struct {
	tableinfo            `ddl:"name=film"`
	FILM_ID              numberfield `ddl:"type=INTEGER primarykey"`
	TITLE                stringfield `ddl:"notnull index"`
	DESCRIPTION          stringfield
	RELEASE_YEAR         numberfield
	LANGUAGE_ID          numberfield `ddl:"notnull references={language onupdate=cascade ondelete=restrict} index"`
	ORIGINAL_LANGUAGE_ID numberfield `ddl:"references={language onupdate=cascade ondelete=restrict} index"`
	RENTAL_DURATION      numberfield `ddl:"default=3 notnull"`
	RENTAL_RATE          numberfield `ddl:"type=DECIMAL(4,2) default=4.99 notnull"`
	LENGTH               numberfield
	REPLACEMENT_COST     numberfield `ddl:"type=DECIMAL(5,2) default=19.99 notnull"`
	RATING               stringfield `ddl:"default='G'"`
	SPECIAL_FEATURES     jsonfield
	LAST_UPDATE          timefield   `ddl:"default=DATETIME('now') notnull"`
	FULLTEXT             stringfield `ddl:"notnull"`
}

func (FILM _FILM) Constraints(dialect string, c *C) {
	switch dialect {
	case "postgres":
		c.TableSchema("public")
		c.Col(FILM.FILM_ID, c.Autoincrement(AutoincrementDefaultIdentity))
		c.Col(FILM.RELEASE_YEAR, c.Type("year"))
		c.Col(FILM.RATING, c.Type("mpaa_rating"), c.Default("'G'::mpaa_rating"))
		c.Col(FILM.LAST_UPDATE, c.Type("TIMESTAMPTZ"), c.Default("NOW()"))
		c.Col(FILM.SPECIAL_FEATURES, c.Type("TEXT[]")) // TODO: ArrayField
		c.Col(FILM.FULLTEXT, c.Type("TSVECTOR"))
	case "mysql":
		c.TableSchema("db")
		c.Col(FILM.FILM_ID, c.Autoincrement(AutoincrementMySQL))
		c.Col(FILM.TITLE, c.Type("VARCHAR(255)"))
		c.Col(FILM.DESCRIPTION, c.Type("TEXT"))
		c.Col(FILM.RATING, c.Type("ENUM('G','PG','PG-13','R','NC-17')"))
		c.Col(FILM.LAST_UPDATE, c.Type("TIMESTAMP"), c.Default("CURRENT_TIMESTAMP"), c.OnUpdateCurrentTimestamp)
		c.CheckString("film_release_year_check", "release_year >= 1901 AND release_year <= 2155")
	case "sqlite3":
		c.CheckString("film_release_year_check", "release_year >= 1901 AND release_year <= 2155")
		c.CheckString("film_rating_check", "rating IN ('G','PG','PG-13','R','NC-17')")
	}
}

type _FILM_TEXT struct {
	tableinfo   `ddl:"name=film_text fts5={content='film' content_rowid='film_id'}"`
	FILM_ID     numberfield
	TITLE       stringfield
	DESCRIPTION stringfield
}

func (FILM_TEXT _FILM_TEXT) Constraints(dialect string, c *C) {
	switch dialect {
	case "postgres":
		// no-op, we will ignore this table if postgres
	case "mysql":
		c.Col(FILM_TEXT.TITLE, c.Type("VARCHAR(255)"), c.NotNull(true))
		c.Index("", "", "FULLTEXT", FILM_TEXT.TITLE, FILM_TEXT.DESCRIPTION)
	case "sqlite3":
		c.Col(FILM_TEXT.FILM_ID, c.Type("\x00"))
	}
}

type _FILM_ACTOR struct {
	tableinfo   `ddl:"name=film_actor index={. cols=actor_id,film_id unique}"`
	ACTOR_ID    numberfield `ddl:"notnull references={actor onupdate=cascade ondelete=restrict}"`
	FILM_ID     numberfield `ddl:"notnull references={film onupdate=cascade ondelete=restrict} index"`
	LAST_UPDATE timefield   `ddl:"default=DATETIME('now') notnull"`
}

func (FILM_ACTOR _FILM_ACTOR) Constraints(dialect string, c *C) {
	switch dialect {
	case "postgres":
		c.Col(FILM_ACTOR.LAST_UPDATE, c.Type("TIMESTAMPTZ"), c.Default("NOW()"))
	case "mysql":
		c.Col(FILM_ACTOR.LAST_UPDATE, c.Type("TIMESTAMP"), c.Default("CURRENT_TIMESTAMP"), c.OnUpdateCurrentTimestamp)
	}
}

type _FILM_CATEGORY struct {
	tableinfo   `ddl:"name=film_category"`
	FILM_ID     numberfield `ddl:"notnull references={film onupdate=cascade ondelete=restrict}"`
	CATEGORY_ID numberfield `ddl:"notnull references={category onupdate=cascade ondelete=restrict}"`
	LAST_UPDATE timefield   `ddl:"default=DATETIME('now') notnull"`
}

func (FILM_CATEGORY _FILM_CATEGORY) Constraints(dialect string, c *C) {
	switch dialect {
	case "postgres":
		c.Col(FILM_CATEGORY.LAST_UPDATE, c.Type("TIMESTAMPTZ"), c.Default("NOW()"))
	case "mysql":
		c.Col(FILM_CATEGORY.LAST_UPDATE, c.Type("TIMESTAMP"), c.Default("CURRENT_TIMESTAMP"), c.OnUpdateCurrentTimestamp)
	}
}

type _STAFF struct {
	tableinfo   `ddl:"name=staff"`
	STAFF_ID    numberfield `ddl:"type=INTEGER primarykey"`
	FIRST_NAME  stringfield `ddl:"notnull"`
	LAST_NAME   stringfield `ddl:"notnull"`
	ADDRESS_ID  numberfield `ddl:"notnull references={address onupdate=cascade ondelete=restrict}"`
	EMAIL       stringfield
	STORE_ID    numberfield  `ddl:"references=store"`
	ACTIVE      booleanfield `ddl:"default=TRUE notnull"`
	USERNAME    stringfield  `ddl:"notnull"`
	PASSWORD    stringfield
	LAST_UPDATE timefield `ddl:"default=DATETIME('now') notnull"`
	PICTURE     blobfield
}

func (STAFF _STAFF) Constraints(dialect string, c *C) {
	switch dialect {
	case "postgres":
		c.Col(STAFF.STAFF_ID, c.Autoincrement(AutoincrementDefaultIdentity))
		c.Col(STAFF.LAST_UPDATE, c.Type("TIMESTAMPTZ"), c.Default("NOW()"))
		c.Col(STAFF.PICTURE, c.Type("BYTEA"))
	case "mysql":
		c.Col(STAFF.STAFF_ID, c.Autoincrement(AutoincrementMySQL))
		c.Col(STAFF.FIRST_NAME, c.Type("VARCHAR(45)"))
		c.Col(STAFF.LAST_NAME, c.Type("VARCHAR(45)"))
		c.Col(STAFF.EMAIL, c.Type("VARCHAR(50)"))
		c.Col(STAFF.USERNAME, c.Type("VARCHAR(16)"))
		c.Col(STAFF.PASSWORD, c.Type("VARCHAR(40)"))
		c.Col(STAFF.LAST_UPDATE, c.Type("TIMESTAMP"), c.Default("CURRENT_TIMESTAMP"), c.OnUpdateCurrentTimestamp)
	}
}

type _STORE struct {
	tableinfo        `ddl:"name=store"`
	STORE_ID         numberfield `ddl:"type=INTEGER primarykey"`
	MANAGER_STAFF_ID numberfield `ddl:"notnull references={staff onupdate=cascade ondelete=restrict} index={. unique}"`
	ADDRESS_ID       numberfield `ddl:"notnull references={address onupdate=cascade ondelete=restrict}"`
	LAST_UPDATE      timefield   `ddl:"default=DATETIME('now') notnull"`
}

func (STORE _STORE) Constraints(dialect string, c *C) {
	switch dialect {
	case "postgres":
		c.Col(STORE.STORE_ID, c.Autoincrement(AutoincrementDefaultIdentity))
		c.Col(STORE.LAST_UPDATE, c.Type("TIMESTAMPTZ"), c.Default("NOW()"))
	case "mysql":
		c.Col(STORE.STORE_ID, c.Autoincrement(AutoincrementMySQL))
		c.Col(STORE.LAST_UPDATE, c.Type("TIMESTAMP"), c.Default("CURRENT_TIMESTAMP"), c.OnUpdateCurrentTimestamp)
	}
}

type _CUSTOMER struct {
	tableinfo   `ddl:"name=customer unique={. cols=email,first_name,last_name}"`
	CUSTOMER_ID numberfield  `ddl:"type=INTEGER primarykey"`
	STORE_ID    numberfield  `ddl:"notnull index"`
	FIRST_NAME  stringfield  `ddl:"notnull"`
	LAST_NAME   stringfield  `ddl:"notnull index"`
	EMAIL       stringfield  `ddl:"unique"`
	ADDRESS_ID  numberfield  `ddl:"notnull references={address onupdate=cascade ondelete=restrict} index"`
	ACTIVE      booleanfield `ddl:"default=TRUE notnull"`
	DATA        jsonfield    `ddl:"index={1 order=2 expr={CAST(JSON_EXTRACT(data, '$.age') AS INT)}}"`
	CREATE_DATE timefield    `ddl:"default=DATETIME('now') notnull"`
	LAST_UPDATE timefield    `ddl:"default=DATETIME('now')"`
}

func (CUSTOMER _CUSTOMER) Constraints(dialect string, c *C) {
	switch dialect {
	case "postgres":
		c.Col(CUSTOMER.CUSTOMER_ID, c.Autoincrement(AutoincrementDefaultIdentity))
		c.Col(CUSTOMER.CREATE_DATE, c.Type("TIMESTAMPTZ"), c.Default("NOW()"))
		c.Col(CUSTOMER.LAST_UPDATE, c.Type("TIMESTAMPTZ"), c.Default("NOW()"))
	case "mysql":
		c.Col(CUSTOMER.CUSTOMER_ID, c.Autoincrement(AutoincrementMySQL))
		c.Col(CUSTOMER.FIRST_NAME, c.Type("VARCHAR(45)"))
		c.Col(CUSTOMER.LAST_NAME, c.Type("VARCHAR(45)"))
		c.Col(CUSTOMER.EMAIL, c.Type("VARCHAR(50)"))
		c.Col(CUSTOMER.CREATE_DATE, c.Type("TIMESTAMP"), c.Default("CURRENT_TIMESTAMP"))
		c.Col(CUSTOMER.LAST_UPDATE, c.Type("TIMESTAMP"), c.Default("CURRENT_TIMESTAMP"), c.OnUpdateCurrentTimestamp)
	}
}

type _INVENTORY struct {
	tableinfo    `ddl:"name=inventory index={. cols=store_id,film_id}"`
	INVENTORY_ID numberfield `ddl:"type=INTEGER primarykey"`
	FILM_ID      numberfield `ddl:"notnull references={film onupdate=cascade ondelete=restrict}"`
	STORE_ID     numberfield `ddl:"notnull references={store onupdate=cascade ondelete=restrict}"`
	LAST_UPDATE  timefield   `ddl:"default=DATETIME('now') notnull"`
}

func (INVENTORY _INVENTORY) Constraints(dialect string, c *C) {
	switch dialect {
	case "postgres":
		c.Col(INVENTORY.INVENTORY_ID, c.Autoincrement(AutoincrementDefaultIdentity))
		c.Col(INVENTORY.LAST_UPDATE, c.Type("TIMESTAMPTZ"), c.Default("NOW()"))
	case "mysql":
		c.Col(INVENTORY.INVENTORY_ID, c.Autoincrement(AutoincrementMySQL))
		c.Col(INVENTORY.LAST_UPDATE, c.Type("TIMESTAMP"), c.Default("CURRENT_TIMESTAMP"), c.OnUpdateCurrentTimestamp)
	}
}

type _RENTAL struct {
	tableinfo    `ddl:"name=rental index={. cols=rental_date,inventory_id,customer_id unique}"`
	RENTAL_ID    numberfield `ddl:"type=INTEGER primarykey"`
	RENTAL_DATE  timefield   `ddl:"notnull"`
	INVENTORY_ID numberfield `ddl:"notnull index references={inventory onupdate=cascade ondelete=restrict}"`
	CUSTOMER_ID  numberfield `ddl:"notnull index references={customer onupdate=cascade ondelete=restrict}"`
	RETURN_DATE  timefield
	STAFF_ID     numberfield `ddl:"notnull index references={staff onupdate=cascade ondelete=restrict}"`
	LAST_UPDATE  timefield   `ddl:"default=DATETIME('now') notnull"`
}

func (RENTAL _RENTAL) Constraints(dialect string, c *C) {
	switch dialect {
	case "postgres":
		c.Col(RENTAL.RENTAL_ID, c.Autoincrement(AutoincrementDefaultIdentity))
		c.Col(RENTAL.RETURN_DATE, c.Type("TIMESTAMPTZ"))
		c.Col(RENTAL.LAST_UPDATE, c.Type("TIMESTAMPTZ"), c.Default("NOW()"))
	case "mysql":
		c.Col(RENTAL.RENTAL_ID, c.Autoincrement(AutoincrementMySQL))
		c.Col(RENTAL.RETURN_DATE, c.Type("TIMESTAMP"))
		c.Col(RENTAL.LAST_UPDATE, c.Type("TIMESTAMP"), c.Default("CURRENT_TIMESTAMP"), c.OnUpdateCurrentTimestamp)
	}
}

type _PAYMENT struct {
	tableinfo    `ddl:"name=payment"`
	PAYMENT_ID   numberfield `ddl:"type=INTEGER primarykey"`
	CUSTOMER_ID  numberfield `ddl:"notnull index references={customer onupdate=cascade ondelete=restrict}"`
	STAFF_ID     numberfield `ddl:"notnull index references={staff onupdate=cascade ondelete=restrict}"`
	RENTAL_ID    numberfield `ddl:"references={rental onupdate=cascade ondelete=restrict}"`
	AMOUNT       numberfield `ddl:"type=DECIMAL(5,2) notnull"`
	PAYMENT_DATE timefield   `ddl:"notnull"`
}

func (PAYMENT _PAYMENT) Constraints(dialect string, c *C) {
	switch dialect {
	case "postgres":
		c.Col(PAYMENT.PAYMENT_ID, c.Autoincrement(AutoincrementDefaultIdentity))
		c.Col(PAYMENT.PAYMENT_DATE, c.Type("TIMESTAMPTZ"))
	case "mysql":
		c.Col(PAYMENT.PAYMENT_ID, c.Autoincrement(AutoincrementMySQL))
		c.Col(PAYMENT.PAYMENT_DATE, c.Type("TIMESTAMP"))
	}
}

type _DUMMY_TABLE struct {
	tableinfo `ddl:"name=dummy_table primarykey={. cols=id1,id2} unique={. cols=score,color}"`
	ID1       numberfield
	ID2       stringfield
	SCORE     numberfield
	COLOR     stringfield `ddl:"collate=nocase default='red'"`
	DATA      jsonfield
}

func (DUMMY_TABLE _DUMMY_TABLE) Constraints(dialect string, c *C) {
	c.CheckString("dummy_table_score_positive_check", "score > 0")
	c.CheckString("dummy_table_score_id1_greater_than_check", "score > id1")
	switch dialect {
	case "postgres":
		// TODO: I need an internal fieldf function for expressions
		// TODO: I need a more ergonomic way of expressing index constraints, don't want to keep repeating empty schema string and empty type string (always btree)
		// TODO: I also need a way of optionally expressing WHERE and INCLUDE for CREATE INDEX statements
		// TODO: OH NO: if I pass in a standalone field without the table there is literally no way for me to figure out which struct field the field came from :(
		//       unless...? I use reflection to set the field values? No it's too much. --REQUIRE-- the user to initialize the tables before passing it into AutoMigrate
		//       this changes everything. NewWantTables no longer utilizes reflect to obtain the field name.
		//       this means every table I am declaring here needs a corresponding constructor.
		c.Index("", "", "", DUMMY_TABLE.SCORE, nil, DUMMY_TABLE.COLOR)
	case "mysql":
	case "sqlite3":
	}
}
