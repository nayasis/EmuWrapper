#NoEnv
#include %A_ScriptDir%\..\..\ZZ_Library\Include.ahk

emulatorPid   := ""
imageFilePath := %0%
; imageFilePath := "\\NAS\emul\image\PcEngineCd\ACTION\Castlevania - Rondo of Blood (En)"

if ( (romFile := FileUtil.getFile(imageFilepath, "i).*\.(mdx|mdf|cue)" )) != "" ) {

	if ( VirtualDisk.open(romFile) != true )
		ExitApp

	Run, % "pce.exe ""./cards/Super CD-ROM2 System V3.01 (En).zip"" -cd",,,emulatorPid
	WinWait, ahk_class MagicEngineWindowClass,, 20
	IfWinExist
	{
		WinActivate, ahk_class MagicEngineWindowClass
		SendKey( "Home" )
	  SendKey( "Enter" )
	  Sleep, 400
	  WinActivate, ahk_class MagicEngineWindowClass
    SendKey( "Down" )
	  SendKey( "Enter" )
	  Sleep, 1200
	  WinActivate, ahk_class MagicEngineWindowClass
		sendKey( "Enter" )
		WinWaitClose
	}
	VirtualDisk.close()

} else if( (romFile := FileUtil.getFile(imageFilepath, "i).*\.(zip|pce)" )) != "" ) {
	debug( "pce.exe """ romFile """" )
	RunWait, % "pce.exe """ romFile """"
} else {
	Run, % "pce.exe"
}

ExitApp


^+Del:: ; Reset
	SendKey( "Esc" )
	SendKey( "Home" )
	SendKey( "Down" )
	SendKey( "Enter" )
	return

^+Insert:: ; Toggle Speed

	Tray.showMessage( "Toggle speed" )

	if( GetKeyState( "Tab" ) == true ) {
		SendInput {Tab up}
	} else {
		SendInput {Tab Down}
	}

	return
