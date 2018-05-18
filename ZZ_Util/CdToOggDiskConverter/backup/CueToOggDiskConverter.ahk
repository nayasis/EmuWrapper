#NoEnv
#include %A_ScriptDir%\..\..\ZZ_Library\Include.ahk

; pathRoot     := "\\NAS\emul\image\PcFx\Wakusei-Koukitai Little Cats"
pathRoot     := "\\NAS\emul\image\PcFx\Aa! Megami Sama"
pathWorkRoot := "f:\download\pce"
debug( "start" )

files := FileUtil.getFiles( pathRoot, "i).*\.(bin|cue)", false, true )

allFiles := {}
cueFiles := {}

; gathering files
Loop, % files.MaxIndex()
{
	fileSrc := files[ A_Index ]
	dirSrc  := FileUtil.getFileName( FileUtil.getDir( fileSrc ) )
	; remove unrecognized character
	dirSrc  := RegExReplace( dirSrc, "%", "_" )

  if ( allFiles[dirSrc] == "" ) {
  	allFiles[dirSrc] := []
  	cueFiles[dirSrc] := []
  }

  allFiles[dirSrc].insert( fileSrc )

  if ( FileUtil.getExt(fileSrc) == "cue" ) {
  	cueFiles[dirSrc].insert( fileSrc )
  }
}

for gameDir, files in cueFiles {
	workDir  := pathWorkRoot "\" gameDir
	; convert image
	Loop, % files.MaxIndex() {
		cueFile := files[ A_Index ]
		if ( VirtualDisk.open(cueFile) == true ) {
			debug( ">> start convert image : " gameDir " / " cueFile )
			Sleep, 1000
			
			if ( files.MaxIndex() > 1 ) {
				diskName := gameDir " (disk " A_Index ")"
			} else {
				diskName := gameDir
			}
			debug( diskName )
			toCdImage( workDir, diskName )
			debug( ">> done convert image")
			VirtualDisk.close()
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
}

	; if ( VirtualDisk.open(fileSrc) == true ) {

	; 	debug( ">> Work Start : " A_Index " : " dirSrc )
	; 	Sleep, 1000

	; 	workDir := pathWorkRoot "\" getTitle( fileSrc )
		
	; 	toCdImage( workDir, getTitle(fileSrc) )
	; 	; toCdImage( workDir, FileUtil.getFileName(fileSrc, false) )
	
	; 	VirtualDisk.close()

	; 	debug( "  - move compressed image to original folder" )
	; 	subFiles := FileUtil.getFiles( workDir, ".*", false, false )
	; 	Loop, % subFiles.MaxIndex()
	; 	{
	; 		subFile := subFiles[A_Index]
	; 		FileMove, % subFile, % dirSrc
	; 	}
	; 	FileRemoveDir, % workDir

	; 	FileDelete, % fileSrc

	; }

	; debug( ">> Work Done : " A_Index " : " dirSrc )
; }

debug( "end" )

ExitApp


getTitle( filePath ) {
	return RegExReplace( filePath, "^.+\\(.+?)\\.+$", "$1" )
}


toCdImage( workDir, fileName ) {

	FileUtil.makeDir( workDir )	

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
	command := % """" A_ScriptDir "\util\bchunk.exe"" -w -r """ binFile """ """ cueFile """ """ fileName "-"""
	; debug( command )
	RunWait, % command, % workDir, Hide, pid

	FileDelete, % binFile

	debug( "  - convert wav to ogg" )
	wavFiles := FileUtil.getFiles( workDir, ".*\.wav" )
	Loop, % wavFiles.MaxIndex()
	{
		; debug( wavFiles[A_Index] )
		toOgg( wavFiles[A_Index], workDir )
	}

	debug( "  - convert to ogg cue" )
	toOggCue( cueFile, workDir )

}

toOgg( wavFile, targetDir ) {
	targetFile := targetDir "\" FileUtil.getFileName(wavFile, false) ".ogg"
	RunWait, % A_ScriptDir "\util\oggenc2.exe -n """ targetFile """ """ wavFile """", % targetDir, Hide, pid
	FileDelete, % wavFile
}

toOggCue( cueFile, targetDir ) {

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
				newCueSheet .= "OGG`n"
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