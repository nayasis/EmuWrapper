#NoEnv
#include %A_ScriptDir%\script\AbstractFunction.ahk

imageDir := %0%
; imageDir := "\\NAS2\emul\image\Handheld\ra_mariosba"

option    := getOption( imageDir )
config    := setConfig( "gw_libretro", option, false )
imageFile := getRomPath( imageDir, option, "zip|7z" )

writeConfig( config, imageFile )
runEmulator( imageFile, config )
waitEmulator(1)
IfWinExist
{
	waitCloseEmulator()
}


ExitApp

#include %A_ScriptDir%\script\AbstractHotkey.ahk