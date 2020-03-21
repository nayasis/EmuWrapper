#NoEnv
#include %A_ScriptDir%\script\AbstractFunction.ahk

imageDir := %0%
; imageDir := "\\NAS\emul\image\PcEngineCd\Bonanza Brothers (ja)"

option    := getOption( imageDir )
config    := setConfig( "mednafen_pce_fast_libretro", option )
imageFile := getRomPath( imageDir, option, "chd|cue" )

writeConfig( config, imageFile )
runEmulator( imageFile, config, "", "pressStart" )

ExitApp

#include %A_ScriptDir%\script\AbstractHotkey.ahk

pressStart( processId, core, imageFilePath, option ) {
	WinWait, RetroArch Beetle PCE Fast,, 10
	activateEmulator()
	Send {Enter Down}
	Sleep 20
	Send {Enter Up}
}