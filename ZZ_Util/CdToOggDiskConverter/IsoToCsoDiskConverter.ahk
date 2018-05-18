#NoEnv
#include %A_ScriptDir%\..\..\ZZ_Library\Include.ahk

pathWorkRoot := "f:\download\psp"
pathRoot     := "\\NAS\emul\image\PSP"
pathRoot     := "\\NAS\emul\image\PSP\F1 Grand Prix (en)"
; replaceFile  := false

debug( "start" )

files := FileUtil.getFiles( pathRoot, "i).*\.(iso)", false, true )

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
  if ( ext == "iso" ) {
  	cueFiles[gameDir].insert( fileSrc )
  }
}

for gameDir, files in cueFiles {
	workDir  := pathWorkRoot "\" gameDir
	FileUtil.makeDir( workDir )
	; convert image
	Loop, % files.MaxIndex() {
		cueFile := files[ A_Index ]
		if ( files.MaxIndex() > 1 ) {
			diskName := gameDir " (disk " A_Index ")"
		} else {
			diskName := gameDir
		}
		debug( ">> start convert image : " gameDir "," diskName "." cueFile )
		toCso( workDir, cueFile, diskName )
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


toCso( workDir, srcFile, trgFile ) {

	command := A_ScriptDir "\util\CisoPlus.exe -com """ srcFile """ """ workDir "\" trgFile ".cso"""

	debug( command )

	RunWait, % command, % workDir, Hide, pid
	; RunWait, % command, % workDir,, pid

}