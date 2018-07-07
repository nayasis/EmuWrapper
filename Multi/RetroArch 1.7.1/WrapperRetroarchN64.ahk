#NoEnv
#include \\NAS\emul\emulator\ZZ_Library\Include.ahk
SetKeyDelay, 10, 0

emulatorPid  := ""
; coreName     := "parallel_n64_libretro.dll"
coreName     := "mupen64plus_libretro.dll"
imageDirPath := %0%
imageDirPath := "\\NAS\emul\image\N64\Legend of Zelda - Ocarina of Time (T-ko)"

imageFilePath := FileUtil.getFile( imageDirPath, "i).*\.(zip|z64|v64)$")

if ( imageFilePath != "" ) {

	command := "retroarch.exe -L ./cores/" coreName " """ imageFilePath """"
	debug( command )

	Run, % command,,Hide,emulatorPid
	waitEmulator()
	IfWinExist
	{
		activateEmulator()		
	  Process, WaitClose, %emulatorPid%
	}

} else {
	Run, % "retroarch.exe",,Hide,
}

ExitApp

waitEmulator() {
	WinWait, ahk_class RetroArch ahk_exe retroarch.exe,, 10
	IfWinExist
	  activateEmulator()
}

activateEmulator() {
	WinActivate, ahk_class RetroArch ahk_exe retroarch.exe,, 10
}

^+Del:: ; Reset
	activateEmulator()
	Send {H Down} {H Up}
	return

^+Insert:: ; Toggle Speed
	Tray.showMessage( "Toggle speed" )
	activateEmulator()
	Send {Space Down} {Space Up}
	return

!Enter:: ;Toggle FullScreen
	activateEmulator()
	Send {f Down} {f Up}
	return