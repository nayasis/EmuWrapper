#NoEnv
#include %A_ScriptDir%\script\AbstractFunction.ahk

imageDir := %0%
; imageDir := "e:\download\Dai Gyakuten Saiban 1"
imageDir := "\\NAS\emul\image\3DS\Animal Crossing - New Leaf (ko)"

option    := getOption( imageDir )
config    := setConfig( "citra_libretro", option )
imageFile := getRomPath( imageDir, option, "3ds|3dsx|elf|axf|cci|cxi|cia|app" )

; config.core := "citra_canary_libretro"

config.video_driver := "gl"
config.video_shader := "none"

writeConfig( config, imageFile )
runEmulator( imageFile, config )

ExitApp

#include %A_ScriptDir%\script\AbstractHotkey.ahk