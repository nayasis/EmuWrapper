#NoEnv
#include WrapperAbstrctFunction.ahk

imageDirPath := %0%
imageDirPath := "\\NAS\emul\image\Saturn\Grandia (T-ko)"

option := getOption( imageDirPath )
core   := getCore( option, "mednafen_saturn_libretro" )
filter := getFilter( option, "(cue|chd)" )

modifyConfigDefault( option )
modifyConfigCore( option )

imageFilePath := getRomPath( imageDirPath, option, filter )

runRomEmulator( imageFilePath, core )

ExitApp

#include %A_ScriptDir%\WrapperAbstrctHotkey.ahk