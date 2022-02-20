#NoEnv
#include %A_ScriptDir%\script\AbstractFunction.ahk

imageDir := %0%
; imageDir := "\\NAS2\emul\image\N64\Star Wars - Rogue Squadron (en)"
; imageDir := "\\NAS2\emul\image\N64\Choro Q 64 2 - Hacha Mecha Grand Prix Race (takara)(T-en 1.0 by Zoinkity)"
; imageDir := "\\NAS2\emul\image\N64\Neon Genesis Evangelion (bandai)(T-ko 210831 by hanmaru)"

option    := getOption( imageDir )
config    := setConfig( "mupen64plus_next_libretro", option )
imageFile := getRomPath( imageDir, option, "zip|7z|z64|v64" )

; config.core := "mupen64plus_next_libretro"
; config.core := "parallel_n64_libretro"

config.video_driver := "glcore"
; config.video_driver := "gl"
; config.driver_switch_enable := "false"

writeConfig( config, imageFile )
runEmulator( imageFile, config )

ExitApp

#include %A_ScriptDir%\script\AbstractHotkey.ahk