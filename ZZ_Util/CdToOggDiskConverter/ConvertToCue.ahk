#NoEnv
#include %A_ScriptDir%\..\..\ZZ_Library\Include.ahk

file := %0%
; file := "e:\download\pc98\KSS\Dragon Lore\Dragon Lore (Disc 1).ccd"

toIso(file)

ExitApp

toIso(cuefile) {
	if ( VirtualDisk.open(cuefile) == true ) {
		trgfile := FileUtil.getDir(cuefile) "\" FileUtil.getName(cuefile,false) ".bin"
		debug( ">> convert img(" cuefile ") to cue(" trgfile ")" )
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