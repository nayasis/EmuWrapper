#NoEnv
; #include %A_ScriptDir%\..\..\ZZ_Library\Include.ahk
#include \\NAS\emul\emulator\ZZ_Library\Include.ahk

SetKeyDelay, 10, 0

emulatorPid  := ""
coreName     := "mednafen_saturn_libretro"
imageDirPath := %0%
imageDirPath := "\\NAS\emul\image\Saturn\Grandia (T-ko)"

hasMultiDisc := false

imageFilePath := FileUtil.getFile( imageDirPath, "i).*\.(m3u)$")
if ( imageFilePath == "" ) {
	imageFilePath := FileUtil.getFile( imageDirPath, "i).*\.(cue|chd)$")
} else {
	hasMultiDisc := true
}

if ( imageFilePath != "" ) {

	command := "retroarch.exe -L ./cores/" coreName ".dll """ imageFilePath """"
	debug( command )

	Run, % command,,Hide,emulatorPid
	waitEmulator()
	IfWinExist
	{
		WinWait, RetroArch Mednafen Saturn,, 20
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

; Change Next CD-ROM
^+PGUP::
	if ( hasMultiDisc == false ) return
	activateEmulator()
	Send {/ Down}{/ Up}
	debug( "Open Tray" )
	Sleep, 40
	Send {. Down}{. Up}
	debug( "Change Next Disc" )
	Sleep, 40
	Send {/ Down}{/ Up}
	debug( "Close Tray" )
	return

; Change Previous CD-ROM
^+PGDN::
	if ( hasMultiDisc == false ) return
	activateEmulator()
	Send {/ Down}{/ Up}
	debug( "Open Tray" )
	Sleep, 40
	Send {, Down}{, Up}
	debug( "Change Previous Disc" )
	Sleep, 40
	Send {/ Down}{/ Up}
	debug( "Close Tray" )
	return