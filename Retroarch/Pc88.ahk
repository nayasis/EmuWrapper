#NoEnv
#include %A_ScriptDir%\script\AbstractFunction.ahk

imageDirPath := %0%
; imageDirPath := "e:\download\Alfaim (1989)(Xain)"

option := getOption( imageDirPath )
config := setConfig( "quasi88_libretro", option )

imageFilePath := getRomPath( imageDirPath, option, "m3u|d88|fdd" )
runEmulator( imageFilePath, config )

ExitApp

#include %A_ScriptDir%\script\AbstractHotkey.ahk