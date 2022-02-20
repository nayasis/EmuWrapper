
#NoEnv
#include %A_ScriptDir%\..\..\ZZ_Library\Include.ahk

cuefile := %0%
; cuefile := "e:\iso\pcecd\Ginga Ojousama Densetsu Yuna 2 (English v1.0).cue"

modeSize := "2352"

debug( "1. Rip disk" )
ripDisk(cuefile,modeSize)

debug( "2. convert wav to ogg" )
toOggs(cueFile)

debug( "3. create ogg cue" )
createOggCue(cuefile,modeSize)

ExitApp

ripDisk(cuefile, modeSize="2352") {

	if ( VirtualDisk.open(cuefile) != true )
		return

	; prepare temp dir
	filename := FileUtil.getName(cuefile,false)
	tmpDir   := toTmpDir(cuefile)
	FileUtil.makeDir( tmpDir )

  ; run turborip
	command := """" A_ScriptDir "\util\TurboRip.exe"" /1 ""/NAME=" tmpDir """"
	if ( modeSize != "" )
		command := command " /RAW " modeSize
	debug( command )
	; RunWait, % command, % tmpDir, Hide, pid
	; RunWait, % command, % tmpDir,, pid
	Run, % command, % tmpDir

  ; waitTurboRipClosed()
  ; renameTempfiles(cuefile)

	; VirtualDisk.close()

}

waitTurboRipClosed() {
	While True
	{
		Sleep, 500
		if WinExist("ahk_exe TurboRip.exe")
		{
			WinActivate
			send {I}
			WinActivate
			send {enter}
		} else {
			Break
		}
	}	
}

renameTempfiles(cuefile) {
	filename := FileUtil.getName(cuefile,false)
	tmpDir   := toTmpDir(cuefile)
	tracks := FileUtil.getFiles(tmpDir, "i).*\.(iso|wav|cue)$", false, true)
	Loop, % tracks.MaxIndex()
	{
		src := tracks[A_Index]
		if ( FileUtil.getExt(src) != "cue" ) {
			trg := FileUtil.getName(src)
			trg := RegExReplace( trg, "^([0-9]{2}) (.+?)\.([a-z]+?)$", filename "-$1.$3" )
		} else {
			trg := filename ".cue"
		}
		FileMove, % src, % tmpDir "\" trg
	}
	debug( ">> delete disc.toc : " tmpDir "\disc.toc" )
	FileDelete, % tmpDir "\disc.toc"
}

toTmpDir(cuefile) {
	return tmpDir   := FileUtil.getDir(cuefile) "\tmp\" FileUtil.getName(cuefile,false)
}

toOggs(cuefile, modeSize="2352") {
	tmpDir := toTmpDir(cuefile)
	wavFiles := FileUtil.getFiles( tmpDir, ".*\.wav" )
	Loop, % wavFiles.MaxIndex()
	{
		toOgg( wavFiles[A_Index] )
	}
}

toOgg( wavefile ) {
	filename := FileUtil.getName(wavefile, false)
	oggfile := FileUtil.getDir(wavefile) "\" filename ".ogg"
	cmd := A_ScriptDir "\util\oggenc2.exe -n """ oggfile """ """ wavefile """"
	debug( "  - " filename )
	RunWait, % cmd,, Hide, pid
	FileDelete, % wavefile
}

createOggCue( cuefile, modeSize="2048" ) {

	cueName    := FileUtil.getName(cuefile, false)
	workDir    := toTmpDir(cuefile)
	trackFiles := FileUtil.getFiles( workDir, ".*-.*\.(ogg|iso)$" )
	targetFile := workDir "\" cueName ".cue"
	trackIndex := 0
	newCuesheet := ""

	Loop, read, % cuefile
	{
		
		if ( RegExMatch(A_LoopReadLine, "^ *TRACK [0-9]{2} .*$") ) {
			trackIndex++
			trackName := FileUtil.getName( trackFiles[trackIndex] )
			trackExt  := RegExReplace( trackName, ".*\.(.*?)$", "$1" )
			StringLower, trackExt, trackExt

			newCueSheet .= "FILE """ trackName """ "
			if ( trackExt == "ogg" )
				newCueSheet .= "OGG`n"
			else if ( trackExt == "mp3" )
				newCueSheet .= "MP3`n"				
			else
				newCueSheet .= "BINARY`n"

			if ( RegExMatch(A_LoopReadLine, "^ *TRACK [0-9]{2} AUDIO") )
				newCuesheet .= A_LoopReadLine "`n"
			else
			  if ( modeSize == "" ) {
					newCuesheet .= A_LoopReadLine "`n"
			  } else {
					newCuesheet .= RegExReplace( A_LoopReadLine, "^( *TRACK [0-9]{2} MODE.)/.*$", "$1/" modeSize ) "`n"
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

