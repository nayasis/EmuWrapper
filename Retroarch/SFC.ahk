#NoEnv
#include %A_ScriptDir%\script\AbstractFunction.ahk

; EMUL_ROOT := A_ScriptDir "\1.9.0"

imageDir := %0%
; imageDir := "\\NAS\emul\image\SuperFamicom\Fire Emblem 3 - Monshou no Nazo (T-ko)"
; imageDir := "\\NAS\emul\image\SuperFamicom\BS Fire Emblem Akaneia Senki - Episode 3 ~ Seigi no Tozokudan (nintendo)(T-en 1.01 by Darnman)"
; imageDir := "\\NAS\emul\image\SuperFamicom\BS Fire Emblem Akaneia Senki - Episode 1 ~ Palace Kanraku (nintendo)(T-en 1.01 by Darnman)"
;imageDir := "\\NAS2\emul\image\SuperFamicom\Assault Suits Valken (T-ko)"
;imageDir := "\\NAS2\emul\image\SuperFamicom\Hamelin no Violin (T-ko)"

option    := getOption( imageDir )
config    := setConfig( "snes9x_libretro", option )
imageFile := getRomPath( imageDir, option, "zip|7z|smc|sfc|fig|bs" )

; config.core := "mednafen_supafaust_libretro"
; config.core := "bsnes_libretro"

writeConfig( config, imageFile )
runEmulator( imageFile, config )

ExitApp

#include %A_ScriptDir%\script\AbstractHotkey.ahk