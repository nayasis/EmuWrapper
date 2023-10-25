#NoEnv
#include %A_ScriptDir%\script\AbstractFunction.ahk

imageDir := %0%
;imageDir := "\\NAS2\emul\image\DreamCast\Under Defeat (g.rev)(T-en 1.0 by TapamN)"

option    := getOption( imageDir )
config    := setConfig( "flycast_libretro", option, true )
; config    := setConfig( "reicast_libretro", option )
imageFile := getRomPath( imageDir, option, "m3u|chd|gdi|cdi|cue|iso|zip|7z" )

writeConfig( config, imageFile )
runEmulator( imageFile, config )

debug( "wait sub process !" )
waitEmulator(1)
waitCloseEmulator()

; Sleep, 1

ExitApp

#include %A_ScriptDir%\script\AbstractHotkey.ahk