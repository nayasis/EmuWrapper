#NoEnv
#include %A_ScriptDir%\script\AbstractFunction.ahk

imageDir := %0%
imageDir := "\\NAS\emul\image\PcFx\God Fighter Zeroigar - CirnoRadimore AD (T-en)"

option    := getOption( imageDir )
config    := setConfig( "mednafen_pcfx_libretro", option )
imageFile := getRomPath( imageDir, option, "chd|cue" )

writeConfig( config, imageFile )
runEmulator( imageFile, config, "", "pressStart" )

ExitApp

#include %A_ScriptDir%\script\AbstractHotkey.ahk

pressStart( processId, core, imageFilePath, option ) {
	WinWait, RetroArch Mednafen PC-FX,, 20
	Sleep, 10000
	activateEmulator()
	Send {Enter Down} {Enter Up}
}