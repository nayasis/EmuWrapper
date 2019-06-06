#NoEnv
#include WrapperAbstrctFunction.ahk

imageDirPath := %0%

option := getOption( imageDirPath )
core   := getCore( option, "mgba_libretro" )
; core   := getCore( option, "gambatte_libretro" )
; core   := getCore( option, "mednafen_gba_libretro" )
filter := getFilter( option, "zip|7z" )

modifyConfigDefault( option )
modifyConfigCore( option )

imageFilePath := getRomPath( imageDirPath, option, filter )

runRomEmulator( imageFilePath, core )

ExitApp

#include %A_ScriptDir%\WrapperAbstrctHotkey.ahk