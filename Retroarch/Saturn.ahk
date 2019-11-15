#NoEnv
#include %A_ScriptDir%\script\AbstractFunction.ahk

imageDirPath := %0%
; imageDirPath := "\\NAS\emul\image\Saturn\Grandia (T-ko)"

option := getOption( imageDirPath )
config := setConfig( "mednafen_saturn_libretro", option )

imageFilePath := getRomPath( imageDirPath, option, "chd|cue" )
runEmulator( imageFilePath, config )

ExitApp

#include %A_ScriptDir%\script\AbstractHotkey.ahk