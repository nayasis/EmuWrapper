#NoEnv
#include %A_ScriptDir%\script\AbstractFunction.ahk

imageDir := %0%
; imageDir := "\\NAS2\emul\image\3DO\Policenauts (konami)(ja)"

option    := getOption( imageDir )
config    := setConfig( "4do_libretro", option )
imageFile := getRomPath( imageDir, option, "m3u|chd|cue|iso" )

writeConfig( config, imageFile )
runEmulator( imageFile, config )

ExitApp

#include %A_ScriptDir%\script\AbstractHotkey.ahk