#Requires AutoHotkey >=2.0
#Include %A_ScriptDir%\script\AbstractFunction.ahk

imageDir := A_Args.Length ? A_Args[1] : ""
imageDir := "\\NAS2\emul\image\MegaDrive\Bare Knuckle 2 - Shitou heno Chingonka (sega)(ja)"

option    := getOption( imageDir )
config    := setConfig( "genesis_plus_gx_libretro", option, true )
imageFile := getRomPath( imageDir, option, "zip|7z|md|smd|gen|bin|sms|gg" )

writeConfig( config, imageFile )
runEmulator( imageFile, config )

ExitApp

#Include %A_ScriptDir%\script\AbstractHotkey.ahk