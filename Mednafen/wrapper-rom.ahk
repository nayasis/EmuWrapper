#NoEnv
#include %A_ScriptDir%\script\AbstractFunction.ahk

imageDirPath := %0%

option := getOption( imageDirPath )
config := setConfig( "", option )

imageFilePath := getRomPath( imageDirPath, option, "zip|7z|fds|gb" )
runEmulator( imageFilePath, config )

ExitApp

#include %A_ScriptDir%\script\AbstractHotkey.ahk
