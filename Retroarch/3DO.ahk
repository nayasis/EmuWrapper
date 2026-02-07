#Requires AutoHotkey >=2.0
#Include %A_ScriptDir%\script\AbstractFunction.ahk

imageDir := A_Args.Length ? A_Args[1] : ""
;imageDir := "\\NAS2\emul\image\3DO\Policenauts (konami)(ja)"

option    := getOption( imageDir )
config    := setConfig( "opera_libretro", option )
imageFile := getRomPath( imageDir, option, "m3u|chd|cue|iso" )

writeConfig( config, imageFile )
runEmulator( imageFile, config )

ExitApp

#Include %A_ScriptDir%\script\AbstractHotkey.ahk