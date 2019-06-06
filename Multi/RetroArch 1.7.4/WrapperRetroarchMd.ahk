#NoEnv
#include WrapperAbstrctFunction.ahk

imageDirPath := %0%

option := getOption( imageDirPath )
core   := getCore( option, "genesis_plus_gx_libretro" )
filter := getFilter( option, "(zip|md|smd|gen|sms|gg)" )

modifyConfigDefault( option )
modifyConfigCore( option )

imageFilePath := getRomPath( imageDirPath, option, filter )

runRomEmulator( imageFilePath, core )

ExitApp

#include %A_ScriptDir%\WrapperAbstrctHotkey.ahk