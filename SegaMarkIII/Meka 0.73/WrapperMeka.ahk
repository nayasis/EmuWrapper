#NoEnv
#include %A_ScriptDir%\..\..\ZZ_Library\Include.ahk

emulatorPid   := ""
imageFilePath := %0%
;imageFilePath := ""
;imageFilePath := "\\NAS\emul\image\SuperFamicom\action\Act Raiser 1 (En)\Act Raiser 1 (US).zip"

romFile := FileUtil.getFile( imageFilepath, "i).*\.(zip|sms)" )
if( romFile != "" ) {
	RunWait, mekaw.exe "%romFile%"	
	ExitApp
}

ExitApp

^+Del:: ; Reset
	sendKey( "Tab" )
	return

^+Insert:: ; Toggle Speed
	Tray.showMessage( "Toggle speed" )
	Send ^{Tab}
	return

!F4:: ; ALT + F4
	Send ^{F4}
  return	