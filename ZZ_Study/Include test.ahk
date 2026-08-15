#Requires AutoHotkey >=2.0
#Include %A_ScriptDir%\..\ZZ_Library\Common.ahk
#Include %A_ScriptDir%\..\ZZ_Library\FileUtil.ahk

files := FileUtil.findFiles("c:\Program Files\AutoHotkey\Compiler")
MsgBox("File count : " files.Length)

ExitApp