#NoEnv
#include %A_ScriptDir%\script\AbstractFunction.ahk

imageDir := %0%
; imageDir := "\\NAS\emul\image\Wii\temp"
; imageDir := "\\NAS\emul\image\Wii\translated\Captain Rainbow (T-en)"

option    := getOption( imageDir )
config    := setConfig( "dolphin_libretro", option )
imageFile := getRomPath( imageDir, option, "m3u|chd|gcz|cue|iso|wad|wbfs" )

writeConfig( config, imageFile )
runEmulator( imageFile, config )

ExitApp

#include %A_ScriptDir%\script\AbstractHotkey.ahk