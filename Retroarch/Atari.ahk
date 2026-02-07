#Requires AutoHotkey >=2.0
#Include %A_ScriptDir%\script\AbstractFunction.ahk

imageDir := A_Args.Length ? A_Args[1] : ""
; imageDir := "\\NAS2\emul\image\Atari7800\Winter Games (atari)(en)"

option    := getOption( imageDir )
config    := setConfig( "prosystem_libretro", option )
imageFile := getRomPath( imageDir, option, "zip|7z|bin|a52|a78" )

; config.core := "prosystem_libretro"

writeConfig( config, imageFile )
runEmulator( imageFile, config )

ExitApp

#Include %A_ScriptDir%\script\AbstractHotkey.ahk