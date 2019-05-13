#NoEnv
#include WrapperAbstrctFunction.ahk

imageDirPath := %0%
; imageDirPath := "\\NAS\emul\image\SuperFamicom\Excitebike - Bunbun Mario Battle - Stadium 1 (ja)"
; imageDirPath := "\\NAS\emul\image\MSX\Ancient Ys Vanished - Omen (T-ko)"
; imageDirPath := "\\NAS\emul\image\GameBoy\Baby Felix - Halloween (en)"
imageDirPath := "\\NAS\emul\image\GameBoyAdvance\Arctic Tale (en)"


option := getOption( imageDirPath )
core   := getCore( option, "gambatte_libretro" )
; core   := getCore( option, "mednafen_gba_libretro" )
; core   := getCore( option, "mgba_libretro" )
filter := getFilter( option, "zip|7z" )

imageFilePath := getRomPath( imageDirPath, option, filter )

runRomEmulator( imageFilePath, core )

ExitApp

#include %A_ScriptDir%\WrapperAbstrctHotkey.ahk