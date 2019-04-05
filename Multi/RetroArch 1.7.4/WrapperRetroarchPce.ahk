#NoEnv
#include WrapperAbstrctFunction.ahk

imageDirPath := %0%
; imageDirPath := "\\NAS\emul\image\PcEngine\1941 - Counter Attack (ja)"

option := getOption( imageDirPath )
core   := getCore( option, "mednafen_supergrafx_libretro" )
filter := getFilter( option, "zip|pce" )

imageFilePath := getRomPath( imageDirPath, option, filter )

runRomEmulator( imageFilePath, core )

ExitApp

#include %A_ScriptDir%\WrapperAbstrctHotkey.ahk