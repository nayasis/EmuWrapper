#NoEnv
#include %A_ScriptDir%\script\AbstractFunction.ahk

imageDirPath := %0%
; imageDirPath := "\\NAS\emul\image\Saturn\Grandia (T-ko)"
; imageDirPath := "\\NAS\emul\image\Saturn\Daytona USA (en)"

option := getOption( imageDirPath )
config := setConfig( "", option )

imageFilePath := getRomPath( imageDirPath, option, "chd|cue" )
runEmulator( imageFilePath, config )

ExitApp

#include %A_ScriptDir%\script\AbstractHotkey.ahk