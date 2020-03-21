#NoEnv
#include %A_ScriptDir%\script\AbstractFunction.ahk

imageDir := %0%
; imageDir := "\\NAS\game\console\PS2\image\God of war (ko)"
; imageDir := "e:\download\test-gc"

option    := getOption( imageDir )
config    := setConfig( "play_libretro", option )
imageFile := getRomPath( imageDir, option, "m3u|chd|gcz|cue|iso" )

writeConfig( config, imageFile )
runEmulator( imageFile, config )

ExitApp

#include %A_ScriptDir%\script\AbstractHotkey.ahk