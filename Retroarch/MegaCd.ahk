#NoEnv
#include %A_ScriptDir%\script\AbstractFunction.ahk

imageDir := %0%
; imageDir := "\\NAS\emul\image\MegaCd\Popful Mail (en)"

option    := getOption( imageDir )
config    := setConfig( "genesis_plus_gx_libretro", option )
imageFile := getRomPath( imageDir, option, "cue|chd|iso" )

writeConfig( config, imageFile )
runEmulator( imageFile, config )

ExitApp

#include %A_ScriptDir%\script\AbstractHotkey.ahk