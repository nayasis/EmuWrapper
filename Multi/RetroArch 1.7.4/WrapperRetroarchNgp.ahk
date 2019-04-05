#NoEnv
#include WrapperAbstrctFunction.ahk

imageDirPath := %0%
; imageDirPath := "\\NAS\emul\image\NGP\Pac Man (en)"

option := getOption( imageDirPath )
core   := getCore( option, "mednafen_ngp_libretro" )
filter := getFilter( option, "(zip|ngc|ngp)" )

imageFilePath := getRomPath( imageDirPath, option, filter )

runRomEmulator( imageFilePath, core )

ExitApp

#include %A_ScriptDir%\WrapperAbstrctHotkey.ahk