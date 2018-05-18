#NoEnv
#include %A_ScriptDir%\..\..\ZZ_Library\Include.ahk

emulatorPid   := ""
imageFilePath := %0%
; imageFilePath := "\\NAS\emul\image\Model2\daytona"

romName := getExecutableRom( imageFilepath )
debug( "romName : " romName )

if ( romName != "" ) {

	setIniFile( imageFilepath )

	cmd := "EmulatorMultiCore.exe " romName

	debug( cmd )
	RunWait, % cmd,,,emulatorPid

} else {
	Run, % "EmulatorMultiCore.exe",,,emulatorPid
}

ExitApp

setIniFile( imageFilePath ) {
	iniFile := A_ScriptDir "\EMULATOR.INI"
	IniWrite, % imageFilePath, % iniFile, RomDirs, Dir2	
}

getExecutableRom( imageFilePath ) {
	
	dirConf := imageFilepath "\_EL_CONFIG"
	FileUtil.makeDir( dirConf )

	; read json option
	IfExist %dirConf%\option\option.json
	{

		FileRead, jsonText, %dirConf%\option\option.json
		jsonObj := JSON.load( jsonText )

		if( jsonObj.run.rom != "" )
			return jsonObj.run.rom

	}

	return ""

}

^+Del:: ; Reset
	WinActivate, ahk_exe EmulatorMultiCore.exe
	Sleep, 100
	Send {F3 down}{F3 up}
	return

; ^+Insert:: ; Toggle Speed
; 	Tray.showMessage( "Toggle speed" )
; 	WinActivate, ahk_exe EmulatorMultiCore.exe
; 	if( GetKeyState( "``" ) == true ) {
; 		SendInput {`` up}
; 	} else {
; 		SendInput {`` Down}
; 	}
; 
;   return

; !F4:: ;Exit
; 	Tray.showMessage( "Close" )
; 	WinActivate, ahk_class SDL_app ahk_exe mednafen.exe
; 	SendInput {Esc}
; 	return

