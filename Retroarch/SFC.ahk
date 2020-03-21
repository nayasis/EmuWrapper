#NoEnv
#include %A_ScriptDir%\script\AbstractFunction.ahk

imageDir := %0%
; imageDir := "\\NAS\emul\image\SuperFamicom\Excitebike - Bunbun Mario Battle - Stadium 1 (ja)"
; imageDir := "\\NAS\emul\image\SuperFamicom\Far East Of Eden Zero (T-en 30 by Tom)"

option    := getOption( imageDir )
config    := setConfig( "snes9x_libretro", option )
imageFile := getRomPath( imageDir, option, "zip|7z|smc|sfc" )

writeConfig( config, imageFile )
runEmulator( imageFile, config )

ExitApp

#include %A_ScriptDir%\script\AbstractHotkey.ahk