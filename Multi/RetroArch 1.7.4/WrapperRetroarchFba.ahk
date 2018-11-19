#NoEnv
#include WrapperAbstrctFunction.ahk

imageDirPath := %0%
; imageDirPath := "\\NAS\emul\image\SuperFamicom\Excitebike - Bunbun Mario Battle - Stadium 1 (ja)"
; imageDirPath := "\\NAS\emul\image\SuperFamicom\Far East Of Eden Zero (T-en 30 by Tom)"

option := getOption( imageDirPath )
core   := getCore( option, "fbalpha_libretro" )
filter := getFilter( option, "zip|7z" )

imageFilePath := getRomPath( imageDirPath, option, filter )

runRomEmulator( imageFilePath, core )

ExitApp

#include %A_ScriptDir%\WrapperAbstrctHotkey.ahk