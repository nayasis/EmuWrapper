#NoEnv
#include %A_ScriptDir%\script\AbstractFunction.ahk

imageDir := %0%
; imageDir := "\\NAS\emul\image\GameCube\Star Wars Jedi Knight II - Jedi Outcast (en)"

option    := getOption( imageDir )
config    := setConfig( "dolphin_libretro", option )
imageFile := getRomPath( imageDir, option, "m3u|chd|gcz|cue|iso" )

writeConfig( config, imageFile )
runEmulator( imageFile, config )

ExitApp

#include %A_ScriptDir%\script\AbstractHotkey.ahk