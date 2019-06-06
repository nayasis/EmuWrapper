#NoEnv
#include %A_ScriptDir%\lib\FileUtil.ahk

imageDir := %0%
imageDir := "\\NAS\emul\image\PlayStation\Final Fantasy Tactics - Complete v2 (en)"

; tempRoot := A_ScriptDir "\_temp"
tempRoot := "f:\_temp\" FileUtil.getName( imageDir )
tempIso  := tempRoot "\iso"
tempPbp  := tempRoot "\pbp"

; prepare temp dir
FileUtil.delete( FileUtil.getParentDir(tempRoot) )
FileUtil.makeDir( tempIso )
FileUtil.makeDir( tempPbp )

; CHD to BIN/CUE
toIso( imageDir, tempIso )

; BIN/CUE to PBP
toPbp( tempIso, tempPbp )

makeM3U( tempRoot )

Exit

debug( message ) {
 if( A_IsCompiled == 1 )
   return
  message .= "`n" 
  FileAppend %message%, * ; send message to stdout
}

toIso( dirChd, dirIso ) {
	chdFiles := FileUtil.getFiles( dirChd, "(?i).*\.chd$", false, true )
	for i, file in chdFiles {
		isoName := FileUtil.getName( file, false )
		FileUtil.makeDir( dirIso "\disk" i )
		target  := dirIso "\disk" i "\" isoName
		RunWait "%A_ScriptDir%\lib\chdman.exe" extractcd -i "%file%" -o "%target%.cue" -ob "%target%.bin"	
	}
}

toPbp( dirIso, dirPbp ) {

	cueFiles := FileUtil.getFiles( dirIso, "(?i).*\.bin$", true, true )

	dirRoot := FileUtil.getParentDir( dirPbp )

	for i, srcFile in cueFiles {

		srcDir := FileUtil.getDir( srcFile )
		trgDir := dirPbp "\" FileUtil.getName( srcDir )

		debug( srcFile " -> " dirPbp )

		toSinglePbp( srcFile, dirPbp )

		name   := FileUtil.getName( srcFile, false )
		srcPbp := FileUtil.getFile( dirPbp, "(?i).*\.pbp$", false, true )
		trgPbp := dirRoot "\" name ".pbp"
		FileUtil.move( srcPbp, trgPbp )

	}

	FileUtil.delete( dirIso )
	FileUtil.delete( dirPbp )

}

toSinglePbp( srcFile, trgDir ) {

	FileUtil.makeDir( trgDir )

	Run, "%A_ScriptDir%\lib\PSX2PSP v1.4.2\PSX2PSP.exe",,,pidPsx2psp
	WinWait, ahk_exe PSX2PSP.exe
	WinActivate
	Click, 254, 57

	Clipboard := srcFile

	WinWait, Open input file
	WinActivate
	Sleep, 300
	Send ^v
	Sleep, 100
	Send {Enter}
	Send {Tab}
	Sleep, 100
	Clipboard := trgDir
	Sleep, 100
	Send ^v
	Sleep, 100

	Send {Tab}{Tab}{Tab}{Tab}{Tab}{Tab}{Tab}{Tab}{Tab}
	Send {Enter}

	Sleep, 1000

	loop
	{
		ControlGetText, message, TStatusBar1, ahk_exe PSX2PSP.exe
		; debug( InStr( message, "Done." ) " >> " message )
		if ( InStr( message, "Done." ) == 1 ) {
			Break
		}
		Sleep, 300
	}
	Process, close, % pidPsx2psp

}

makeM3U( dirRoot ) {

	pbpFiles := FileUtil.getFiles( dirRoot, "(?i).*\.pbp$", false, true )

	if ( pbpFiles.MaxIndex() <= 1 )
		return

	m3uText := ""
	fileM3u := FileUtil.getName( dirRoot, false ) ".m3u"

	for i, pbpFile in pbpFiles {
		fileName := FileUtil.getName( pbpFile, false ) ".pbp"
		m3uText .= fileName "`n"
	}

	FileAppend, % m3uText, % dirRoot "/" fileM3u

}