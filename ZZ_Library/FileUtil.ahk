#Requires AutoHotkey >=2.0
#Warn VarUnset, Off  ; Xml is class from Xml.ahk (included via Include.ahk)

class FileUtil {

	static _init() {
	}
	static void := FileUtil._init()
	static _iniCache := Map()

	__New() {
		throw Error("FileUtil is a static class, dont instantiate it!", -1)
	}

	static getDir( path ) {
		path := RegExReplace( path, "^(.*?)\\$", "$1" )
		if( ! this.exist(path) )
		  return ""
		if( this.isDir(path) )
			return path
		return this.getParentDir( path )
	}

	static getParentDir( path ) {
		path := RegExReplace( path, "^(.*?)\\$", "$1" )
		path := RegExReplace( path, "^(.*)\\.+?$", "$1" )
		return path
	}

	/**
	* get user home
	* @return user home directory path
	*/
	static getHomeDir() {
		return EnvGet("userprofile")
	}

	static getExt(filePath) {
		SplitPath(filePath, , , &fileExtention)
		return StrLower(fileExtention)
	}

  /**
  * File extention is matched width extentionPattern
  *
  * @param {string} filePath
  * @param {string} extentionPattern 
  * @exmaple
  *   FileUtil.isExt("cue|mdx")
  */
	static isExt(filePath, extentionPattern) {
		if (!FileExist(filePath))
			return false
		if (RegExMatch(filePath, "i).*\.(" extentionPattern ")$")) {
			return true
		} else {
			return false
		}
	}
	
	static getName(filePath, withExt := true) {
		filePath := RegExReplace(filePath, "^(.*?)\\$", "$1")
		SplitPath(filePath, &fileName, &fileDir, &fileExtention, &fileNameWithoutExtension)
		if (withExt == true)
			return fileName
		return fileNameWithoutExtension
	}
	
	static getFiles(path, pattern := ".*", includeDir := false, depth := 0) {
		files := []
		if (this.isFile(path) && includeDir == false) {
			if RegExMatch(path, pattern)
				files.Push(path)
		} else {
			currDir := this.getDir(path)
			if (currDir != "") {
				this._getFilesRecursive(currDir, pattern, includeDir, depth, files)
				this._sortArray(files)
			}
		}
		return files
	}

	static _getFilesRecursive(dir, pattern, includeDir, depth, files) {
		dirs := []
		Loop Files, dir "\*", "FD" {
			if (InStr(A_LoopFileAttrib, "D")) {
				dirs.Push(A_LoopFileFullPath)
				if (includeDir && RegExMatch(A_LoopFileFullPath, pattern)) {
					files.Push(A_LoopFileFullPath)
				}
			} else {
				if RegExMatch(A_LoopFileFullPath, pattern) {
					files.Push(A_LoopFileFullPath)
				}
			}
		}

		if (depth == -1 || depth > 0) {
			nextDepth := (depth == -1) ? -1 : (depth - 1)
			for index, subDir in dirs {
				this._getFilesRecursive(subDir, pattern, includeDir, nextDepth, files)
			}
		}
	}

	static getFile(pathDirOrFile, pattern := ".*", includeDir := false, depth := 0) {
		if (!this.exist(pathDirOrFile) && includeDir == false) {
			return ""
		}
		if (this.isFile(pathDirOrFile)) {
			return pathDirOrFile
		}
		files := this.getFiles(pathDirOrFile, pattern, includeDir, depth)
		if (files.Length > 0) {
			return files[1]
		} else {
			return ""
		}
	}
	
	static isDir(path) {
		if (!this.exist(path))
			return false
		attr := FileGetAttrib(path)
		return InStr(attr, "D") > 0
	}
	
	static isFile(path) {
		if (!this.exist(path))
			return false
		attr := FileGetAttrib(path)
		return !InStr(attr, "D")
	}

  static readJson(path) {
  	if (!this.exist(path))
  		return JSON.Obj()
 	return JSON.parse(this.read(path))
  }

  static readXml(path) {
  	if (!this.exist(path))
  		return Xml()
  	return Xml(path)
  }

  static read(path, charset := "") {
  	if (charset == "")
  		return FileRead(path)
  	return FileRead(path, charset)
  }

  /**
  * Read INI using the specified charset. Default charset is UTF-8.
  * readIni(path, "init", "executor") -> single value
  * readIni(path, "init") -> section Map
  * readIni(path) -> file Map(section -> Map)
  * writeIni(path, "init", "executor", "game.exe") -> upsert key
  * deleteIni(path, "init", "executor") -> delete key
  * deleteIni(path, "window") -> delete section
  */
  static readIni(path, section := "", key := "", defaultValue := "", charset := "UTF-8") {
  	data := this._loadIni(path, charset)
  	if (section == "")
  		return this._materializeIni(data)
  	sectionKey := StrLower(Trim(section))
  	if (!data.Has(sectionKey))
  		return defaultValue
  	sectionData := data[sectionKey]
  	if (key == "")
  		return this._materializeIniSection(sectionData)
  	keyKey := StrLower(Trim(key))
  	if (!sectionData["values"].Has(keyKey))
  		return defaultValue
  	return sectionData["values"][keyKey]
  }

	static readProperties(path, charset := "UTF-8") {
		prop := Map()
		text := this.read(path, charset)
		if (SubStr(text, 1, 1) == Chr(0xFEFF))
			text := SubStr(text, 2)
		for loopLine in StrSplit(text, "`n", "`r") {
			if RegExMatch(loopLine, "^#.*")
				continue
			splitPosition := InStr(loopLine, "=")
			if (splitPosition = 0) {
				key := loopLine
				val := ""
			} else {
				key := SubStr(loopLine, 1, splitPosition - 1)
				val := SubStr(loopLine, splitPosition + 1)
			}
			prop[Trim(key)] := Trim(val)
		}
		return prop
	}

	static makeDir(path) {
		DirCreate(path)
	}

	static makeParentDir(path, forDirectory := true) {
		if (forDirectory == true) {
			parentDir := this.getParentDir(path)
		} else {
			parentDir := this.getDir(path)
		}
		DirCreate(parentDir)
	}

	static exist( path ) {
		return FileExist( path ) != ""
	}

	static delete(path, recursive := 1) {
		if (this.isFile(path)) {
			FileDelete(path)
		} else if (this.isDir(path)) {
			DirDelete(path, recursive)
		}
	}

	static move(src, trg, overwrite := 1) {
		if (!this.exist(src))
			return
		this.makeParentDir(trg, this.isDir(src))
		FileMove(src, trg, overwrite ? 1 : 0)
	}

	static copy(src, trg, overwrite := 1) {
		if (!this.exist(src))
			return
		this.makeParentDir(trg, this.isDir(src))
		if (this.isDir(src)) {
			DirCopy(src, trg, overwrite)
		} else {
			FileCopy(src, trg, overwrite ? 1 : 0)
		}
	}

	static write(path, content := "") {
		this.makeParentDir(path)
		try FileDelete(path)
		FileAppend(content, path)
	}

	static writeIni(path, section, key, value, charset := "UTF-8") {
		sectionName := Trim(section)
		keyName := Trim(key)
		if (sectionName == "" || keyName == "")
			return

		text := ""
		if (this.exist(path))
			text := this.read(path, charset)
		if (SubStr(text, 1, 1) == Chr(0xFEFF))
			text := SubStr(text, 2)

		content := this._upsertIniText(text, sectionName, keyName, "" value)
		this.makeParentDir(path)
		try FileDelete(path)
		FileAppend(content, path, charset)

		cacheKey := path "|" charset
		if (this._iniCache.Has(cacheKey))
			this._iniCache.Delete(cacheKey)
	}

	static deleteIni(path, section, key := "", charset := "UTF-8") {
		sectionName := Trim(section)
		keyName := Trim(key)
		if (sectionName == "" || !this.exist(path))
			return

		text := this.read(path, charset)
		if (SubStr(text, 1, 1) == Chr(0xFEFF))
			text := SubStr(text, 2)

		content := this._deleteIniText(text, sectionName, keyName)
		if (content == text)
			return

		this.makeParentDir(path)
		try FileDelete(path)
		FileAppend(content, path, charset)

		cacheKey := path "|" charset
		if (this._iniCache.Has(cacheKey))
			this._iniCache.Delete(cacheKey)
	}

	static _upsertIniText(text, sectionName, keyName, value) {
		if (text == "")
			return "[" sectionName "]`r`n" keyName " = " value "`r`n"

		newline := InStr(text, "`r`n") ? "`r`n" : "`n"
		hasTrailingNewline := RegExMatch(text, "(\r\n|\n)$")
		lines := StrSplit(text, "`n", "`r")
		targetSection := StrLower(sectionName)
		targetKeyPattern := "i)^\s*" this._escapeRegEx(keyName) "\s*="
		inSection := false
		sectionFound := false
		insertAt := lines.Length + 1

		for index, line in lines {
			trimmed := Trim(line)
			if RegExMatch(trimmed, "^\[(.*)\]$", &match) {
				if (inSection) {
					insertAt := index
					break
				}
				currentSection := StrLower(Trim(match[1]))
				inSection := (currentSection == targetSection)
				if (inSection) {
					sectionFound := true
					insertAt := index + 1
				}
				continue
			}

			if (!inSection)
				continue

			if RegExMatch(line, targetKeyPattern) {
				lines[index] := this._replaceIniValueLine(line, value)
				return this._joinIniLines(lines, newline, hasTrailingNewline)
			}
			insertAt := index + 1
		}

		entryLine := keyName " = " value
		if (sectionFound) {
			lines.InsertAt(insertAt, entryLine)
		} else {
			if (lines.Length > 0 && Trim(lines[lines.Length]) != "")
				lines.Push("")
			lines.Push("[" sectionName "]")
			lines.Push(entryLine)
			hasTrailingNewline := true
		}

		return this._joinIniLines(lines, newline, hasTrailingNewline)
	}

	static _deleteIniText(text, sectionName, keyName := "") {
		if (text == "")
			return text

		newline := InStr(text, "`r`n") ? "`r`n" : "`n"
		hasTrailingNewline := RegExMatch(text, "(\\r\\n|\\n)$")
		lines := StrSplit(text, "`n", "`r")
		targetSection := StrLower(sectionName)
		targetKeyPattern := (keyName == "") ? "" : "i)^\\s*" this._escapeRegEx(keyName) "\\s*="
		sectionStart := 0
		sectionEnd := lines.Length + 1
		inSection := false

		for index, line in lines {
			trimmed := Trim(line)
			if RegExMatch(trimmed, "^\[(.*)\]$", &match) {
				if (inSection) {
					sectionEnd := index
					break
				}
				currentSection := StrLower(Trim(match[1]))
				inSection := (currentSection == targetSection)
				if (inSection)
					sectionStart := index
				continue
			}

			if (!inSection || keyName == "")
				continue

			if RegExMatch(line, targetKeyPattern) {
				lines.RemoveAt(index)
				return this._joinIniLines(lines, newline, hasTrailingNewline)
			}
		}

		if (sectionStart == 0)
			return text
		if (keyName != "")
			return text

		deleteLength := sectionEnd - sectionStart
		if (deleteLength <= 0)
			return text
		lines.RemoveAt(sectionStart, deleteLength)
		while (lines.Length > 1) {
			changed := false
			for index, line in lines {
				if (index < lines.Length && Trim(line) == "" && Trim(lines[index + 1]) == "") {
					lines.RemoveAt(index)
					changed := true
					break
				}
			}
			if (!changed)
				break
		}
		while (lines.Length > 0 && Trim(lines[1]) == "")
			lines.RemoveAt(1)
		while (lines.Length > 0 && Trim(lines[lines.Length]) == "")
			lines.RemoveAt(lines.Length)

		return this._joinIniLines(lines, newline, hasTrailingNewline)
	}

	static _replaceIniValueLine(line, value) {
		if RegExMatch(line, "^(\s*[^=]+?\s*=\s*)(.*?)(\s+[;#].*)?$", &match)
			return match[1] value match[3]
		eqPos := InStr(line, "=")
		if (eqPos <= 0)
			return line
		return SubStr(line, 1, eqPos) " " value
	}

	static _joinIniLines(lines, newline := "`r`n", hasTrailingNewline := false) {
		content := ""
		for index, line in lines {
			if (index > 1)
				content .= newline
			content .= line
		}
		if (hasTrailingNewline && content != "")
			content .= newline
		return content
	}

	static _escapeRegEx(text) {
		return "\Q" text "\E"
	}

	static _loadIni(path, charset := "UTF-8") {
		cacheKey := path "|" charset
		if (this._iniCache.Has(cacheKey))
			return this._iniCache[cacheKey]

		data := Map("__order__", [])
		if (!this.exist(path)) {
			this._iniCache[cacheKey] := data
			return data
		}

		text := FileRead(path, charset)
		if (SubStr(text, 1, 1) == Chr(0xFEFF))
			text := SubStr(text, 2)

		currentSection := ""
		for loopLine in StrSplit(text, "`n", "`r") {
			line := Trim(loopLine)
			if (line == "" || RegExMatch(line, "^[;#]"))
				continue
			if RegExMatch(line, "^\[(.*)\]$", &match) {
				sectionName := Trim(match[1])
				sectionKey := StrLower(sectionName)
				currentSection := sectionKey
				if (!data.Has(sectionKey)) {
					data["__order__"].Push(sectionKey)
					data[sectionKey] := Map("name", sectionName, "order", [], "values", Map(), "keyNames", Map())
				}
				continue
			}
			if (currentSection == "")
				continue
			eqPos := InStr(line, "=")
			if (eqPos <= 0)
				continue
			keyName := Trim(SubStr(line, 1, eqPos - 1))
			keyKey := StrLower(keyName)
			value := Trim(SubStr(line, eqPos + 1))
			sectionData := data[currentSection]
			if (!sectionData["values"].Has(keyKey))
				sectionData["order"].Push(keyKey)
			sectionData["values"][keyKey] := value
			sectionData["keyNames"][keyKey] := keyName
		}

		this._iniCache[cacheKey] := data
		return data
	}

	static _renderIni(data) {
		content := ""
		for index, sectionKey in data["__order__"] {
			sectionData := data[sectionKey]
			if (index > 1)
				content .= "`r`n"
			content .= "[" sectionData["name"] "]`r`n"
			for _, keyKey in sectionData["order"] {
				keyName := sectionData["keyNames"][keyKey]
				storedValue := sectionData["values"][keyKey]
				content .= keyName " = " storedValue "`r`n"
			}
		}
		return content
	}

	static _materializeIni(data) {
		result := Map()
		for _, sectionKey in data["__order__"] {
			sectionData := data[sectionKey]
			result[sectionData["name"]] := this._materializeIniSection(sectionData)
		}
		return result
	}

	static _materializeIniSection(sectionData) {
		result := Map()
		for _, keyKey in sectionData["order"] {
			keyName := sectionData["keyNames"][keyKey]
			result[keyName] := sectionData["values"][keyKey]
		}
		return result
	}

  /**
  * get file size
  *
  * @param {path} filePath
  * @return size (byte)
  */
	static getSize(path) {
		return FileGetSize(path)
	}

  /**
  * get time
  *
  * @param {path} file path
  * @param {witchTime} M: modification time (default), C: creation time, A: last access time
  * @return YYYYMMDDHH24MISS
  */
	static getTime(path, whichTime := "M") {
		return FileGetTime(path, whichTime)
	}

  /**
  * check symlink
  *
  * @param {path} file path
  * @return true if path is symlink
  */
  static isSymlink(path) {
  	attr := FileGetAttrib(path)
  	return InStr(attr, "L") > 0
  }

  static hasSymlinkAuth() {
		testFilePath := A_Temp "\ahkSymlinkTestfile.txt"
		testLinkPath := A_Temp "\ahkSymlinkTestlink.txt"

		; debug("symlink test file path: " testFilePath)

		FileAppend("", testFilePath)
		RunWait(A_ComSpec ' /c mklink "' testLinkPath '" "' testFilePath '"', , "Hide")

		hasAuth := this.exist(testLinkPath)

		try FileDelete(testFilePath)
		try FileDelete(testLinkPath)

		; debug("has auth: " hasAuth)
		return hasAuth
  }

  static createSymlinkAuth() {
  	cmd := "fsutil behavior set SymlinkEvaluation L2L:1 R2R:1 L2R:1 R2L:1"
  	RunWait(A_ComSpec " " cmd, , "Hide")
  }

  /**
  * make symbolic link
  *
  * @param src        source path (real file)
  * @param trg        target path (path to used as link)
  * @param deleteTrg  delete trg forcidly
  */
  static makeLink(src, trg, deleteTrg:=false) {

    if( ! this.exist(src) )
    	return false

  	if( deleteTrg == true && this.exist(trg) ) {
  		this.delete(trg)
  	}

		this.makeParentDir(trg, true)
		if ( this.isDir(src) ) {
			cmd := "/c mklink /d `"" . trg . "`" `"" . src . "`""
		} else {
			cmd := "/c mklink `"" . trg . "`" `"" . src . "`""
		}
		debug(cmd)
		RunWait(A_ComSpec " " cmd, , "Hide")
		; this.cli( cmd )

		return true

  }

  /**
  * run command and return result
  *
  * @param  command	 command
  * @return command execution result
  */
	static cli(command) {
		dhw := A_DetectHiddenWindows
		DetectHiddenWindows(true)
		try {
			Run(A_ComSpec " /k", , "Hide UseErrorLevel", &pid)
			if (pid) {
				while !WinExist("ahk_pid" pid)
					Sleep(100)
				DllCall("AttachConsole", "UInt", pid)
			}
		}
		DetectHiddenWindows(dhw)

		shell := ComObject("WScript.Shell")
		try {
			exec := shell.Exec(A_ComSpec " " command)
			while !exec.Status
				Sleep(100)
			result := exec.StdOut.ReadAll()
		} catch as e {
			debug("error`n" e.What "`n" e.Message)
		}
		DllCall("FreeConsole")
		ProcessClose(pid)
		return result
	}

	static _sortArray(Array) {
	  t := Map()
	  for k, v in Array
	    t[RegExReplace(v, "\s")] := v
	  Array := []
	  for k, v in t
	    Array.Push(v)
	  return Array
	}

	static resolvePath(absolutePath, relativePath) {
		dest := Buffer(260 * 2, 0)
		DllCall("Shlwapi.dll\PathCombine", "Ptr", dest, "Str", absolutePath, "Str", relativePath)
		return StrGet(dest)
	}

  static normalizePath( path ) {
  	return RegExReplace( path, "\\+", "\" )
  }

}
