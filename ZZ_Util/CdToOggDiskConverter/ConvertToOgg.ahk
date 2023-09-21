#NoEnv
#include %A_ScriptDir%\..\..\ZZ_Library\Include.ahk

file := A_ARGS[1]
modeSize     := nvl(A_ARGS[2], "2048")
bchunkOption := nvl(A_ARGS[3], "" )

; file := "e:\download\cdrom\XMEN_COTA_PC.cue"
; bchunkOption := "-r"
; modeSize := "2352"
msgbox, % file "`n" bchunkOption "`n" modeSize
;ExitApp

convert(file, bchunkOption, modeSize)

ExitApp

convert(cuefile, bchunkOption="", modeSize="2048") {

	fileName := FileUtil.getName(cuefile,false)
	workDir  := FileUtil.getDir(cuefile) "\" fileName "-ogg"
	binfile  := FileUtil.getDir(cuefile) "\" fileName ".bin"
	FileUtil.makeDir(workDir)

  debug( ">> extract wav" )
  extractWav(cuefile, binfile, workdir, bchunkOption)

  debug( ">> convert wav to ogg" )
	wavfiles := FileUtil.getFiles( workDir, ".*\.wav" )
	for i, file in wavfiles {
		toOgg(file)
	}

	debug(">> create new cuefile")
	createCuefile(cuefile, workdir, modeSize)

}

extractWav(cuefile, binfile, extractDir, bchunkOption="") {
	fileName := FileUtil.getName(cuefile,false)
	command := % wrap(A_ScriptDir "\util\bchunk.exe") " -v -w " bchunkOption " " wrap(binfile) " " wrap(cuefile) " " wrap(extractDir "\" fileName "-" )
	debug( command )
	RunWait, % command, % workDir, Hide, pid
}

toOgg( wavfile ) {
	workdir := FileUtil.getDir(wavfile)
	oggfile := workdir "\" FileUtil.getName(wavfile, false) ".ogg"
	cmd := A_ScriptDir "\util\oggenc2.exe -n " wrap(oggfile) " " wrap(wavFile)
	debug( cmd )
	RunWait, % cmd, % workdir, Hide, pid
	FileUtil.delete(wavfile)
}

createCuefile( originCuefile, resourceDir, modeSize="2048" ) {

	cueName    := FileUtil.getName( originCuefile, false )
	trackFiles := FileUtil.getFiles( resourceDir, ".*\.(ogg|iso)$" )
	newCuefile := resourceDir "\" cueName ".cue"
	trackIndex := 0
	cursheet   := ""

	Loop, read, % originCuefile
	{
		
		if ( RegExMatch(A_LoopReadLine, "^ *TRACK [0-9]{2} .*$") ) {
			trackIndex++
			trackName := FileUtil.getName( trackFiles[trackIndex] )
			trackExt  := RegExReplace( trackName, ".*\.(.*?)$", "$1" )
			StringLower, trackExt, trackExt

			cursheet .= "FILE """ trackName """ "
			if ( trackExt == "ogg" )
				cursheet .= "OGG`n"
			else if ( trackExt == "mp3" )
				cursheet .= "MP3`n"				
			else
				cursheet .= "BINARY`n"

			if ( RegExMatch(A_LoopReadLine, "^ *TRACK [0-9]{2} AUDIO") )
				cursheet .= A_LoopReadLine "`n"
			else
			  if ( modeSize == "" ) {
					cursheet .= A_LoopReadLine "`n"
			  } else {
					cursheet .= RegExReplace( A_LoopReadLine, "^( *TRACK [0-9]{2} MODE.)/.*$", "$1/" modeSize ) "`n"
			  }

			continue
		}

		if ( RegExMatch(A_LoopReadLine, "^ *PREGAP .*$") ) {
			cursheet .= A_LoopReadLine "`n"
			continue
		}

		if ( RegExMatch(A_LoopReadLine, "^ *INDEX [0-9]{2}.*$") ) {
			cursheet .= RegExReplace( A_LoopReadLine, "^( *INDEX [0-9]{2}).*$", "$1 00:00:00" ) "`n"
			continue
		}

	}

	FileDelete, % newCuefile
	FileAppend, % cursheet, % newCuefile
}