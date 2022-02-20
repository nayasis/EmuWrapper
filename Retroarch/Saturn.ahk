#NoEnv
#include %A_ScriptDir%\script\AbstractFunction.ahk

; global EMUL_ROOT := A_ScriptDir "\1.9.7"

imageDir := %0%
; imageDir := "\\NAS2\emul\image\Saturn\Grandia (T-ko)"
; imageDir := "\\NAS2\emul\image\Saturn\Daytona USA (en)"
; imageDir := "\\NAS2\emul\image\Saturn\FIFA Soccer 97 (ea)(en)"

option := getOption( imageDir )

if( option.core.common_core == "yabasanshiro_libretro" ) {
	option.run.videoDriver := "gl"
}

config := setConfig( "mednafen_saturn_libretro", option )

; config.core := "mednafen_saturn_libretro"
; config.core := "kronos_libretro"
; config.core := "yabasanshiro_libretro"
; config.core := "yabause_libretro"

; imageFile := getRomPath( imageDir, option, "chd|cue" )
imageFile := getRomPath( imageDir, option, "m3u|chd|bin" )

writeConfig( config, imageFile )
runEmulator( imageFile, config )

ExitApp

#include %A_ScriptDir%\script\AbstractHotkey.ahk