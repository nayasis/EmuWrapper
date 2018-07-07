#NoEnv
#include %A_ScriptDir%\..\..\ZZ_Library\Include.ahk
SetKeyDelay, 10, 0

emulatorPid  := ""
coreName     := "mednafen_pcfx_libretro.dll"
imageDirPath := %0%
; imageDirPath := "f:\download\pce\Aa! Megami Sama"
; imageDirPath := "\\NAS\emul\image\PcFx\Doukyusei II"

imageFilePath := FileUtil.getFile( imageDirPath, "i).*\.(m3u)$")
if ( imageFilePath == "" ) {
	imageFilePath := FileUtil.getFile( imageDirPath, "i).*\.(cue|chd)$")
}

if ( imageFilePath != "" ) {

	command := "retroarch.exe -L ./cores/" coreName " """ imageFilePath """"
	debug( command )

	Run, % command,,Hide,emulatorPid
	waitEmulator()
	IfWinExist
	{
		;RetroArch Mednafen PCE Fast v0.9.38.7 d2080d7 || Frames: 3328
		WinWait, RetroArch Mednafen PC-FX,, 20
		activateEmulator()
		Sleep, 10000
		Send {Enter Down} {Enter Up}
		debug( "Enter !")
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