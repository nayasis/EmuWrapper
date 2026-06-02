#Requires AutoHotkey >=2.0

/**
 * Windows Registry helper.
 * - Static class; do not instantiate.
 * - Registry.write(file) applies both 32-bit and 64-bit registry views.
 * - Placeholder binding supports both #{name} and ${name} in .reg files.
 * - Registry.clearProps() resets the placeholder map to default path values.
 * - Registry.setProps(Map()) replaces the current placeholder map.
 */
class Registry {

	static prop := Map()
	static _init() {
		Registry.clearProps()
	}
	static void := Registry._init()

	__New() {
	  throw Error("Registry is a static class, don't instantiate it!", -1)
	}

	static getProp(key) {
		return Registry.prop[ key ]
	}

	static setProp(key, value) {
		Registry.prop[ key ] := value
	}

	static setProps(properties) {
		Registry.clearProps()
		if (Type(properties) != "Map")
			return
		for key, value in properties
			Registry.prop[key] := value
	}

	static clearProps() {
		Registry.prop := Map()
		Registry.prop[ "cd"     ] := A_ScriptDir
		Registry.prop[ "cdWin"  ] := RegExReplace(A_ScriptDir, "\\", "\\")
		Registry.prop[ "cdUnix" ] := RegExReplace(A_ScriptDir, "\\", "/")
	}

	/**
	* Write registry entries from a .reg file.
	*
	* Example:
	*   Registry.setProps(Map("gameDir", "D:\Games\MyGame"))
	*   Registry.write("D:\config\sample.reg")
	*
	* @param file {String} filePath containing Windows Registry Editor format
	*/
	static write(file) {
		if !FileExist(file)
			return
		SetRegView(32)
		Registry._setRegistry(file, Registry.prop)
		SetRegView(64)
		Registry._setRegistry(file, Registry.prop)
	}

	/**
	* Internal parser/writer for Windows Registry Editor format.
	* Applies placeholder binding before writing values.
	*
	* @param file       {String} .reg file path
	* @param properties {Map}    placeholder values used for #{name} / ${name}
	*/
	static _setRegistry(file, properties) {

		regKey := ""
		readNextLine := false
		isHex := true

		loop read, file
		{
			line := Trim(A_LoopReadLine)

			if RegExMatch(line, "^Windows Registry Editor" ) {
				continue
			} else if (StrLen(line) == 0) {
				continue
			} else if (RegExMatch(line, "^\[.*\]")) {
				regKey := RegExReplace(line, "^\[(.*)\]", "$1")
				continue
			} else if (regKey == "") {
				continue
			}

			regKey := Registry._bindValue(regKey, properties)

			if ( readNextLine == true ) {
				regVal := regVal line
			} else {
		
				regName := RegExReplace(line, '^(@|".+?")=.*$', '$1')
				regName := RegExReplace(regName, '^"(.+?)"$', '$1')
				regName := StrReplace(regName, '\\"', '"')
				regName := Registry._bindValue( regName, properties )
				regVal := RegExReplace(line, '^(@|".*?")=(.*)$', '$2')
				regVal := StrReplace(regVal, '\\"', '"')
				regType := "REG_SZ"

				if (regName == "@")
					regName := ""

				if RegExMatch(regVal, '^".*"$') {
					regType := "REG_SZ"
					regVal  := Registry._bindValue(RegExReplace(regVal, '^"(.*)"$', '$1'), properties)
					isHex   := false
				} else if RegExMatch(regVal, '^dword:') {
					regType := "REG_DWORD"
					regVal  := RegExReplace(regVal, '^dword:(.*)$', '$1')
					isHex   := false
				} else if RegExMatch(regVal, '^hex\(b\):') {
					regType := "REG_QWORD"
					regVal  := RegExReplace(regVal, '^hex\(b\):(.*)$', '$1')
					isHex   := true
				} else if RegExMatch(regVal, '^hex\(7\):') {
					regType := "REG_MULTI_SZ"
					regVal  := RegExReplace(regVal, '^hex\(7\):(.*)$', '$1')
					isHex   := true
				} else if RegExMatch(regVal, '^hex\(2\):') {
					regType := "REG_EXPAND_SZ"
					regVal  := RegExReplace(regVal, '^hex\(2\):(.*)$', '$1')
					isHex   := true
				} else if (RegExMatch(regVal, '^hex:')) {
					regType := "REG_BINARY"
					regVal := RegExReplace(regVal, '^hex:(.*)$', '$1')
					isHex := true
				}
			}

			if (RegExMatch(line, '^.*\\$')) {
				readNextLine := true
				continue
			} else {
				readNextLine := false
			}

			if (isHex == true) {
				regVal := RegExReplace(regVal, "[\\\t ]", "")
			}

			if (regType == "REG_DWORD") {
				regVal := "0x" . regVal
			} else if (regType == "REG_QWORD") {
				regVal := "0x" . Registry._toNumberFromHex(regVal)
			} else if (regType == "REG_MULTI_SZ") {
				regVal := Registry._toStringFromHex(regVal)
			} else if (regType == "REG_EXPAND_SZ") {
				regVal := Registry._toStringFromHex(regVal)
			} else if (regType == "REG_BINARY") {
				regVal := StrReplace(regVal, ",", "", "All")
			}
			
			regName := Registry._bindValue( regName, properties )

			if !Registry._valueChanged(regKey, regName, regType, regVal)
				continue

			if ( ! RegExMatch(regKey, "^(HKEY_CURRENT_USER|HKEY_USERS)\\.*$") ) {
				Registry._restartAsAdmin()
			}

			RegWrite(regVal, regType, regKey, regName)

		}

	}

	static _bindValue(value, properties) {

		for key, val in properties {
			value := StrReplace(value, "#{" key "}", val)
			value := StrReplace(value, "${" key "}", val)
		}

		return value
	}

	static _valueChanged(regKey, regName, regType, regVal) {
		try current := RegRead(regKey, regName)
		catch
			return true

		if (regType == "REG_DWORD")
			return Integer(current) != Integer(regVal)

		return current != regVal
	}

	static _toStringFromHex( hexValue ) {

	  if ! hexValue
	    return 0

	  array := StrSplit( hexValue, "," )

	  if (Mod(array.Length, 2) != 0) {
	  	array.Push("00")
	  }

	  result := ""

	  for i, element in array {
	  	if (Mod(i, 2) == 0)
	  		continue

	  	result := result Chr("0x" array[i + 1] array[i])
	  }

	  return result
	}

	static _toNumberFromHex( hexValue ) {

	  if ! hexValue
	    return 0

	  array := StrSplit( hexValue, "," )

	  if (Mod(array.Length, 2) != 0) {
	  	array.Push("00")
	  }

	  result := ""

	  for i, element in array {
	  	if (Mod(i, 2) == 0)
	  		continue

	  	result := array[i + 1] array[i] result
	  }

	  return "0x0000000c"
	}

	static _convertBase(fromBase, toBase, number) {
		static u := "_wcstoui64"
		static v := "_i64tow"
		s := Buffer(65, 0)
		value := DllCall("msvcrt.dll\" u, "Str", number, "UInt", 0, "UInt", fromBase, "CDECL Int64")
		DllCall("msvcrt.dll\" v, "Int64", value, "Ptr", s, "UInt", toBase, "CDECL")
		return StrGet(s)
	}

	static _restartAsAdmin() {
		if (!A_IsAdmin) {
			try {
				if (A_IsCompiled)
					Run('*RunAs "' A_ScriptFullPath '" /restart')
				else
					Run('*RunAs "' A_AhkPath '" /restart "' A_ScriptFullPath '"')
			}
			ExitApp
		}
	}

}
