#NoEnv
#include %A_ScriptDir%\script\AbstractFunction.ahk

imageDir := %0%
; imageDir := "\\NAS\emul\image\MSX\XZR II (T-ko)"

option    := getOption( imageDir )
; config    := setConfig( "fmsx_libretro", option )
config    := setConfig( "bluemsx_libretro", option )
imageFile := getRomPath( imageDir, option, "m3u|zip|7z|rom|dsk" )

writeConfig( config, imageFile )
runEmulator( imageFile, config )

ExitApp

#include %A_ScriptDir%\script\AbstractHotkey.ahk