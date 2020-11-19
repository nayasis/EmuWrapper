#NoEnv
#include %A_ScriptDir%\script\AbstractFunction.ahk

imageDir := %0%
; imageDir := "\\NAS\emul\image\SuperFamicom\Fire Emblem 3 - Monshou no Nazo (T-ko)"
; imageDir := "\\NAS\emul\image\SuperFamicom\BS Fire Emblem Akaneia Senki - Episode 3 ~ Seigi no Tozokudan (nintendo)(T-en 1.01 by Darnman)"
; imageDir := "\\NAS\emul\image\SuperFamicom\BS Fire Emblem Akaneia Senki - Episode 1 ~ Palace Kanraku (nintendo)(T-en 1.01 by Darnman)"
; imageDir := "\\NAS\emul\image\SuperFamicom\BS Legend of Zelda 1 - Kodai no Sekiban (J)"

option    := getOption( imageDir )
; config    := setConfig( "mednafen_supafaust_libretro", option )
; config    := setConfig( "bsnes_libretro", option )
config    := setConfig( "snes9x_libretro", option )
imageFile := getRomPath( imageDir, option, "zip|7z|smc|sfc|fig|bs" )

writeConfig( config, imageFile )
runEmulator( imageFile, config )

ExitApp

#include %A_ScriptDir%\script\AbstractHotkey.ahk