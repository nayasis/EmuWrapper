#NoEnv
#include %A_ScriptDir%\..\..\ZZ_Library\Include.ahk

emulatorPid   := ""
imageFilePath := %0%
;imageFilePath := ""
;imageFilePath := "\\NAS\emul\image\SuperFamicom\action\Act Raiser 1 (En)\Act Raiser 1 (US).zip"

romFile := FileUtil.getFile( imageFilepath, "i).*\.(zip|cue)" )
if( romFile == "" ) {
	romFile := FileUtil.getFile( imageFilepath, "i).*\.(iso)" )
}
if( romFile != "" ) {
	RunWait, Fusion.exe "%romFile%"	
	ExitApp
}

ExitApp

^+Del:: ; Reset
	sendKey( "Tab" )
	return

^+Insert:: ; Toggle Speed
	Tray.showMessage( "Toggle speed" )
	sendKey( "BackSpace" )
	return