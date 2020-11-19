#NoEnv
#include %A_ScriptDir%\script\AbstractFunction.ahk

imageDir := %0%
; imageDir := "\\NAS\emul\image\SuperFamicom\BS Legend of Zelda 1 - Kodai no Sekiban (J)"

option := getOption( imageDir )
config := setConfig( "", option )

imageFile := getRomPath( imageDir, option, "zip|7z|fds|gb" )
runEmulator( imageFile, config )

ExitApp

#include %A_ScriptDir%\script\AbstractHotkey.ahk
