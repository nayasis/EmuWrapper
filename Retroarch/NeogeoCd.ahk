#NoEnv
#include %A_ScriptDir%\script\AbstractFunction.ahk

imageDir := %0%
; imageDir := "\\NAS\emul\image\NeoGeo CD\2020 Super Baseball (en)"

option    := getOption( imageDir )
config    := setConfig( "neocd_libretro", option )
imageFile := getRomPath( imageDir, option, "chd|cue" )

writeConfig( config, imageFile )
runEmulator( imageFile, config )

ExitApp

#include %A_ScriptDir%\script\AbstractHotkey.ahk