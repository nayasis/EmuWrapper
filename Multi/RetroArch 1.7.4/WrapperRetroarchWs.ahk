#NoEnv
#include WrapperAbstrctFunction.ahk

imageDirPath := %0%
; imageDirPath := "\\NAS\emul\image\Famicom\rpg\Dragon Warrior 1 (En)"
; imageDirPath := "\\NAS\emul\image\SuperFamicom\Far East Of Eden Zero (T-en 30 by Tom)"

option := getOption( imageDirPath )
core   := getCore( option, "mednafen_wswan_libretro" )
filter := getFilter( option, "ws|wsc|7z|zip" )

modifyConfigDefault( option )
modifyConfigCore( option )

imageFilePath := getRomPath( imageDirPath, option, filter )

runRomEmulator( imageFilePath, core )

ExitApp

#include %A_ScriptDir%\WrapperAbstrctHotkey.ahk