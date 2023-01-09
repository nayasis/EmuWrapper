#NoEnv
#include %A_ScriptDir%\script\AbstractFunction.ahk

imageDir := %0%
; imageDir := "\\NAS\emul\image\Famicom\Contra (T-en 1.0)"
; imageDir := "\\NAS2\emul\image\PcEngine\Mashin Eiyuuden Wataru (hudson)(T-en 1.0 by Stardust Crusaders)"

option    := getOption( imageDir )
config    := setConfig( "mednafen_supergrafx_libretro", option )
imageFile := getRomPath( imageDir, option, "zip|7z|pce" )

writeConfig( config, imageFile )
runEmulator( imageFile, config )

ExitApp

#include %A_ScriptDir%\script\AbstractHotkey.ahk