/**
 * Lib: JSON.ahk
 *     JSON lib for AutoHotkey.
 * Version:
 *     v2.1.3 [updated 04/18/2016 (MM/DD/YYYY)]
 * License:
 *     WTFPL [http://wtfpl.net/]
 * Requirements:
 *     Latest version of AutoHotkey (v1.1+ or v2.0-a+)
 * Installation:
 *     Use #Include JSON.ahk or copy into a function library folder and then
 *     use #Include <JSON>
 * Links:
 *     GitHub:     - https://github.com/cocobelgica/AutoHotkey-JSON
 *     Forum Topic - http://goo.gl/r0zI8t
 *     Email:      - cocobelgica <at> gmail <dot> com
 */

#Warn All, Off
#Include "DotMap.ahk"
/**
 * Class: JSON
 *     The JSON object contains methods for parsing JSON and converting values
 *     to JSON. Callable - NO; Instantiable - YES; Subclassable - YES;
 *     Nestable(via #Include) - NO.
 * Methods:
 *     load() - see relevant documentation before method definition header
 *     Dump() - see relevant documentation before method definition header
 */
class JSON
{
	static load(text, reviver:="") {
		return (JSON._load()).Call(text, reviver)
	}

	static dump(value, replacer:="", space:="2") {
		if (Type(value) == "DotMap")
			value := value.raw()
		return (JSON._dump()).Call(value, replacer, space)
	}

	/**
	 * Method: load
	 *     Parses a JSON string into an AHK value
	 * Syntax:
	 *     value := JSON.load( text [, reviver ] )
	 * Parameter(s):
	 *     value      [retval] - parsed value
	 *     text    [in, ByRef] - JSON formatted string
	 *     reviver   [in, opt] - function object, similar to JavaScript's
	 *                           JSON.parse() 'reviver' parameter
	 */
	class _load extends JSON.Functor
	{
		Call(text, reviver:="")
		{
			this.rev := IsObject(reviver) ? reviver : false
		; Object keys(and array indices) are temporarily stored in arrays so that
		; we can enumerate them in the order they appear in the document/text instead
		; of alphabetically. Skip if no reviver function is specified.
			this.keys := this.rev ? Map() : false

			static quot := Chr(34), bashq := "\" . quot
			     , json_value := quot . "{[01234567890-tfn"
			     , json_value_or_array_closing := quot . "{[]01234567890-tfn"
			     , object_key_or_object_closing := quot . "}"

			key := ""
			resultSet := false
			result := ""
			is_key := false
			u := 0
			root := {}
			stack := [root]
			next := json_value
			pos := 0

			while ((ch := SubStr(text, ++pos, 1)) != "") {
				if InStr(" `t`r`n", ch)
					continue
				if !InStr(next, ch, 1)
					this.ParseError(next, text, pos)

				holder := stack[1]
				is_array := (holder is Array)

				if InStr(",:", ch) {
					next := (is_key := !is_array && ch == ",") ? quot : json_value

				} else if InStr("}]", ch) {
					stack.RemoveAt(1)
					next := (ObjPtr(stack[1]) == ObjPtr(root)) ? "" : (stack[1] is Array) ? ",]" : ",}"

				} else {
					if InStr("{[", ch) {
					if (ch == "{") {
						is_key := true
						value := {}
						next := object_key_or_object_closing
					} else {
						value := []
						next := json_value_or_array_closing
					}
						
						stack.InsertAt(1, value)

						if (this.keys)
							this.keys[value] := []
					
					} else {
						if (ch == quot) {
							i := pos
							while (i := InStr(text, quot,, i+1)) {
								value := StrReplace(SubStr(text, pos+1, i-pos-1), "\\", "\u005c")

								if (SubStr(value, -1) != "\")
									break
							}

							if (!i)
								this.ParseError("'", text, pos)

							value := StrReplace(value,  "\/",  "/")
							value := StrReplace(value, bashq, quot)
							value := StrReplace(value,  "\b", "`b")
							value := StrReplace(value,  "\f", "`f")
							value := StrReplace(value,  "\n", "`n")
							value := StrReplace(value,  "\r", "`r")
							value := StrReplace(value,  "\t", "`t")

							pos := i ; update pos
							
							i := 0
							while (i := InStr(value, "\",, i+1)) {
								if (SubStr(value, i+1, 1) != "u")
									this.ParseError("\", text, pos - StrLen(SubStr(value, i+1)))

								uCode := Abs("0x" . SubStr(value, i+2, 4))
								value := SubStr(value, 1, i-1) . Chr(uCode) . SubStr(value, i+6)
							}

							if (is_key) {
								key := value, next := ":"
								continue
							}
						
						} else {
							value := SubStr(text, pos, i := RegExMatch(text, "[\]\},\s]|$",, pos)-pos)

							if (IsNumber(value))
								value += 0
							else if (value == "true" || value == "false")
								value := (value = "true") ? 1 : 0
							else if (value == "null")
								value := ""
							else
							; we can do more here to pinpoint the actual culprit
							; but that's just too much extra work.
								this.ParseError(next, text, pos, i)

							pos += i-1
						}

						next := (ObjPtr(holder) == ObjPtr(root)) ? "" : is_array ? ",]" : ",}"
					} ; If InStr("{[", ch) { ... } else

					if (is_array)
						key := holder.Push(value)
					else
						holder.%key% := value
					if (ObjPtr(holder) == ObjPtr(root) && !resultSet) {
						result := value
						resultSet := true
					}

					if (this.keys && this.keys.Has(holder))
						this.keys[holder].Push(key)
				}
			
			} ; while ( ... )

			value := this.rev ? this.Walk(root, "") : (resultSet ? result : (ObjHasOwnProp(root, "") ? root[""] : root))
			return (Type(value) == "Object") ? DotMap(value) : value
		}

		ParseError(expect, text, pos, len:=1)
		{
			static quot := Chr(34), qurly := quot . "}"
			
			line := StrSplit(SubStr(text, 1, pos), "`n", "`r").Length()
			col := pos - InStr(text, "`n",, -(StrLen(text)-pos+1))
			msg := Format("{1}`n`nLine:`t{2}`nCol:`t{3}`nChar:`t{4}"
			,     (expect == "")     ? "Extra data"
			    : (expect == "'")    ? "Unterminated string starting at"
			    : (expect == "\")    ? "Invalid \escape"
			    : (expect == ":")    ? "Expecting ':' delimiter"
			    : (expect == quot)   ? "Expecting object key enclosed in double quotes"
			    : (expect == qurly)  ? "Expecting object key enclosed in double quotes or object closing '}'"
			    : (expect == ",}")   ? "Expecting ',' delimiter or object closing '}'"
			    : (expect == ",]")   ? "Expecting ',' delimiter or array closing ']'"
			    : InStr(expect, "]") ? "Expecting JSON value or array closing ']'"
			    :                      "Expecting JSON value(string, number, true, false, null, object or array)"
			, line, col, pos)

			static offset := -4
			throw Exception(msg, offset, SubStr(text, pos, len))
		}

		Walk(holder, key)
		{
			value := holder[key]
			if IsObject(value) {
				for i, k in this.keys[value] {
					; check if ObjHasKey(value, k) ??
					v := this.Walk(value, k)
					if (v != JSON.Undefined)
						value[k] := v
					else
						value.Delete(k)
				}
			}
			
			return this.rev.Call(holder, key, value)
		}
	}

	/**
	 * Method: dump
	 *     Converts an AHK value into a JSON string
	 * Syntax:
	 *     str := JSON.dump( value [, replacer, space ] )
	 * Parameter(s):
	 *     str        [retval] - JSON representation of an AHK value
	 *     value          [in] - any value(object, string, number)
	 *     replacer  [in, opt] - function object, similar to JavaScript's
	 *                           JSON.stringify() 'replacer' parameter
	 *     space     [in, opt] - similar to JavaScript's JSON.stringify()
	 *                           'space' parameter
	 */
	class _dump extends JSON.Functor
	{
		Call(value, replacer:="", space:="2")
		{
			if (Type(value) == "DotMap")
				value := value.raw()
			this.rep := IsObject(replacer) ? replacer : ""

			this.gap := ""
			if (space != "") {
				if (space is Integer || IsInteger(space))
					loop Min(10, Abs(space))
						this.gap .= " "
				else
					this.gap := SubStr(space, 1, 10)

				this.indent := "`n"
			}

			return this.Str(Map("", value), "")
		}

		Str(holder, key)
		{
			value := holder[key]

			if (this.rep)
				value := this.rep.Call(holder, key, ObjHasOwnProp(holder, key) ? value : JSON.Undefined)

			if (value is DotMap)
				value := value.raw()

			if (Type(value) == "Object") {
				objMap := Map()
				for k in value.OwnProps()
					objMap[k] := value.%k%
				value := objMap
			}

			if IsObject(value) {
			; Check object type, skip serialization for other object types such as
			; ComObject, Func, BoundFunc, FileObject, RegExMatchObject, Property, etc.
				if (Type(value) == "Object" || value is Map || value is Array) {
					canEnum := true
					try {
						for k, v in value {
							break
						}
					} catch {
						canEnum := false
					}
					if (!canEnum)
						return "null"

					if (this.gap) {
						stepback := this.indent
						this.indent .= this.gap
					}

					is_array := (value is Array)
				; Array() is not overridden, rollback to old method of
				; identifying array-like objects. Due to the use of a for-loop
				; sparse arrays such as '[1,,3]' are detected as objects({}). 
					if (!is_array) {
						idx := 0
						is_array := true
						for i, v in value {
							idx++
							if (i != idx) {
								is_array := false
								break
							}
						}
						if (idx == 0)
							is_array := false
					}

					str := ""
					if (is_array) {
						loop value.Length {
							if (this.gap)
								str .= this.indent
							
							v := this.Str(value, A_Index)
							str .= (v != "") ? v . "," : "null,"
						}
					} else {
						colon := this.gap ? ": " : ":"
						for k, v in value {
							v := this.Str(value, k)
							if (v != "") {
								if (this.gap)
									str .= this.indent

								str .= this.Quote(k) . colon . v . ","
							}
						}
					}

					if (str != "") {
						str := RTrim(str, ",")
						if (this.gap)
							str .= stepback
					}

					if (this.gap)
						this.indent := stepback

					return is_array ? "[" . str . "]" : "{" . str . "}"
				}
			
			} else ; is_number ? value : "value"
				return IsNumber(value) ? value : this.Quote(value)
		}

		Quote(string)
		{
			static quot := Chr(34), bashq := "\" . quot

			if (string != "") {
				string := StrReplace(string,  "\",  "\\")
				; string := StrReplace(string,  "/",  "\/") ; optional in ECMAScript
				string := StrReplace(string, quot, bashq)
				string := StrReplace(string, "`b",  "\b")
				string := StrReplace(string, "`f",  "\f")
				string := StrReplace(string, "`n",  "\n")
				string := StrReplace(string, "`r",  "\r")
				string := StrReplace(string, "`t",  "\t")

			static rx_escapable := "[^\x20-\x7e]"
				while RegExMatch(string, rx_escapable, &m)
					string := StrReplace(string, m.Value, Format("\u{1:04x}", Ord(m.Value)))
			}

			return quot . string . quot
		}
	}

	/**
	 * Property: Undefined
	 *     Proxy for 'undefined' type
	 * Syntax:
	 *     undefined := JSON.Undefined
	 * Remarks:
	 *     For use with reviver and replacer functions since AutoHotkey does not
	 *     have an 'undefined' type. Returning blank("") or 0 won't work since these
	 *     can't be distnguished from actual JSON values. This leaves us with objects.
	 *     Replacer() - the caller may return a non-serializable AHK objects such as
	 *     ComObject, Func, BoundFunc, FileObject, RegExMatchObject, and Property to
	 *     mimic the behavior of returning 'undefined' in JavaScript but for the sake
	 *     of code readability and convenience, it's better to do 'return JSON.Undefined'.
	 *     Internally, the property returns a ComObject with the variant type of VT_EMPTY.
	 */
	static Undefined {
		get {
			static empty := {}, vt_empty := ComObject(0, &empty, 1)
			return vt_empty
		}
	}

	class Functor
	{
		__Call(method, arg, args*)
		{
		; When casting to Call(), use a new instance of the "function object"
		; so as to avoid directly storing the properties(used across sub-methods)
		; into the "function object" itself.
			if IsObject(method)
				return (new this).Call(method, arg, args*)
			else if (method == "")
				return (new this).Call(arg, args*)
		}
	}
}
