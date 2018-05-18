#NoEnv
#include %A_ScriptDir%\..\..\ZZ_Library\Include.ahk

emulatorPid   := ""
imageFilePath := %0%
; imageFilePath := "\\NAS\emul\image\Famicom\rpg\God Slayer - Haruka Tenkuu no Sonata (Jp)"

romFile := FileUtil.getFile( imageFilePath, "i).*\.(zip|7z)" )

if ( romFile != "" ) {
	RunWait, % "mednafen.exe """ romFile """",,,emulatorPid
}

ExitApp

^+Del:: ; Reset
	WinActivate, ahk_class SDL_app ahk_exe mednafen.exe
	Send {F11}
	return

^+Insert:: ; Toggle Speed
	Tray.showMessage( "Toggle speed" )
	WinActivate, ahk_class SDL_app ahk_exe mednafen.exe
	if( GetKeyState( "``" ) == true ) {
		SendInput {`` up}
	} else {
		SendInput {`` Down}
	}

	return

!F4:: ;Exit
	Tray.showMessage( "Close" )
	WinActivate, ahk_class SDL_app ahk_exe mednafen.exe
	SendInput {Esc}
	return