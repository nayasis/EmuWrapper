#Requires AutoHotkey >=2.0
#Include %A_ScriptDir%\script\AbstractFunction.ahk

imageDir := A_Args.Length ? A_Args[1] : ""
; imageDir := "\\NAS\emul\image\NeoGeo CD\2020 Super Baseball (en)"

option    := getOption( imageDir )
config    := setConfig( "neocd_libretro", option )
imageFile := getRomPath( imageDir, option, "chd|cue" )

writeConfig( config, imageFile )
runEmulator( imageFile, config )

ExitApp

#Include %A_ScriptDir%\script\AbstractHotkey.ahk