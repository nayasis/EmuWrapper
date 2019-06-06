#NoEnv
#include %A_ScriptDir%\..\..\ZZ_Library\Include.ahk

emulatorPid := ""

imageDirPath := %0%
; imageDirPath := "\\NAS\emul\image\N64\Legend of Zelda - Majora's Mask (T-ko)"

romFile := FileUtil.getFile( imageDirPath, "i).*\.(zip|7z)" )

if ( romFile != "" ) {
	RunWait, % "Project64 """ romFile """",,,emulatorPid
} else {
  Run, % "Project64.exe " config,,,emulatorPid
}

ExitApp	


!F4:: ; ALT + F4
	Process, Close, %emulatorPid%
  return
	
^+Del:: ; Reset
	activateEmulator()
	Send {F1}
	return

^+Insert:: ; Toggle Speed
	Tray.showMessage( "Toggle speed not supported" )
	return

activateEmulator() {
	WinActivate, ahk_exe Project64.exe	
}

waitEmulator() {
	WinWait, ahk_exe Project64.exe,, 10
	IfWinExist
		activateEmulator()
}