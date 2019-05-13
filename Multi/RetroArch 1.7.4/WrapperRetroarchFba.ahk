#NoEnv
#include WrapperAbstrctFunction.ahk

imageDirPath := %0%
; imageDirPath := "f:\pacman\"
; imageDirPath := "\\NAS\emul\image\Neogeo\The King of Fighters 2001 (en)"


option := getOption( imageDirPath )
core   := getCore( option, "fbalpha_libretro" )
filter := getFilter( option, "zip|7z" )

imageFilePath := getRomPath( imageDirPath, option, filter )

runRomEmulator( imageFilePath, core )

ExitApp

#include %A_ScriptDir%\WrapperAbstrctHotkey.ahk