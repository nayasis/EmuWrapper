FileEncoding, UTF-8

EnvGet, userHome, userprofile

source := A_ScriptDir "\..\..\bin\save"
target := userHome "\AppData\Local\Eushully\神採りアルケミーマイスター"

debug( "source : " source )
debug( "target : " target )

FileUtil.makeLink( source, target, true )

ExitApp

debug( message ) {
 if( A_IsCompiled == 1 )
   return
  message .= "`n" 
  FileAppend %message%, * ; send message to stdout
}

class FileUtil {

	getDir( path ) {
		path := RegExReplace( path, "^(.*?)\\$", "$1" )
		IfNotExist %path%
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

	isDir( path ) {
		IfNotExist %path%
			return false
		FileGetAttrib, attr, %path%
		Return InStr( attr, "D" )
	}
	
	isFile( path ) {
		IfNotExist %path%
			return false
		FileGetAttrib, attr, %path%
		Return ! InStr( attr, "D" )
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
		return FileExist( path )
	}

	delete( path, recursive=1 ) {
		if ( this.isFile(path) ) {
			FileDelete, % path
		} else if( this.isDir(path) ) {
			FileRemoveDir, % path, % recursive
		}
	}

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
  * @param src  source path (real file)
  * @param trg  target path (path to used as link)
  */
  makeLink(src, trg, deleteTrg:=false ) {
  	if( deleteTrg == true && this.isSymlink(trg) ) {
  		debug(">> delete previous link`n  - " trg)
  		this.delete(trg)
  	}
		this.makeParentDir( trg, this.isDir(src) )
		if ( this.isDir(src) ) {
			cmd := "/c mklink /d """ trg """ """ src """"
		} else {
			cmd := "/c mklink /f """ trg """ """ src """"
		}
		run %ComSpec% %cmd%,, Hide
  }

}