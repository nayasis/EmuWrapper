#NoEnv
#include %A_ScriptDir%\..\..\ZZ_Library\Include.ahk

emulatorPid  := ""
imageDirPath := %0%
; imageDirPath := "\\NAS\emul\image\Saturn\Grandia (T-ko)"

hasMultiDisc := false

imageFilePath := FileUtil.getFile( imageDirPath, "i).*\.(m3u)$")
if ( imageFilePath == "" ) {
	imageFilePath := FileUtil.getFile( imageDirPath, "i).*\.(cue)$")
} else {
	hasMultiDisc := true
}

if ( imageFilePath != "" ) {
	RunWait, % "mednafen.exe """ imageFilePath """",,,emulatorPid
}

ExitApp

waitEmulator() {
	WinWait, ahk_class SDL_app ahk_exe mednafen.exe,, 10
	IfWinExist
	  activateEmulator()
}

activateEmulator() {
	WinActivate, ahk_class SDL_app ahk_exe mednafen.exe,, 10
}

; Change CD rom
^+PGUP::
	if ( hasMultiDisc == false ) return
	activateEmulator()
	Send {F8 Down}{F8 Up}
	debug( "Open Tray" )
	Sleep, 40
	Send {F6 Down}{F6 Up}
	debug( "Swap disc" )
	Sleep, 40
	Send {F8 Down}{F8 Up}
	debug( "Close Tray" )
	return

; Reset
^+Del:: 
	activateEmulator()
	Send {F11 Down}{F11 Up}
	return

; Toggle Speed
^+Insert::
	Tray.showMessage( "Toggle speed" )
	activateEmulator()
	if( GetKeyState( "``" ) == true ) {
		SendInput {`` up}
	} else {
		SendInput {`` Down}
	}

	return

;Exit
!F4::
	Tray.showMessage( "Close" )
	activateEmulator()
	Send {Esc Down}{Esc Up}
	return