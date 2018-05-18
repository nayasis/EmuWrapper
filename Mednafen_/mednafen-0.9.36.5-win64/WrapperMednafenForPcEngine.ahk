#NoEnv
#include %A_ScriptDir%\..\..\ZZ_Library\Include.ahk

emulatorPid   := ""
imageFilePath := %0%
;imageFilePath := ""

if ( (romFile := FileUtil.getFile(imageFilePath, "i).*\.(mdx|mdf|cue)" )) != "" ) {

	if ( VirtualDisk.open(romFile) != true )
		ExitApp

	Run, % "mednafen.exe -force_module pce_fast -loadcd pce",,,emulatorPid
	WinWait, ahk_class SDL_app ahk_exe mednafen.exe,, 10
	IfWinExist
	{
		Sleep, 1200
		WinWaitActive, ahk_class SDL_app ahk_exe mednafen.exe,, 10
	  SendKey( "Enter" )
	  Process, WaitClose, %emulatorPid%
	}
	VirtualDisk.close()

} else if( (romFile := FileUtil.getFile(imageFilePath, "i).*\.(zip|pce)" )) != "" ) {
	RunWait, % "mednafen.exe """ romFile """"
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
	WinActivate, ahk_class SDL_app ahk_exe mednafen.exe
	SendInput {Esc}
	return