#Requires AutoHotkey >=2.0
#Include %A_ScriptDir%\script\AbstractFunction.ahk

;global EMUL_ROOT := A_ScriptDir "\1.9.7"

imageDir := A_Args.Length ? A_Args[1] : ""
;imageDir := "\\NAS2\emul\image\Saturn\Madou Monogatari (compile)(T-ko 0.3.0 by mcpads)"

option := getOption(imageDir)

if( option.core == "yabasanshiro_libretro" ) {
	option.run.videoDriver := "gl"
	extension := "chd|bin"
} else {
	extension := "m3u|chd|bin"
}

config := setConfig( "mednafen_saturn_libretro", option )

; config.core := "mednafen_saturn_libretro"
; config.core := "kronos_libretro"
; config.core := "yabasanshiro_libretro"
; config.core := "yabause_libretro"

; imageFile := getRomPath( imageDir, option, "chd|cue" )
imageFile := getRomPath( imageDir, option, extension )

writeConfig( config, imageFile )
runEmulator( imageFile, config )

ExitApp

#Include %A_ScriptDir%\script\AbstractHotkey.ahk