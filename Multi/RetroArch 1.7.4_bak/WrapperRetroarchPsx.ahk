#NoEnv
#include %A_ScriptDir%\..\..\ZZ_Library\Include.ahk
SetKeyDelay, 10, 0

emulatorPid  := ""
coreName     := "mednafen_psx_libretro"
imageDirPath := %0%
imageDirPath := "\\NAS\emul\image\PlayStation\Chrono Cross (en)"

hasMultiDisc := false

imageFilePath := FileUtil.getFile( imageDirPath, "i).*\.(m3u)$")
if ( imageFilePath == "" ) {
	imageFilePath := FileUtil.getFile( imageDirPath, "i).*\.(cue|chd)$")
} else {
	hasMultiDisc := true
}

if ( imageFilePath != "" ) {

	applyCustomBios( imageDirPath )

	command := "retroarch.exe -L ./cores/" coreName ".dll """ imageFilePath """"

	debug( command )

	Run, % command,,Hide,emulatorPid
	waitEmulator()
	IfWinExist
	{
		WinActivate
	  Process, WaitClose, %emulatorPid%
	}

} else {
	Run, % "retroarch.exe",,Hide,
}

ExitApp

waitEmulator() {
	WinWait, ahk_class RetroArch ahk_exe retroarch.exe,, 10
}

activateEmulator() {
	WinActivate, RetroArch Beetle PSX

	;ahk_class RetroArch ahk_exe retroarch.exe
	; WinActivate, ahk_class RetroArch ahk_exe retroarch.exe
	; WinActivate, ahk_class RetroArch
}

getConfig( key ) {
	Loop, read, % "retroarch.cfg"
	{
		array := StrSplit( A_LoopReadLine, "=" )
		array[1] := trim( array[1] )
		if ( array[1] == key ) {
			array[2] := trim( array[2] )
			return RegExReplace( array[2], "^""(.*)""$", "$1" )
		}
	}
	return ""
}

applyCustomBios( imageDirPath ) {
	systemDir := A_ScriptDir "\system"
	customDir := imageDirPath "\_EL_CONFIG\bios"
	originDir := A_ScriptDir "\system\psx"
	if ( FileUtil.exist(customDir "\*") ) {
		FileUtil.copyFile( customDir "\*", systemDir )
	} else {
		FileUtil.copyFile( originDir "\*", systemDir )
	}
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
	Sleep, 100
	Send {. Down}{. Up}
	debug( "Change Next Disc" )
	Sleep, 100
	Send {/ Down}{/ Up}
	debug( "Close Tray" )
	return

; Change Previous CD-ROM
^+PGDN::
	if ( hasMultiDisc == false ) return
	activateEmulator()
	Send {/ Down}{/ Up}
	debug( "Open Tray" )
	Sleep, 100
	Send {, Down}{, Up}
	debug( "Change Previous Disc" )
	Sleep, 100
	Send {/ Down}{/ Up}
	debug( "Close Tray" )
	return