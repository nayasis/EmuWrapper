#NoEnv
#include WrapperAbstrctFunction.ahk

imageDirPath := %0%
; imageDirPath := "\\NAS\emul\image\SuperFamicom\Excitebike - Bunbun Mario Battle - Stadium 1 (ja)"
; imageDirPath := "\\NAS\emul\image\MSX\Ancient Ys Vanished - Omen (T-ko)"
; imageDirPath := "\\NAS\emul\image\MSX\MSX1 Various\Knightmare Majyo Densetsu (en)"
imageDirPath := "\\NAS\emul\image\MSX\MSX2 Various\Zanac Ex (en)"
; imageDirPath := "\\NAS\emul\image\MSX\MSX2 Various\Ancient Ys Vanished II - The Final Chapter (T-ko)"
; imageDirPath := "\\NAS\emul\image\MSX\MSX2 Various\Ancient Ys Vanished - Omen (T-en)"

option := getOption( imageDirPath )
core   := getCore( option, "bluemsx_libretro" )
; core   := getCore( option, "fmsx_libretro" )
filter := getFilter( option, "zip|7z|rom" )

imageFilePath := getRomPath( imageDirPath, option, filter )

debug( "diskSize : " diskContainer.size() )

runRomEmulator( imageFilePath, core )

ExitApp

#include %A_ScriptDir%\WrapperAbstrctHotkey.ahk