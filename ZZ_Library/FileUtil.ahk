; #NoEnv
; #include %A_ScriptDir%\..\ZZ_Library\Include.ahk
; FileUtil.makeLink("C:\app\emulator\Retroarch\share\config","C:\app\emulator\Retroarch\1.9.7\config")
; ExitApp

class FileUtil {

	static void := FileUtil._init()

	_init() {
	}

	__New() {
		throw Exception( "FileUtil is a static class, dont instante it!", -1 )
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
		EnvGet, userHome, userprofile
		return userHome
	}

	getExt( filePath ) {
		SplitPath, % filePath, fileName, fileDir, fileExtention, fileNameWithoutExtension, DriveName
		StringLower, fileExtention, fileExtention
		return fileExtention
	}

  /**
  * File extention is matched width extentionPattern
  *
  * @param {string} filePath
  * @param {string} extentionPattern 
  * @exmaple
  *   FileUtil.isExt("cue|mdx")
  */
	isExt( filePath, extentionPattern ) {

		IfNotExist %filePath%
			return false

		if ( RegExMatch( filePath, "i).*\.(" extentionPattern ")$" ) ) {
			return true
		} else {
			return false
		}

	}
	
	getName( filePath, withExt:=true ) {
		filePath := RegExReplace( filePath, "^(.*?)\\$", "$1" )
		SplitPath, filePath, fileName, fileDir, fileExtention, fileNameWithoutExtension, DriveName
		if( withExt == true )
			return fileName
		return fileNameWithoutExtension
	}
	
	getFiles( path, pattern=".*", includeDir=false, recursive=false ) {
		
		files := []

		if ( this.isFile(path) ) {
			if RegExMatch( path, pattern )
				files.Insert( path )
		} else {
		  currDir := this.getDir( path )
		  if( currDir != "" ) {
				Loop, %currDir%\*, % includeDir, % recursive
				{
					if not RegExMatch( A_LoopFileFullPath, pattern )
						continue
					files.Insert( A_LoopFileFullPath )
				}
				this._sortArray( files )
		  }
		}
		
		return files
		
	}

	getFile( pathDirOrFile, pattern=".*", includeDir=false, recursive=false ) {

    if( ! this.exist(pathDirOrFile) ) {
    	return ""
    }

		if( this.isFile(pathDirOrFile) ) {
			return pathDirOrFile
		}

    files := this.getFiles( pathDirOrFile, pattern, includeDir, recursive )

    if ( files.MaxIndex() > 0 ) {
      return files[ 1 ]
    }

    return ""

	}
	
	isDir( path ) {
		if( ! this.exist(path) )
			return false
		FileGetAttrib, attr, %path%
		Return InStr( attr, "D" )
	}
	
	isFile( path ) {
		if( ! this.exist(path) )
			return false
		FileGetAttrib, attr, %path%
		Return ! InStr( attr, "D" )
	}

  readJson(path) {
  	if( ! this.exist(path) )
  		return {}
  	return JSON.load(this.read(path))
  }

  readXml(path) {
  	if( ! this.exist(path) )
  		return new XML()
  	return new XML(this.read(path))
  }

  read(path) {
  	FileRead, text, %path%
  	return text
  }

	readProperties( path ) {

		prop := []

		Loop, Read, %path%
		{

			If RegExMatch(A_LoopReadLine, "^#.*" )
				continue

			splitPosition := InStr(A_LoopReadLine, "=" )

			If ( splitPosition = 0 ) {
				key := A_LoopReadLine
				val := ""
			} else {
				key := SubStr( A_LoopReadLine, 1, splitPosition - 1 )
				val := SubStr( A_LoopReadLine, splitPosition + 1 )
			}
			
			prop[ Trim(key) ] := Trim(val)

		}

		return prop

	}

	makeDir( path ) {
		FileCreateDir, %path%
	}

	makeParentDir( path, forDirectory=true ) {
		if ( forDirectory == true ) {
			parentDir := this.getParentDir( path )
		} else {
			parentDir := this.getDir( path )
		}
		FileCreateDir, % parentDir
	}

	exist( path ) {
		return FileExist( path ) != ""
	}

	delete( path, recursive=1 ) {
		if ( this.isFile(path) ) {
			FileDelete, % path
		} else if( this.isDir(path) ) {
			FileRemoveDir, % path, % recursive
		}
	}

	move( src, trg, overwrite=1 ) {
		if ( ! this.exist(src) )
			return
		this.makeParentDir( trg, this.isDir(src) )
		FileMove, % src, % trg, % overwrite
	}

	copy( src, trg, overwrite=1 ) {
		if ( ! this.exist(src) )
			return
		this.makeParentDir( trg, this.isDir(src) )
		if ( this.isDir(src) ) {
			FileCopyDir, % src, % trg, % overwrite
		} else {
			FileCopy, % src, % trg, % overwrite
		}
	}

	write( path, content="" ) {
		this.makeParentDir( path )
		FileDelete, % path
		FileAppend, % content, % path
	}

  /**
  * get file size
  *
  * @param {path} filePath
  * @return size (byte)
  */
	getSize( path ) {
		FileGetSize, size, % path
		return size
	}

  /**
  * get time
  *
  * @param {path} file path
  * @param {witchTime} M: modification time (default), C: creation time, A: last access time
  * @return YYYYMMDDHH24MISS
  */
	getTime( path, whichTime="M" ) {
		FileGetTime, var, % path, % whichTime
		return var
	}

  /**
  * check symlink
  *
  * @param {path} file path
  * @return true if path is symlink
  */
  isSymlink(path) {
  	FileGetAttrib, attr, % path
  	if( InStr(attr,"D") )
  		return true
  	else
  		return false
  }

  /**
  * make symbolic link
  *
  * @param src        source path (real file)
  * @param trg        target path (path to used as link)
  * @param deleteTrg  delete trg forcidly
  */
  makeLink( src, trg, deleteTrg:=false ) {

    if( ! this.exist(src) )
    	return false

  	if( deleteTrg == true ) {
  		this.delete( trg )
  	}

		this.makeParentDir( trg, this.isDir(src) )
		if ( this.isDir(src) ) {
			cmd := "/c mklink /d """ trg """ """ src """"
		} else {
			cmd := "/c mklink """ trg """ """ src """"
		}
		debug( cmd )
		; run %ComSpec% %cmd%,,
		runWait %ComSpec% %cmd%,, Hide
		; this.cli( cmd )

		return true

  }

  /**
  * run command and return result
  *
  * @param  command	 command
  * @return command execution result
  */
	cli( command ) {

		dhw := A_DetectHiddenWindows
		DetectHiddenWindows,On
		Run, %ComSpec% /k,,Hide UseErrorLevel, pid
		if not ErrorLevel
		{
			while ! WinExist("ahk_pid" pid)
				Sleep,100
			DllCall( "AttachConsole","UInt",pid )
		}
		DetectHiddenWindows, % dhw

		; debug( "command :`n`t" command )
		shell := ComObjCreate("WScript.Shell")
		try {
			exec := shell.Exec( comspec " " command )
			While ! exec.Status
				sleep, 100
			result := exec.StdOut.readAll()
		}
		catch e
		{
			debug( "error`n" e.what "`n" e.message )
		}
		; debug( "result :`n`t" result )
		DllCall("FreeConsole")
		Process Close, %pid%

		return result

	}

	_sortArray( Array ) {
	  t := Object()
	  for k, v in Array
	    t[RegExReplace(v,"\s")]:=v
	  for k, v in t
	    Array[A_Index] := v
	  return Array
	}

	resolvePath( absolutePath, relativePath ) {
    VarSetCapacity( dest, (A_IsUnicode ? 2 : 1) * 260, 1 ) ; MAX_PATH
    DllCall( "Shlwapi.dll\PathCombine", "UInt", &dest, "UInt", &absolutePath, "UInt", &relativePath )
    Return, dest
  }

  normalizePath( path ) {
  	return RegExReplace( path, "\\+", "\" )
  }

}