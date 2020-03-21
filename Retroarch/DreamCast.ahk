#NoEnv
#include %A_ScriptDir%\script\AbstractFunction.ahk

imageDir := %0%
; imageDir := "\\NAS\emul\image\DreamCast\King of Fighters 2002 (en)"
; imageDir := "\\NAS\emul\image\Atomiswave\rumblef"
; imageDir := "e:\download\lol\dc_lol_t-eng_v1.1_rr_jc_vga"
; imageDir := "e:\download\lol\Dreamcast_Lazyboot_3.3_oketado\gdi_image"

option    := getOption( imageDir )
config    := setConfig( "flycast_libretro", option )
; config    := setConfig( "reicast_libretro", option )
imageFile := getRomPath( imageDir, option, "m3u|chd|gdi|cdi|cue|iso|zip|7z" )

writeConfig( config, imageFile )
runEmulator( imageFile, config )

ExitApp

#include %A_ScriptDir%\script\AbstractHotkey.ahk