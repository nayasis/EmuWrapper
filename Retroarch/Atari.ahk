#NoEnv
#include %A_ScriptDir%\script\AbstractFunction.ahk

imageDir := %0%
; imageDir := "\\NAS2\emul\image\Atari7800\Winter Games (atari)(en)"

option    := getOption( imageDir )
config    := setConfig( "prosystem_libretro", option )
imageFile := getRomPath( imageDir, option, "zip|7z|bin|a52|a78" )

; config.core := "prosystem_libretro"

writeConfig( config, imageFile )
runEmulator( imageFile, config )

ExitApp

#include %A_ScriptDir%\script\AbstractHotkey.ahk