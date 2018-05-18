#NoEnv

EnvGet, userHome, userprofile

trgDir01 := userHome "\Documents\Rockstar Games\L.A. Noire"
trgDir02 := userHome "\Documents\Rockstar Games\Social Club"
srcDir01 := FileUtil.getDir(A_LineFile) "\documents\L.A. Noire"
srcDir02 := FileUtil.getDir(A_LineFile) "\documents\Social Club"

copyDir( srcDir01, trgDir01 )
copyDir( srcDir02, trgDir02 )

ExitApp

copyDir( srcDir, trgDir ) {
	if( FileUtil.exist(trgDir) )
		return
	debug( srcDir " -> " FileUtil.getParentDir(trgDir) )
	FileUtil.copyDir( srcDir, trgDir )
}


debug( message ) {

 if( A_IsCompiled == 1 )
   return

  message .= "`n" 
  FileAppend %message%, * ; send message to stdout
    
}


class FileUtil {

	static void := FileUtil._init()

	_init() {
	}

	__New() {
	throw Exception( "FileUtil is a static class, dont instante it!", -1 )
	}

	getDir( path ) {
		IfNotExist %path%, return ""
		if( this.isDir(path) )
			return path
		return this.getParentDir( path )
	}

	getParentDir( path ) {
		path := RegExReplace( path, "^(.*?)\\$", "$1" )
		path := RegExReplace( path, "^(.*)\\.+?$", "$1" )
		return path
	}

	getExt( filePath ) {

		IfNotExist %filePath%
			return ""
		
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
	
	getFileName( filePath, withExt:=true ) {

		IfNotExist %filePath%
			return ""
		
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
			Loop, %currDir%\*, % includeDir, % recursive
			{
					if not RegExMatch( A_LoopFileFullPath, pattern )
						continue
					files.Insert( A_LoopFileFullPath )        	
			}

			this._sortArray( files )

		}
		
		return files
		
	}

	getFile( pathDirOrFile, pattern=".*" ) {

		if ( pathDirOrFile == "" or this.isFile(pathDirOrFile) )  {
			return pathDirOrFile
		}

        files := this.getFiles( pathDirOrFile, pattern )

        if ( files.MaxIndex() > 0 ) {
        	return files[ 1 ]
        }

        return ""

	}
	
	isDir( path ) {

		IfNotExist %path%, return false

		FileGetAttrib, attr, %path%
		
		Return InStr( attr, "D" )
	}
	
	isFile( path ) {

		IfNotExist %path%, return false

		FileGetAttrib, attr, %path%
		
		Return ! InStr( attr, "D" )

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

	exist( path ) {
		return FileExist( path )
	}

	removeDir( path, recursive=1 ) {
		FileRemoveDir, % path, % recursive
	}

	delete( filePath ) {
		FileDelete, % filePath
	}

	move( src, trg, overwrite=1 ) {
		FileMove, % src, % trg, % overwrite
	}

	copyFile( src, trg, overwrite=1 ) {
		FileCopy, % src, % trg, % overwrite
	}

	copyDir( src, trg, overwrite=1 ) {
		FileCopyDir, % src, % trg, % overwrite
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

	_sortArray( Array ) {
	  t := Object()
	  for k, v in Array
	    t[RegExReplace(v,"\s")]:=v
	  for k, v in t
	    Array[A_Index] := v
	  return Array
	}

}