#NoEnv
#include %A_ScriptDir%\script\AbstractFunction.ahk

imageDir := %0%
; imageDir := "\\NAS2\emul\image\MegaDrive\action\Sonic the Hedgehog (En)"

option    := getOption( imageDir )
config    := setConfig( "genesis_plus_gx_libretro", option )
imageFile := getRomPath( imageDir, option, "zip|7z|md|smd|gen|sms|gg" )

writeConfig( config, imageFile )
runEmulator( imageFile, config )

ExitApp

#include %A_ScriptDir%\script\AbstractHotkey.ahk