#NoEnv
#include %A_ScriptDir%\script\AbstractFunction.ahk

imageDir := %0%
; imageDir := "\\NAS\emul\image\NDS\Metal Max 3 (crea tech)(T-en 1.0 by Metal Dreamers)"
; imageDir := "\\NAS\emul\image\NDS\Gyakuten Saiban 3 (T-ko)"

option    := getOption( imageDir )
config    := setConfig( "desmume_libretro", option )
; config    := setConfig( "melonds_libretro", option )
imageFile := getRomPath( imageDir, option, "zip|7z|z64|v64" )

writeConfig( config, imageFile )
runEmulator( imageFile, config )

ExitApp

#include %A_ScriptDir%\script\AbstractHotkey.ahk