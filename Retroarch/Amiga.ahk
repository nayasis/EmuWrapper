#NoEnv
#include %A_ScriptDir%\script\AbstractFunction.ahk

imageDir := %0%
; imageDir := "\\NAS2\emul\image\Amiga\Strip Poker 2"
; imageDir := "\\NAS2\emul\image\amiga\Commando (en)"

option    := getOption( imageDir )
config    := setConfig( "puae_libretro", option )
imageFile := getRomPath( imageDir, option, "m3u|zip|adf|adz|hdf|hdz" )

writeConfig( config, imageFile )
runEmulator( imageFile, config )

ExitApp

#include %A_ScriptDir%\script\AbstractHotkey.ahk