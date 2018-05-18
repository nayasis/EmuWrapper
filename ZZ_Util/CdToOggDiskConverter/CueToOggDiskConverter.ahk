#NoEnv
#include %A_ScriptDir%\..\..\ZZ_Library\Include.ahk

; pathWorkRoot := "f:\download\3do"
pathWorkRoot := "f:\download\windows"
; pathWorkRoot := "f:\download\saturn"
; pathRoot     := "\\NAS\emul\image\PcFx"
; pathRoot     := "\\NAS\emul\image\PlayStation"
; pathRoot     := "\\NAS\emul\image\3DO\Games\Guardian War"
pathRoot     := "f:\download\KICHIKU_WIN"
; pathRoot     := "\\NAS\emul\image\Saturn\RPG\Grandia (T-Kr)"
; pathRoot     := "\\NAS\emul\image\PcFx\Aa! Megami Sama"
replaceFile  := false

debug( "start" )

; files := FileUtil.getFiles( pathRoot, "i).*\.(bin|cue|mdx|ccd)", false, true )
files := FileUtil.getFiles( pathRoot, "i).*\.(ccd)", false, true )
; files := FileUtil.getFiles( pathRoot, "i).*\\_EL_CONFIG\\.*\.(bin|cue|iso|mdx|ccd)", false, true )
; files := FileUtil.getFiles( pathRoot, "i).*\\_EL_CONFIG\\.*\.(bin|cue|iso|mdx|ccd)", false, true )

Loop, % files.MaxIndex()
{
	fileSrc := files[ A_Index ]
	srcDir  := FileUtil.getDir( fileSrc )
	gameDir := RegExReplace( srcDir, "^.*\\(.+?)$", "$1")
	debug( fileSrc " -> " srcDir " -> " gameDir )
}

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
  if ( ext == "cue" || ext == "mdx" || ext == "mdf" || ext == "ccd" ) {
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

			; PC-FX
			; toCdImageWithTurboRip( workDir, diskName, "2048" )
			
			; PcEngine
			; toCdImage( workDir, diskName, "", "2048" )
			; toCdImageWithTurboRip( workDir, diskName, "2048" )
			
      ; DOS
      ; toCdImage( workDir, diskName, "", "2048" )
      toCdImageWithTurboRip( workDir, diskName, "2048" )

			; Saturn
			; toCdImageWithTurboRip( workDir, diskName )

			; 3DO
			; toCdImageWithTurboRip( workDir, diskName )
			
			; PlayStation
			; toCdImage( workDir, diskName, "-r", "" )

			VirtualDisk.close()
			Sleep, 1000
		}
	}
	; write m3u for multi-disc
	if ( files.MaxIndex() > 1 ) {
		m3uText := ""
		loop, % files.MaxIndex() {
			m3uText .= gameDir " (disk " A_Index ").cue`n"
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

; ; delete original files
; for gameDir, files in allFiles {
; 	loop, % files.MaxIndex() {
; 		file := files[ A_Index ]
; 		debug( "delete file : " file )
; 		FileUtil.delete( file )
; 	}
; }

; ; copy worked files
; for gameDir, srcDir in srcDirs {
; 	workDir := pathWorkRoot "\" gameDir
; 	debug( workDir )
; 	files   := FileUtil.getFiles( workDir, ".*", false, false )
; 	loop, % files.MaxIndex() {
; 		file := files[ A_Index ]
; 		debug( "copy file : " file " -> " srcDir )
; 		FileUtil.move( file, srcDir )
; 	}
; }

debug( "end" )

ExitApp


getTitle( filePath ) {
	return RegExReplace( filePath, "^.+\\(.+?)\\.+$", "$1" )
}


toCdImage( workDir, fileName, bchunkOption="", modeSize="" ) {

	binFile := workDir "\" fileName ".bin"
	cueFile := workDir "\" fileName ".cue"

	debug( "  - read to cd image" )
	command := % """" A_ScriptDir "\util\ImgBurn.exe"" /MODE READ /SRC G: /DEST """ binFile """ /START /CLOSE"
	; debug( command )
	RunWait, % command, % workDir, Hide, pid

	debug( "  - convert to bin/wav image" )
	; PcEngine
	; command := % """" A_ScriptDir "\util\bchunk.exe"" -w """ binFile """ """ cueFile """ """ fileName "-"""
	; PcFx
	command := % """" A_ScriptDir "\util\bchunk.exe"" -w " bchunkOption " """ binFile """ """ cueFile """ """ fileName "-"""
	; debug( command )
	RunWait, % command, % workDir, Hide, pid

	FileDelete, % binFile
	toCdOgg( workDir, cueFile )

}

toCdImageWithTurboRip( workDir, fileName, modeSize="" ) {

	tmpDir := workDir "\tmp"
	FileUtil.makeDir( tmpDir )
	debug( "tmpDir : " tmpDir )
	debug( "  - read to cd image" )
	command := % """" A_ScriptDir "\util\TurboRip.exe"" /1 ""/NAME=" fileName """"
	debug( command )
	Run, % command, % tmpDir, Hide, pid
  waitToCloseTurboRip( tmpDir, pid )

	tracks := FileUtil.getFiles( tmpDir, "i).*\.(iso|wav|cue)$", false, true )
	Loop, % tracks.MaxIndex()
	{
		srcFilePath := tracks[ A_Index ]
		if ( FileUtil.getExt(srcFilePath) != "cue" ) {
			trgFileName := FileUtil.getFileName(srcFilePath)
			trgFileName := RegExReplace( trgFileName, "^([0-9]{2}) (.+?)\.([a-z]+?)$", fileName "-$1.$3" )
		} else {
			trgFileName := fileName ".cue"
		}
		FileMove, % srcFilePath, % workDir "\" trgFileName
	}
	FileUtil.removeDir( tmpDir )

	newCuesheet := ""
	cueFile := workDir "\" fileName ".cue"
	debug( "curFileName : " cueFile )
	Loop, read, % cueFile
	{
		if ( RegExMatch(A_LoopReadLine, "^FILE "".*$") ) {
			newCuesheet .= RegExReplace( A_LoopReadLine, "^(.+"")([0-9]{2}) (.+?)\.([a-z]+?)("".+?)$", "$1" fileName "-$2.$4$5" ) "`n"
		} else {
			newCuesheet .= A_LoopReadLine "`n"
		}
	}

	FileDelete, % cueFile
	FileAppend, % newCuesheet, % cueFile

	toCdOgg( workDir, cueFile )

}

waitToCloseTurboRip( workDir, pid ) {

  prevFileCount := 0
  retryCount    := 0
  while True
  {
      Sleep, 1000
      currFileCount := FileUtil.getFiles( workDir, ".*", false, true ).MaxIndex()
      if ( currFileCount != prevFileCount )
      {
          prevFileCount := currFileCount
          retryCount    := 0
      } else {
          retryCount := retryCount + 1
          debug( "\t\t... wait to close" retryCount )
      }
      if ( retryCount >= 30 ) {
          break
      }
  }

  Process, Close, % pid

  SetTitleMatchMode,2
  loop
  {
      IfWinNotExist, Chrome
          break
      else
          WinClose, Chrome
  }

}


toCdOgg( workDir, cueFile, modeSize="" ) {
	debug( "  - convert wav to ogg" )
	wavFiles := FileUtil.getFiles( workDir, ".*\.wav" )
	Loop, % wavFiles.MaxIndex()
	{
		; debug( wavFiles[A_Index] )
		toOgg( wavFiles[A_Index], workDir )
	}

	debug( "  - convert to ogg cue" )
	toOggCue( cueFile, workDir, modeSize )
}

toOgg( wavFile, targetDir ) {
	targetFile := targetDir "\" FileUtil.getFileName(wavFile, false) ".ogg"
	RunWait, % A_ScriptDir "\util\oggenc2.exe -n """ targetFile """ """ wavFile """", % targetDir, Hide, pid
	FileDelete, % wavFile
}

toOggCue( cueFile, targetDir, modeSize="" ) {

	; PcEngine, PC-FX
	; MODE_SIZE := "2048"
	MODE_SIZE := ""

	cueName    := FileUtil.getFileName( cueFile, false )
	workDir    := FileUtil.getDir( cueFile )
	trackFiles := FileUtil.getFiles( workDir, ".*-.*\.(ogg|iso)$" )
	targetFile := targetDir "\" cueName ".cue"
	trackIndex := 0
	newCuesheet := ""
	Loop, read, % cueFile
	{
		
		if ( RegExMatch(A_LoopReadLine, "^ *TRACK [0-9]{2} .*$") ) {
			trackIndex++
			trackName := FileUtil.getFileName( trackFiles[trackIndex] )
			trackExt  := RegExReplace( trackName, ".*\.(.*?)$", "$1" )

			newCueSheet .= "FILE """ trackName """ "
			if ( trackExt == "ogg" )
				newCueSheet .= "MP3`n"
			else
				newCueSheet .= "BINARY`n"

			if ( RegExMatch(A_LoopReadLine, "^ *TRACK [0-9]{2} AUDIO") )
				newCuesheet .= A_LoopReadLine "`n"
			else
			  if ( MODE_SIZE == "" ) {
					newCuesheet .= A_LoopReadLine "`n"
			  } else {
					newCuesheet .= RegExReplace( A_LoopReadLine, "^( *TRACK [0-9]{2} MODE.)/.*$", "$1/" MODE_SIZE ) "`n"
			  }

			continue
		}

		if ( RegExMatch(A_LoopReadLine, "^ *PREGAP .*$") ) {
			newCuesheet .= A_LoopReadLine "`n"
			continue
		}

		if ( RegExMatch(A_LoopReadLine, "^ *INDEX [0-9]{2}.*$") ) {
			newCuesheet .= RegExReplace( A_LoopReadLine, "^( *INDEX [0-9]{2}).*$", "$1 00:00:00" ) "`n"
			continue
		}

	}

	FileDelete, % targetFile
	FileAppend, % newCuesheet, % targetFile
}