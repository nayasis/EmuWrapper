#Requires AutoHotkey >=2.0
#Include %A_ScriptDir%\script\AbstractFunction.ahk

imageDir := A_Args.Length ? A_Args[1] : ""
; imageDir := "\\NAS\emul\image\NGP\Pachisuro Aruze Oogoku Pocket - Oelsol (ja)"

option    := getOption( imageDir )
config    := setConfig( "mednafen_ngp_libretro", option )
imageFile := getRomPath( imageDir, option, "zip|ngc|ngp" )

writeConfig( config, imageFile )
runEmulator( imageFile, config )

ExitApp

#Include %A_ScriptDir%\script\AbstractHotkey.ahk