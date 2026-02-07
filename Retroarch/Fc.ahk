#Requires AutoHotkey >=2.0
#Include %A_ScriptDir%\script\AbstractFunction.ahk

imageDir := A_Args.Length ? A_Args[1] : ""
;imageDir := "\\NAS2\emul\image\Famicom\Dragon Knife (waixing)(T-en 1.0 by pacnsacdave)"

option    := getOption( imageDir )
config    := setConfig( "mesen_libretro", option )
imageFile := getRomPath( imageDir, option, "zip|7z|nes" )

; config.core := "mesen_libretro"
; config.core := "nestopia_libretro"
; config.input_overlay := ".\overlays\famicom.cfg"
; config.aspect_ratio_index := "22"

writeConfig( config, imageFile )
runEmulator( imageFile, config )

ExitApp

#Include %A_ScriptDir%\script\AbstractHotkey.ahk