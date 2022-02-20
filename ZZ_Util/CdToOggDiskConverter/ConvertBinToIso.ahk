#NoEnv
#include %A_ScriptDir%\..\..\ZZ_Library\Include.ahk

imageDir := %0%
; imageDir := "e:\iso\ps2"

files := FileUtil.getFiles( imageDir, "i).*\.(cue)", false, false )

for i, cuefile in files {
	toIso(cuefile)
}

ExitApp

toIso(cuefile) {
	if ( VirtualDisk.open(cuefile) == true ) {
		trgfile := FileUtil.getDir(cuefile) "\" FileUtil.getName(cuefile,false) ".iso"
		debug( ">> convert cue[" cuefile "] to iso[" trgfile "]" )
		sleep, 500
		command := % """" A_ScriptDir "\util\ImgBurn.exe"" /MODE READ /SRC G: /DEST """ trgfile """ /START /CLOSE"
		Run, % command,, Hide, pid
		WinWait, ahk_exe ImgBurn.exe, ISO is not an appropriate container format for the current disc but today is your lucky day and I will make the necessary adjustments (convert MODE2/FORM1 to MODE1) if you want me to?,2000
		IfWinExist
		{
			WinActivate
			Send {Enter}
		}
		WinWaitClose, ahk_exe ImgBurn.exe
		VirtualDisk.close()
	}
}