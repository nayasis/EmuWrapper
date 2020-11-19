#NoEnv
#include %A_ScriptDir%\script\AbstractFunction.ahk

imageDir := %0%
; imageDir := "\\NAS\emul\image\Saturn\Grandia (T-ko)"
; imageDir := "\\NAS\emul\image\Saturn\Daytona USA (en)"

option := getOption( imageDir )
config := setConfig( "", option )

imageFile := getRomPath( imageDir, option, "chd|cue" )
runEmulator( imageFile, config )

ExitApp

#include %A_ScriptDir%\script\AbstractHotkey.ahk