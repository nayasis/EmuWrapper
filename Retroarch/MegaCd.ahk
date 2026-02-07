#Requires AutoHotkey >=2.0
#Include %A_ScriptDir%\script\AbstractFunction.ahk

imageDir := A_Args.Length ? A_Args[1] : ""
; imageDir := "\\NAS\emul\image\MegaCd\Popful Mail (en)"

option    := getOption( imageDir )
config    := setConfig( "genesis_plus_gx_libretro", option )
imageFile := getRomPath( imageDir, option, "m3u|cue|chd|iso" )

writeConfig( config, imageFile )
runEmulator( imageFile, config )

ExitApp

#Include %A_ScriptDir%\script\AbstractHotkey.ahk