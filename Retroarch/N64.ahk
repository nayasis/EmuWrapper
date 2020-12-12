#NoEnv
#include %A_ScriptDir%\script\AbstractFunction.ahk

imageDir := %0%
; imageDir := "\\NAS\emul\image\N64\Star Wars Episode I - Battle for Naboo (en)"

option    := getOption( imageDir )
config    := setConfig( "mupen64plus_next_libretro", option )
imageFile := getRomPath( imageDir, option, "zip|7z|z64|v64" )

; config.core := "mupen64plus_next_libretro"
; config.core := "parallel_n64_libretro"

writeConfig( config, imageFile )
runEmulator( imageFile, config )

ExitApp

#include %A_ScriptDir%\script\AbstractHotkey.ahk