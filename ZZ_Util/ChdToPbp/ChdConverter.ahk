#NoEnv
#include %A_ScriptDir%\lib\FileUtil.ahk

imageDir := %0%
; imageDir := "\\NAS\emul\image\PlayStation\Hyper Olympic in Nagano (ja)"

; tempRoot := A_ScriptDir "\_temp"
tempRoot := "f:\_temp"
tempIso  := tempRoot "\iso"
tempPbp  := tempRoot "\pbp"

; prepare temp dir
FileUtil.delete( tempRoot )
FileUtil.makeDir( tempIso )
FileUtil.makeDir( tempPbp )

; CHD to BIN/CUE
toIso( imageDir, tempIso )

; BIN/CUE to PBP
toPbp( tempIso, tempPbp )

; rename file
renamePbp( tempPbp, tempRoot, imageDir )

; delete temp dir
FileUtil.delete( tempIso )
FileUtil.delete( tempPbp )

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
		target  := dirIso "\" isoName
		RunWait "%A_ScriptDir%\lib\chdman.exe" extractcd -i "%file%" -o "%target%.cue" -ob "%target%.bin"	
	}
}

toPbp( dirIso, dirPbp ) {

	Run, "%A_ScriptDir%\lib\PSX2PSP v1.4.2\PSX2PSP.exe" /batch,,,pidPsx2psp
	WinWait, ahk_exe PSX2PSP.exe
	WinActivate
	Clipboard := dirIso
	Sleep, 1000
	Send ^v
	Sleep, 1000
	Send {tab}
	Sleep, 100
	Clipboard := dirPbp
	Sleep, 100
	Send ^v
	Sleep, 100
	Send {tab}{tab}{enter}
	Sleep, 1000

	loop
	{
		ControlGetText, message, TStatusBar1, ahk_exe PSX2PSP.exe
		; debug( message )
		if ( message == "Done." ) {
			Break
		}
		Sleep, 300
	}
	Process, close, % pidPsx2psp

}

renamePbp( dirPbp, targetDir, dirChd ) {

	pbpFile := FileUtil.getFile( dirPbp, "(?i).*\.pbp$", false, true )

	fileName  := FileUtil.getName( dirChd )
	fileExt   := FileUtil.getExt( pbpFile )

	renamedFile := targetDir "\" fileName "." fileExt

	debug( pbpFile " -> " renamedFile )

	FileUtil.move( pbpFile, renamedFile )

}