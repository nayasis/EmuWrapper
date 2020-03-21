#NoEnv
#include %A_ScriptDir%\script\AbstractFunction.ahk

imageDir := %0%

option    := getOption( imageDir )
config    := setConfig( "genesis_plus_gx_libretro", option )
imageFile := getRomPath( imageDir, option, "zip|md|smd|gen|sms|gg" )

writeConfig( config, imageFile )
runEmulator( imageFile, config )

ExitApp

#include %A_ScriptDir%\script\AbstractHotkey.ahk