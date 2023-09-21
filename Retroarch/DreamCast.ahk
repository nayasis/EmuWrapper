#NoEnv
#include %A_ScriptDir%\script\AbstractFunction.ahk

imageDir := %0%
; imageDir := "\\NAS2\emul\image\DreamCast\Sakura Taisen - Hanagumi Taisen Columns 2 (tenky)(T-en 1.0 by ateam)"
; imageDir := "\\NAS\emul\image\DreamCast\King of Fighters 2002 (en)"
; imageDir := "\\NAS\emul\image\Atomiswave\rumblef"
; imageDir := "e:\download\lol\dc_lol_t-eng_v1.1_rr_jc_vga"
imageDir := "\\NAS2\emul\image\DreamCast\Nakoruru - The Gift She Gave Me (kool kizz)(T-en 1.0)"

option    := getOption( imageDir )
config    := setConfig( "flycast_libretro", option, true )
; config    := setConfig( "reicast_libretro", option )
imageFile := getRomPath( imageDir, option, "m3u|chd|gdi|cdi|cue|iso|zip|7z" )

writeConfig( config, imageFile )
runEmulator( imageFile, config )

debug( "wait sub process !" )
waitEmulator( 1 )
waitCloseEmulator()

; Sleep, 1

ExitApp

#include %A_ScriptDir%\script\AbstractHotkey.ahk