package metadata

import (
	"fmt"
	"strings"
	"unicode"
	"unicode/utf8"
)

func cutValue(s string) (value, rest string, err error) {
	s = strings.TrimLeft(s, " \t\n\v\f\r\u0085\u00A0")
	if s == "" {
		return "", "", nil
	}
	var bracelevel, splitAt int
	isBraceQuoted := s[0] == '{'
	for i := 0; i < len(s); {
		r, size := utf8.DecodeRuneInString(s[i:])
		i += size
		splitAt = i
		switch r {
		case '{':
			bracelevel++
		case '}':
			bracelevel--
		}
		if bracelevel < 0 {
			return "", "", fmt.Errorf("too many closing braces")
		}
		if bracelevel == 0 && isBraceQuoted {
			break
		}
		if bracelevel == 0 && unicode.IsSpace(r) {
			splitAt -= size
			break
		}
	}
	if bracelevel > 0 {
		return "", "", fmt.Errorf("unclosed brace")
	}
	value = s[:splitAt]
	rest = s[splitAt:]
	if isBraceQuoted {
		value = value[1 : len(value)-1]
	}
	return value, rest, nil
}

func lexValue(s string) (value string, modifiers [][2]string, err error) {
	value, rest, err := cutValue(s)
	if err != nil {
		return "", nil, err
	}
	modifiers, err = lexModifiers(rest)
	if err != nil {
		return "", nil, err
	}
	return value, modifiers, err
}

func lexModifiers(s string) (modifiers [][2]string, err error) {
	value, rest := "", s
	for rest != "" {
		value, rest, err = cutValue(rest)
		if err != nil {
			return nil, err
		}
		subname, subvalue := value, ""
		if i := strings.Index(value, "="); i >= 0 {
			subname, subvalue = value[:i], value[i+1:]
			if subvalue[0] == '{' {
				subvalue = subvalue[1 : len(subvalue)-1]
			}
		}
		modifiers = append(modifiers, [2]string{subname, subvalue})
	}
	return modifiers, nil
}
