#NoEnv
#include %A_ScriptDir%\script\AbstractFunction.ahk

imageDir := %0%
; imageDir := "e:\download\Dai Gyakuten Saiban 1"
imageDir := "\\NAS2\emul\image\3DS\Persona Q2 - New Cinema Labyrinth (atlus)(T-ko 1.04 by K)"

option    := getOption( imageDir )
config    := setConfig( "citra_libretro", option )
imageFile := getRomPath( imageDir, option, "3ds|3dsx|elf|axf|cci|cxi|cia|app" )

config.video_driver := "glcore"
config.driver_switch_enable := "false"
config.input_auto_mouse_grab := "true"
; config.video_shader := "none"

writeConfig( config, imageFile )
runEmulator( imageFile, config )

ExitApp

#include %A_ScriptDir%\script\AbstractHotkey.ahk