#NoEnv
#include %A_ScriptDir%\script\AbstractFunction.ahk

imageDir := %0%
; imageDir := "\\NAS\emul\image\DreamCast\King of Fighters 2002 (en)"
; imageDir := "\\NAS\emul\image\Atomiswave\rumblef"
; imageDir := "e:\download\lol\dc_lol_t-eng_v1.1_rr_jc_vga"
; imageDir := "\\NAS\emul\image\Naomi\Guilty Gear XX - Accent Core (en)"

option    := getOption( imageDir )
config    := setConfig( "flycast_libretro", option )
; config    := setConfig( "reicast_libretro", option )
imageFile := getRomPath( imageDir, option, "m3u|chd|gdi|cdi|cue|iso|zip|7z" )

writeConfig( config, imageFile )
runEmulator( imageFile, config )

debug( "wait sub process !" )
waitEmulator( 1 )
waitCloseEmulator()

ExitApp

#include %A_ScriptDir%\script\AbstractHotkey.ahk