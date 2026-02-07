#Requires AutoHotkey >=2.0
#Warn VarUnset, Off  ; xml is class from Xml.ahk (included via Include.ahk)

class FileUtil {

	static _init() {
	}
	static void := FileUtil._init()

	__New() {
		throw Error("FileUtil is a static class, dont instantiate it!", -1)
	}

	getDir( path ) {
		path := RegExReplace( path, "^(.*?)\\$", "$1" )
		if( ! this.exist(path) )
		  return ""
		if( this.isDir(path) )
			return path
		return this.getParentDir( path )
	}

	getParentDir( path ) {
		path := RegExReplace( path, "^(.*?)\\$", "$1" )
		path := RegExReplace( path, "^(.*)\\.+?$", "$1" )
		return path
	}

	/**
	* get user home
	* @return user home directory path
	*/
	getHomeDir() {
		return EnvGet("userprofile")
	}

	getExt(filePath) {
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
	isExt(filePath, extentionPattern) {
		if (!FileExist(filePath))
			return false
		if (RegExMatch(filePath, "i).*\.(" extentionPattern ")$")) {
			return true
		} else {
			return false
		}
	}
	
	getName(filePath, withExt := true) {
		filePath := RegExReplace(filePath, "^(.*?)\\$", "$1")
		SplitPath(filePath, &fileName, &fileDir, &fileExtention, &fileNameWithoutExtension)
		if (withExt == true)
			return fileName
		return fileNameWithoutExtension
	}
	
	getFiles(path, pattern := ".*", includeDir := false, depth := 0) {
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

	_getFilesRecursive(dir, pattern, includeDir, depth, files) {
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

	getFile(pathDirOrFile, pattern := ".*", includeDir := false, depth := 0) {
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
	
	isDir(path) {
		if (!this.exist(path))
			return false
		attr := FileGetAttrib(path)
		return InStr(attr, "D") > 0
	}
	
	isFile(path) {
		if (!this.exist(path))
			return false
		attr := FileGetAttrib(path)
		return !InStr(attr, "D")
	}

  readJson(path) {
  	if (!this.exist(path))
  		return Map()
  	return JSON.load(this.read(path))
  }

  readXml(path) {
    global xml  ; class from Xml.ahk
  	if (!this.exist(path))
  		return xml()
  	return xml(path)
  }

  read(path) {
  	return FileRead(path)
  }

	readProperties(path) {
		prop := Map()
		loop read, path {
			if RegExMatch(A_LoopReadLine, "^#.*")
				continue
			splitPosition := InStr(A_LoopReadLine, "=")
			if (splitPosition = 0) {
				key := A_LoopReadLine
				val := ""
			} else {
				key := SubStr(A_LoopReadLine, 1, splitPosition - 1)
				val := SubStr(A_LoopReadLine, splitPosition + 1)
			}
			prop[Trim(key)] := Trim(val)
		}
		return prop
	}

	makeDir(path) {
		DirCreate(path)
	}

	makeParentDir(path, forDirectory := true) {
		if (forDirectory == true) {
			parentDir := this.getParentDir(path)
		} else {
			parentDir := this.getDir(path)
		}
		DirCreate(parentDir)
	}

	exist( path ) {
		return FileExist( path ) != ""
	}

	delete(path, recursive := 1) {
		if (this.isFile(path)) {
			FileDelete(path)
		} else if (this.isDir(path)) {
			DirDelete(path, recursive)
		}
	}

	move(src, trg, overwrite := 1) {
		if (!this.exist(src))
			return
		this.makeParentDir(trg, this.isDir(src))
		FileMove(src, trg, overwrite ? 1 : 0)
	}

	copy(src, trg, overwrite := 1) {
		if (!this.exist(src))
			return
		this.makeParentDir(trg, this.isDir(src))
		if (this.isDir(src)) {
			DirCopy(src, trg, overwrite)
		} else {
			FileCopy(src, trg, overwrite ? 1 : 0)
		}
	}

	write(path, content := "") {
		this.makeParentDir(path)
		try FileDelete(path)
		FileAppend(content, path)
	}

  /**
  * get file size
  *
  * @param {path} filePath
  * @return size (byte)
  */
	getSize(path) {
		return FileGetSize(path)
	}

  /**
  * get time
  *
  * @param {path} file path
  * @param {witchTime} M: modification time (default), C: creation time, A: last access time
  * @return YYYYMMDDHH24MISS
  */
	getTime(path, whichTime := "M") {
		return FileGetTime(path, whichTime)
	}

  /**
  * check symlink
  *
  * @param {path} file path
  * @return true if path is symlink
  */
  isSymlink(path) {
  	attr := FileGetAttrib(path)
  	return InStr(attr, "L") > 0
  }

  hasSymlinkAuth() {
		testFilePath := A_Temp "\ahkSymlinkTestfile.txt"
		testLinkPath := A_Temp "\ahkSymlinkTestlink.txt"

		debug("symlink test file path: " testFilePath)

		FileAppend("", testFilePath)
		RunWait(A_ComSpec ' /c mklink "' testLinkPath '" "' testFilePath '"', , "Hide")

		hasAuth := this.exist(testLinkPath)

		try FileDelete(testFilePath)
		try FileDelete(testLinkPath)

		debug("has auth: " hasAuth)
		return hasAuth
  }

  createSymlinkAuth() {
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
  makeLink(src, trg, deleteTrg:=false) {

    if( ! this.exist(src) )
    	return false

  	if( deleteTrg == true && this.exist(trg) ) {
  		this.delete(trg)
  	}

		this.makeParentDir(trg, this.isDir(src))
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
	cli(command) {
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

	_sortArray(Array) {
	  t := Map()
	  for k, v in Array
	    t[RegExReplace(v, "\s")] := v
	  Array := []
	  for k, v in t
	    Array.Push(v)
	  return Array
	}

	resolvePath(absolutePath, relativePath) {
		dest := Buffer(260 * 2, 0)
		DllCall("Shlwapi.dll\PathCombine", "Ptr", dest, "Str", absolutePath, "Str", relativePath)
		return StrGet(dest)
	}

  normalizePath( path ) {
  	return RegExReplace( path, "\\+", "\" )
  }

}
