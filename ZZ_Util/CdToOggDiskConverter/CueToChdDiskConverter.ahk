#NoEnv
#include %A_ScriptDir%\..\..\ZZ_Library\Include.ahk

; pathWorkRoot := "f:\download\3do"
pathWorkRoot := "f:\download\3do"
; pathWorkRoot := "f:\download\saturn"
; pathRoot     := "\\NAS\emul\image\PcFx"
; pathRoot     := "\\NAS\emul\image\PlayStation"
; pathRoot     := "\\NAS\emul\image\3DO\Games\Guardian War"
pathRoot     := "\\NAS\emul\image\3DO"
; pathRoot     := "\\NAS\emul\image\Saturn\RPG\Grandia (T-Kr)"
; pathRoot     := "\\NAS\emul\image\PcFx\Aa! Megami Sama"
replaceFile  := true

debug( "start" )

files := FileUtil.getFiles( pathRoot, "i).*\.(bin|cue|mdx|mds|ccd)", false, true )

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
  if ( ext == "cue" || ext == "mdx" || ext == "mds" || ext == "ccd") {
  	cueFiles[gameDir].insert( fileSrc )
  }
}

for gameDir, files in cueFiles {
	workDir  := pathWorkRoot "\" gameDir
	FileUtil.makeDir( workDir )
	; convert image
	Loop, % files.MaxIndex() {
		cueFile := files[ A_Index ]
		if ( VirtualDisk.open(cueFile) == true ) {
			debug( ">> start convert image : " gameDir " / " cueFile )
			Sleep, 2000
			if ( files.MaxIndex() > 1 ) {
				diskName := gameDir " (disk " A_Index ")"
			} else {
				diskName := gameDir
			}

			toChdImage( workDir, diskName )

			VirtualDisk.close()
			Sleep, 1000
		}
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


toChdImage( workDir, fileName ) {

	binFile := workDir "\" fileName ".bin"
	cueFile := workDir "\" fileName ".cue"
	chdFile := workDir "\" fileName ".chd"

	debug( "  - read to cd image" )
	command := % """" A_ScriptDir "\util\ImgBurn.exe"" /MODE READ /SRC G: /DEST """ binFile """ /START /CLOSE"
	; debug( command )
	RunWait, % command, % workDir, Hide, pid

	debug( "  - convert to chd image" )
	command := % """" A_ScriptDir "\util\chdman.exe"" createcd -i """ cueFile """ -o """ chdFile """"
	debug( command )
	RunWait, % command, % workDir, show, pid

	FileDelete, % cueFile
	FileDelete, % binFile

}