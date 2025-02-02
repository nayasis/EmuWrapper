#NoEnv
#include %A_ScriptDir%\script\AbstractFunction.ahk

imageDir := %0%
;imageDir := "\\NAS2\emul\image\PcFx\Der Langrisser FX (ja)"

option    := getOption( imageDir )
config    := setConfig( "mednafen_pcfx_libretro", option )
imageFile := getRomPath( imageDir, option, "chd|cue" )

writeConfig( config, imageFile )
runEmulator( imageFile, config )

ExitApp

#include %A_ScriptDir%\script\AbstractHotkey.ahk