#NoEnv
#include \\NAS\emul\emulator\ZZ_Library\Include.ahk
SetKeyDelay, 10, 0

arguments := getArguments()

imageDirPath  := nvl( arguments[0] )
coreName      := nvl( arguments[1], "mednafen_ngp_libretro" )

; imageDirPath := "f:\download\ngp\Samurai Shodown! 2 - Pocket Fighting Series (W) [!].ngc"

imageFilePath := FileUtil.getFile( imageDirPath, "i).*\.(zip|ngc|ngp)$")


if ( imageFilePath != "" ) {

	command := "retroarch.exe -L ./cores/" coreName ".dll """ imageFilePath """"
	debug( command )

	Run, % command,,Hide,emulatorPid
	waitEmulator()
	IfWinExist
	{
		activateEmulator()		
	  Process, WaitClose, %emulatorPid%
	}

} else {
	RunWait, % "retroarch.exe",,Hide,
}

ExitApp

nvl( val, defaultVal="" ) {
	if ( val == null || val == "" ) {
		return defaultVal
	} else {
		return val
	}
}

getArguments() {
	array := []
	for i, param in A_Args {
		array[ i - 1 ] := param
	}
	return array
}

waitEmulator() {
	WinWait, ahk_class RetroArch ahk_exe retroarch.exe,, 20
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