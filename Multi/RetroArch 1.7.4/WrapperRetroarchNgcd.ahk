#NoEnv
#include WrapperAbstrctFunction.ahk

imageDirPath := %0%
imageDirPath := "\\NAS\emul\image\NeoGeo CD\Samurai Shodown 4 (en)"

option := getOption( imageDirPath )
core   := getCore( option, "mess2014_libretro" )
filter := getFilter( option, "(zip)" )

modifyConfigDefault( option )
modifyConfigCore( option )

imageFilePath := getRomPath( imageDirPath, option, filter )

; runRomEmulator( imageFilePath, core, "--subsystem neocd" )
runRomEmulator( imageFilePath, core )

ExitApp

#include %A_ScriptDir%\WrapperAbstrctHotkey.ahk

