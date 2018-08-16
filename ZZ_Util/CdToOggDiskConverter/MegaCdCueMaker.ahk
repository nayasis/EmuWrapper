#NoEnv
#include %A_ScriptDir%\..\..\ZZ_Library\Include.ahk

pathRoot := "\\NAS\emul\image\MegaCd"

; dir := "\\NAS\emul\image\MegaCd\Final Fight CD (En)"
; files := FileUtil.getFiles( dir,  "i).*\.(iso|ogg)", false, true )
; makeCueFile( dir, files )
; ExitApp

files    := FileUtil.getFiles( pathRoot, "i).*\.(iso)", false, true )
gameDirs := {}

debug("Start")

Loop, % files.MaxIndex()
{
	dir := FileUtil.getDir( files[a_index] )
	gameDirs[ dir ] := ""
}

for dir in gameDirs {
	gameDirs[dir] := FileUtil.getFiles( dir,  "i).*\.(iso|ogg)", false, true )
}

for dir, files in gameDirs {
	makeCueFile( dir, files )
}

ExitApp

toCueFile( dir ) {
	return RegExReplace( dir, "^.*\\(.+?)$", "$1") ".cue"
}

makeCueFile( dir, files ) {

	cueFile := dir "\" toCueFile( dir )

	debug( ">> dir : " dir )
	debug( ">> cue : " cueFile )

	cuesheet := ""

	track := 0

	Loop, % files.MaxIndex()
	{

		track ++

		filePath := files[ a_index ]
		fileName := FileUtil.getFileName( filePath )
		fileExt  := FileUtil.getExt( filePath )

		if ( fileExt == "iso" ) {

			cuesheet := cuesheet "FILE """ fileName """ BINARY`n"
			cuesheet := cuesheet "  TRACK 01 MODE1/2048`n"
			cuesheet := cuesheet "  INDEX 01 00:00:00`n"
			cuesheet := cuesheet "  POSTGAP 00:02:00`n"

		} else {

			if ( track < 10 ) {
				tagTrack := "0" track
			} else {
				tagTrack := track
			}

			cuesheet := cuesheet "FILE """ fileName """ WAVE`n"
			cuesheet := cuesheet "  TRACK " tagTrack " AUDIO`n"

			if ( track == 2 ) {
				cuesheet := cuesheet "  PREGAP 00:02:00`n"
			}
			
			cuesheet := cuesheet "  INDEX 01 00:00:00`n"

		}

	}

	; debug( cuesheet )

	FileDelete, % cueFile
	FileAppend, % cuesheet, % cueFile

}