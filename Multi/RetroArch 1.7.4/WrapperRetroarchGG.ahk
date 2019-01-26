#NoEnv
#include WrapperAbstrctFunction.ahk

imageDirPath := %0%
; imageDirPath := "\\NAS\emul\image\SuperFamicom\Excitebike - Bunbun Mario Battle - Stadium 1 (ja)"
; imageDirPath := "\\NAS\emul\image\GameGear\Moldorian - Hikari to Yami no Sister (Japan)"

option := getOption( imageDirPath )
core   := getCore( option, "genesis_plus_gx_libretro" )
filter := getFilter( option, "zip|7z|gg" )

imageFilePath := getRomPath( imageDirPath, option, filter )

runRomEmulator( imageFilePath, core )

ExitApp

#include %A_ScriptDir%\WrapperAbstrctHotkey.ahk