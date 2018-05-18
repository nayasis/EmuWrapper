#NoEnv
#include %A_ScriptDir%\..\..\ZZ_Library\Include.ahk

emulatorPid   := ""
imageFilePath := %0%
;imageFilePath := ""
; imageFilePath := "\\NAS\emul\image\Famicom\action\Mickey Mouse"

romFile := FileUtil.getFile( imageFilePath, "i).*\.(zip|7z)" )

if ( romFile != "" ) {
	RunWait, % "d:\app\Emul\Famicom\nestopiaGit_20141007\nestopia.exe """ romFile """",,,emulatorPid
}

ExitApp

^+Del:: ; Reset
	WinActivate, ahk_class Nestopia ahk_exe nestopia.exe
	; Shift + T
	Send +T
	return

^+Insert:: ; Toggle Speed
	; Tray.showMessage( "Toggle speed" )
	; WinActivate, ahk_class Nestopia ahk_exe nestopia.exe
	; if( GetKeyState( "``" ) == true ) {
	; 	SendInput {`` up}
	; } else {
	; 	SendInput {`` Down}
	; }

	return

;Exit
; ^+F4::
; 	Tray.showMessage( "Close" )
; 	WinActivate, ahk_class Nestopia ahk_exe nestopia.exe
; 	; Alt + X
; 	Send !X
; 	return