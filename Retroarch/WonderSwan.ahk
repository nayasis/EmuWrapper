#NoEnv
#include %A_ScriptDir%\script\AbstractFunction.ahk

imageDir := %0%
; imageDir := "\\NAS\emul\image\SuperFamicom\Far East Of Eden Zero (T-en 30 by Tom)"

option    := getOption( imageDir )
config    := setConfig( "mednafen_wswan_libretro", option )
imageFile := getRomPath( imageDir, option, "ws|wsc|7z|zip" )

writeConfig( config, imageFile )
runEmulator( imageFile, config )

ExitApp

#include %A_ScriptDir%\script\AbstractHotkey.ahk