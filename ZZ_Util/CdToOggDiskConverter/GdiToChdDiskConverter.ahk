#NoEnv
#include %A_ScriptDir%\..\..\ZZ_Library\Include.ahk

pathWorkRoot := "f:\download\dc"
pathRoot     := "\\NAS\emul\image\DreamCast"
replaceFile  := false

debug( "start" )

files := FileUtil.getFiles( pathRoot, "i).*\.(gdi)", false, true )

debug( "file count : " files.MaxIndex() )

allFiles := {}
cueFiles := {}
srcDirs  := {}

; gathering files
Loop, % files.MaxIndex()
{
	fileSrc := files[ A_Index ]
	srcDir  := FileUtil.getDir( fileSrc )
	gameDir := FileUtil.getFileName( srcDir )
	; remove unrecognized character
	gameDir  := RegExReplace( gameDir, "%", "_" )

  if ( allFiles[gameDir] == "" ) {
  	allFiles[gameDir] := []
  	cueFiles[gameDir] := []
  	srcDirs[gameDir]  := srcDir
  }

  allFiles[gameDir].insert( fileSrc )

	ext := FileUtil.getExt(fileSrc)
  if ( ext == "gdi" ) {
  	cueFiles[gameDir].insert( fileSrc )
  }
}

for gameDir, files in cueFiles {
	workDir  := pathWorkRoot "\" gameDir
	FileUtil.makeDir( workDir )
	; convert image
	Loop, % files.MaxIndex()
	{
		gdiFile := files[ A_Index ]
		debug( ">> start convert image : " gameDir " / " gdiFile )
		if ( files.MaxIndex() > 1 ) {
			diskName := gameDir " (disk " A_Index ")"
		} else {
			diskName := gameDir
		}
		toChdImage( gdiFile, workDir, diskName )
	}
	; write m3u for multi-disc
	if ( files.MaxIndex() > 1 ) {
		m3uText := ""
		loop, % files.MaxIndex() {
			m3uText .= gameDir " (disk " A_Index ").chd`n"
		}
		FileAppend, % m3uText, % workDir "/" gameDir ".m3u"
	}

	if( replaceFile == false )
		continue

	; delete original files
	loop, % allFiles[gameDir].MaxIndex() {
		file := allFiles[gameDir][ A_Index ]
		debug( "delete file : " file )
		FileUtil.delete( file )
	}

	; copy worked files
	copyFiles := FileUtil.getFiles( workDir, ".*", false, false )
	loop, % copyFiles.MaxIndex() {
		file := copyFiles[ A_Index ]
		debug( "    - move file : " file " -> " srcDir[gameDir] )
		FileUtil.move( file, srcDirs[gameDir] )
	}
	FileAppend, % "", srcDirs[gameDir] "\.done"
	FileUtil.removeDir( workDir )

}

debug( "end" )

ExitApp

getTitle( filePath ) {
	return RegExReplace( filePath, "^.+\\(.+?)\\.+$", "$1" )
}


toChdImage( gdiFile, workDir, fileName ) {

	chdFile := workDir "\" fileName ".chd"

	debug( "  - convert to chd image" )
	command := % """" A_ScriptDir "\util\chdman.exe"" createcd -i """ gdiFile """ -o """ chdFile """"
	debug( command )
	RunWait, % command, % workDir, show, pid

	if ( replaceFile == true ) {
		debug( "delete file !!!")
		; FileDelete, % cueFile
		; FileDelete, % binFile
	}

}