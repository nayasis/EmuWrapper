#NoEnv
#include WrapperAbstrctFunction.ahk

imageDirPath := %0%
; imageDirPath := "\\NAS\emul\image\N64\Paper Mario (en)"

option := getOption( imageDirPath )
core   := getCore( option, "mupen64plus_libretro" )
filter := getFilter( option, "zip|z64|v64" )

modifyConfigDefault( option )
modifyConfigCore( option )

imageFilePath := getRomPath( imageDirPath, option, filter )

runRomEmulator( imageFilePath, core )

ExitApp

#include %A_ScriptDir%\WrapperAbstrctHotkey.ahk