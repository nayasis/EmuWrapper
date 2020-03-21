#NoEnv
#include %A_ScriptDir%\script\AbstractFunction.ahk

imageDir := %0%
; imageDir := "\\NAS\emul\image\Saturn\Grandia (T-ko)"
; imageDir := "\\NAS\emul\image\Saturn\Daytona USA (en)"
imageDir := "d:\app\Downloader\TstoryUrlDownloader\temp\Grandia(K) Disc1"

option    := getOption( imageDir )
config    := setConfig( "mednafen_saturn_libretro", option )
; config    := setConfig( "yabause_libretro", option )
imageFile := getRomPath( imageDir, option, "chd|cue" )

writeConfig( config, imageFile )
runEmulator( imageFile, config )

ExitApp

#include %A_ScriptDir%\script\AbstractHotkey.ahk