#Requires AutoHotkey >=2.0
#Include %A_ScriptDir%\script\AbstractFunction.ahk

imageDir := A_Args.Length ? A_Args[1] : ""
;imageDir := "\\NAS2\emul\image\Wii\Ikenie no Yoru (square enix)(T-en 1.03 by Newman)"

option    := getOption(imageDir)
config    := setConfig("dolphin_libretro", option)
imageFile := getRomPath(imageDir, option, "m3u|chd|gcz|cue|iso|wad|wbfs|rvz")

; EMUL_ROOT := A_ScriptDir "\1.9.8"
;config.video_driver         := "gl"
;config.video_driver         := "vulkan"
;config.driver_switch_enable := "false"
;config.video_shared_context := "true"
;config.rewind_enable        := "false"

writeConfig(config, imageFile)
runEmulator(imageFile, config)

ExitApp

#Include %A_ScriptDir%\script\AbstractHotkey.ahk