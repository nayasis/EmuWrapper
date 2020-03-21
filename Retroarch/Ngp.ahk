#NoEnv
#include %A_ScriptDir%\script\AbstractFunction.ahk

imageDir := %0%
; imageDir := "\\NAS\emul\image\NGP\Pachisuro Aruze Oogoku Pocket - Oelsol (ja)"

option    := getOption( imageDir )
config    := setConfig( "mednafen_ngp_libretro", option )
imageFile := getRomPath( imageDir, option, "zip|ngc|ngp" )

writeConfig( config, imageFile )
runEmulator( imageFile, config )

ExitApp

#include %A_ScriptDir%\script\AbstractHotkey.ahk