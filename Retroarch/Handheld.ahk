#Requires AutoHotkey >=2.0
#Include %A_ScriptDir%\script\AbstractFunction.ahk

imageDir := A_Args.Length ? A_Args[1] : ""
; imageDir := "\\NAS2\emul\image\Handheld\Game & Watch - Mario Bros"

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

#Include %A_ScriptDir%\script\AbstractHotkey.ahk