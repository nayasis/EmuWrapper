#NoEnv
#include %A_ScriptDir%\..\..\ZZ_Library\Include.ahk

cueFile   := "disk.cue"
targetDir := "\\NAS\emul\image\NeoGeo CD\Samurai Shodown 2 (en)"

toOggCue( cueFile, targetDir, "MODE1/2048" )


ExitApp

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

toOggCue( cueFile, targetDir, dataTrack="MODE1/2048" ) {

	targetFile  := targetDir "\" cueFile
	trackFiles  := FileUtil.getFiles( targetDir, ".*\.(ogg|mp3|iso)$" )
	newCuesheet := ""

	debug( targetFile )

	for index, file in trackFiles	{

		trackNamePrev := FileUtil.getFileName( trackFiles[index - 1] )
		trackName     := FileUtil.getFileName( file )
		trackExt      := FileUtil.getExt( file )
		trackNo       := index < 10 ? "0" index : index

		newCueSheet .= "FILE """ trackName """ "
		
		if ( trackExt == "iso" ) {
			newCueSheet .= "BINARY`n  TRACK " trackNo " " dataTrack "`n  INDEX 01 00:00:00" "`n  POSTGAP 00:02:00`n"
		} else {
			newCueSheet .= "WAVE`n  TRACK " trackNo " AUDIO`n"
			if ( FileUtil.getExt(trackNamePrev) == "iso" ) {
				newCueSheet .= "  PREGAP 00:02:00`n"
			}
			newCueSheet .= "  INDEX 01 00:00:00`n"
		}

	}

	FileDelete, % targetFile
	FileAppend, % newCuesheet, % targetFile

}