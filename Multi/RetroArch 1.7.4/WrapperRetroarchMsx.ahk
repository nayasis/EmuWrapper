#NoEnv
#include WrapperAbstrctFunction.ahk

imageDirPath := %0%
imageDirPath := "\\NAS\emul\image\MSX\XZR II (T-ko)"
; imageDirPath := "\\NAS\emul\image\MSX\MSX2 Various\Ball Out (ja)"

option := getOption( imageDirPath )
core   := getCore( option, "bluemsx_libretro" )
; core   := getCore( option, "fmsx_libretro" )
filter := getFilter( option, "zip|7z|rom|dsk" )

modifyConfigDefault( option )
modifyConfigCore( option )

imageFilePath := getRomPath( imageDirPath, option, filter )

runRomEmulator( imageFilePath, core )

ExitApp

#include %A_ScriptDir%\WrapperAbstrctHotkey.ahk