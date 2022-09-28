#NoEnv
#include %A_ScriptDir%\script\AbstractFunction.ahk

imageDir := %0%
; imageDir := "\\NAS2\emul\image\Famicom\Punisher (en)"
; imageDir := "\\NAS2\emul\image\Famicom\Tenchi wo Kurau 2 - Shokatsu Koumei Den (T-ko)"
; imageDir := "\\NAS2\emul\image\Famicom\Takahashi Meijin no Bouken-jima (hudson)(T-ko)"

option    := getOption( imageDir )
config    := setConfig( "mesen_libretro", option )
imageFile := getRomPath( imageDir, option, "zip|7z|nes" )

; config.core := "mesen_libretro"
; config.core := "nestopia_libretro"
; config.input_overlay := ".\overlays\famicom.cfg"

writeConfig( config, imageFile )
runEmulator( imageFile, config )

ExitApp

#include %A_ScriptDir%\script\AbstractHotkey.ahk