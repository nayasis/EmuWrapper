#NoEnv
#include %A_ScriptDir%\script\AbstractFunction.ahk

imageDir := %0%
; imageDir := "\\NAS\emul\image\Famicom\Contra (T-en 1.0)"
imageDir := "\\NAS\emul\image\Famicom\Duck Hunt (en)"

option    := getOption( imageDir )
config    := setConfig( "mesen_libretro", option )
; config    := setConfig( "nestopia_libretro", option )
imageFile := getRomPath( imageDir, option, "zip|7z|nes" )

writeConfig( config, imageFile )
runEmulator( imageFile, config )

ExitApp

#include %A_ScriptDir%\script\AbstractHotkey.ahk