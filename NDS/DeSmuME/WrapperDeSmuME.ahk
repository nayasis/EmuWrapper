#NoEnv
#include %A_ScriptDir%\..\..\ZZ_Library\Include.ahk

emulatorPid   := ""
imageFilePath := %0%
; imageFilePath := "d:\_backup\download\NDS_Korean\Final Fantasy 4"

romFile := FileUtil.getFile( imageFilePath, "i).*\.(zip|nds)" )

debug( "??" )
debug( romFile )

if ( romFile != "" ) {
	Run, % "DeSmuME-x64.exe """ romFile """",,,emulatorPid

  ; hide console window
	WinWait, ahk_class ConsoleWindowClass ahk_exe DeSmuME-x64.exe
	IfWinExist
		WinHide

  ; wait emulator to close
	waitEmulator()
	IfWinExist
		Process, WaitClose, %emulatorPid%

}

ExitApp

waitEmulator() {
	WinWait, ahk_class DeSmuME ahk_exe DeSmuME-x64.exe,, 30
	IfWinExist
	  activateEmulator()
}

activateEmulator() {
	WinActivate, ahk_class DeSmuME ahk_exe DeSmuME-x64.exe,, 10
}

^+Del:: ; Reset
	activateEmulator()
	Send !frrr{enter}
	return

^+Insert:: ; Toggle Speed
	Tray.showMessage( "Toggle speed" )
	activateEmulator()
	Send {Space down}{Space up}
	return