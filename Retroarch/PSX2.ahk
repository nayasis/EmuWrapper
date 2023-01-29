#NoEnv
#include %A_ScriptDir%\script\AbstractFunction.ahk

; EMUL_ROOT := A_ScriptDir "\1.8.4"

imageDir := %0%
; imageDir := "\\NAS2\emul\image\PlayStation\Silent Hill (T-ko)"
; imageDir := "\\NAS2\emul\image\PSX2\God of War 1 (sce)(ko)"
; imageDir := "\\NAS2\emul\image\PSX2\Wizardry - Tale of the Forsaken Land (atlus)(en)"
; imageDir := "\\NAS2\emul\image\PSX2\Jak 2 (sce,naughty dog)(ko,en)"
; imageDir := "\\NAS2\emul\image\PSX2\Super Robot Taisen MX (banpresto)(T-ko)"

option := getOption( imageDir )
config := setConfig( "pcsx2_libretro", option, true )
imageFile := getRomPath( imageDir, option, "m3u|cso|bin|iso|chd" )

; config.core := "pcsx2_libretro"

config.driver_switch_enable := "true"
; config.video_driver := "glcore"

writeConfig( config, imageFile )
runEmulator( imageFile, config )

ExitApp

#include %A_ScriptDir%\script\AbstractHotkey.ahk