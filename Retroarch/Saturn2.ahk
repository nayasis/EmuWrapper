#NoEnv
#include %A_ScriptDir%\script\AbstractFunction.ahk

; global EMUL_ROOT     := A_ScriptDir "\1.9.0"

imageDir := %0%
; imageDir := "\\NAS\emul\image\Saturn\Grandia (T-ko)"
; imageDir := "\\NAS\emul\image\Saturn\Daytona USA (en)"
imageDir := "\\NAS\emul\image\Saturn\Grandia (T-ko)"

option    := getOption( imageDir )
; config    := setConfig( "mednafen_saturn_libretro", option )
; config    := setConfig( "yabause_libretro", option )
; config    := setConfig( "yabasanshiro_libretro", option )
config    := setConfig( "kronos_libretro", option )
; imageFile := getRomPath( imageDir, option, "chd|cue" )
imageFile := getRomPath( imageDir, option, "chd|bin" )

writeConfig( config, imageFile )
runEmulator( imageFile, config )

ExitApp

#include %A_ScriptDir%\script\AbstractHotkey.ahk