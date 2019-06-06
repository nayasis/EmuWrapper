#NoEnv
#include WrapperAbstrctFunction.ahk

imageDirPath := %0%
imageDirPath := "f:\c64\"

option := getOption( imageDirPath )
core   := getCore( option, "vice_x64_libretro" )
filter := getFilter( option, "(zip|prg)" )

modifyConfigDefault( option )
modifyConfigCore( option )

imageFilePath := getRomPath( imageDirPath, option, filter )

runRomEmulator( imageFilePath, core )

ExitApp

#include %A_ScriptDir%\WrapperAbstrctHotkey.ahk