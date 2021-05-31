package metadata

import (
	"testing"

	"github.com/bokwoon95/testutil"
)

func TestCutValue(t *testing.T) {
	assert := func(t *testing.T, s, wantValue, wantRest string) {
		is := testutil.New(t)
		gotValue, gotRest, err := cutValue(s)
		is.NoErr(err)
		is.Equal(wantValue, gotValue)
		is.Equal(wantRest, gotRest)
	}
	assert(t, "", "", "")
	assert(t, "notnull", "notnull", "")
	assert(t, "one two three four", "one", " two three four")
	assert(t, "{notnull}    haha", "notnull", "    haha")
	assert(t, "{lorem ipsum dolor {sit} amet} testing one two three", "lorem ipsum dolor {sit} amet", " testing one two three")
	assert(t, "{one two th}ree four five six", "one two th", "ree four five six")
	is := testutil.New(t)
	_, _, err := cutValue("{")
	is.True(err != nil)
	_, _, err = cutValue("{{}")
	is.True(err != nil)
	_, _, err = cutValue("}")
	is.True(err != nil)
}

func TestLexModifiers(t *testing.T) {
	assert := func(t *testing.T, s string, wantModifiers [][2]string) {
		is := testutil.New(t)
		gotModifiers, err := lexModifiers(s)
		is.NoErr(err)
		is.Equal(wantModifiers, gotModifiers)
	}
	assert(t, "", nil)
	assert(t,
		"notnull index index={1 unique} references={inventory onupdate=cascade ondelete=restrict}",
		[][2]string{
			{"notnull", ""},
			{"index", ""},
			{"index", "1 unique"},
			{"references", "inventory onupdate=cascade ondelete=restrict"},
		},
	)
	assert(t, "index={0 where={email LIKE '%gmail'}}", [][2]string{{"index", "0 where={email LIKE '%gmail'}"}})
}

func TestLexValue(t *testing.T) {
	assert := func(t *testing.T, s string, wantValue string, wantModifiers [][2]string) {
		is := testutil.New(t)
		gotValue, gotModifiers, err := lexValue(s)
		is.NoErr(err)
		is.Equal(wantValue, gotValue)
		is.Equal(wantModifiers, gotModifiers)
	}
	assert(t, "", "", nil)
	assert(t, "1 unique", "1", [][2]string{{"unique", ""}})
	assert(t, "{first_name || ' ' || last_name} virtual", "first_name || ' ' || last_name", [][2]string{{"virtual", ""}})
	assert(t, "inventory onupdate=cascade ondelete=restrict", "inventory", [][2]string{{"onupdate", "cascade"}, {"ondelete", "restrict"}})
	assert(t, "inventory.inventory_id onupdate=setnull", "inventory.inventory_id", [][2]string{{"onupdate", "setnull"}})
	assert(t, "0 where={email LIKE '%gmail'}", "0", [][2]string{{"where", "email LIKE '%gmail'"}})
}
