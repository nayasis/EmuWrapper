#NoEnv
#include WrapperAbstrctFunction.ahk

imageDirPath := %0%
imageDirPath := "f:\c64-testimg\Bards Tale 3"

option := getOption( imageDirPath )
core   := getCore( option, "vice_x64_libretro" )
filter := getFilter( option, "vfl$" )

imageFilePath := getRomPath( imageDirPath, option, filter )

runRomEmulator( imageFilePath, core )

ExitApp

#include %A_ScriptDir%\WrapperAbstrctHotkey.ahk