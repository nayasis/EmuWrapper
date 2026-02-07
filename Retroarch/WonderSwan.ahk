#Requires AutoHotkey >=2.0
#Include %A_ScriptDir%\script\AbstractFunction.ahk

imageDir := A_Args.Length ? A_Args[1] : ""
; imageDir := "\\NAS\emul\image\WonderSwan\Gunpey EX (koto)(ja)"

option    := getOption( imageDir )
config    := setConfig( "mednafen_wswan_libretro", option )
imageFile := getRomPath( imageDir, option, "ws|wsc|7z|zip" )

writeConfig( config, imageFile )
runEmulator( imageFile, config )

ExitApp

#Include %A_ScriptDir%\script\AbstractHotkey.ahk