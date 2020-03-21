#NoEnv
#include %A_ScriptDir%\script\AbstractFunction.ahk

imageDir := %0%
; imageDir := "\\NAS\emul\image\N64\Star Wars - Rogue Squadron (en)"

option    := getOption( imageDir )
config    := setConfig( "mupen64plus_next_libretro", option )
; config    := setConfig( "mupen64plus_next_gles3_libretro", option )
; config    := setConfig( "parallel_n64_libretro", option )
imageFile := getRomPath( imageDir, option, "zip|7z|z64|v64" )

writeConfig( config, imageFile )
runEmulator( imageFile, config )

ExitApp

#include %A_ScriptDir%\script\AbstractHotkey.ahk