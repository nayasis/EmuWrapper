#NoEnv
#include %A_ScriptDir%\..\..\ZZ_Library\Include.ahk
SetKeyDelay, 10, 0

emulatorPid  := ""
coreName     := "mednafen_pce_fast_libretro.dll"
imageDirPath := %0%
;imageDirPath := "f:\download\TurboRip\Ys IV - The Dawn of Ys {HCD3051-5-1116-R1P} (J)"

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
		WinWait, RetroArch Mednafen PCE Fast,, 10
		activateEmulator()		
		Send {Enter Down} {Enter Up}
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