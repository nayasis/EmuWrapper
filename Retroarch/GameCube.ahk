#NoEnv
#include %A_ScriptDir%\script\AbstractFunction.ahk

imageDir := %0%
; imageDir := "\\NAS2\emul\image\GameCube\Super Mario Sunshine (en)"
; imageDir := "\\NAS2\emul\image\GameCube\Tengai Makyou 2 - Manji Maru (ja)"
; imageDir := "\\NAS2\emul\image\Wii\Pikmin 1 for Wii (nintendo)(ko)"

option    := getOption( imageDir )
config    := setConfig( "dolphin_libretro", option )
imageFile := getRomPath( imageDir, option, "m3u|chd|gcz|cue|iso|wad|wbfs" )

; EMUL_ROOT := A_ScriptDir "\1.9.8"
config.video_driver         := "gl"
config.video_driver         := "vulkan"
config.driver_switch_enable := "false"
config.video_shared_context := "true"
config.rewind_enable        := "false"

writeConfig( config, imageFile )
runEmulator( imageFile, config )

ExitApp

#include %A_ScriptDir%\script\AbstractHotkey.ahk