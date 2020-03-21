#NoEnv
#include %A_ScriptDir%\script\AbstractFunction.ahk

imageDir := %0%
; imageDir := "\\NAS\emul\image\GameBoy\Dragon Quest I & II (T-ko)"

option    := getOption( imageDir )
config    := setConfig( "gambatte_libretro", option )
; config    := setConfig( "mgba_libretro", option )
; config   := setConfig( "mednafen_gba_libretro", option )
imageFile := getRomPath( imageDir, option, "zip|7z|gba|gbc|gb" )

writeConfig( config, imageFile )
runEmulator( imageFile, config )

ExitApp

#include %A_ScriptDir%\script\AbstractHotkey.ahk