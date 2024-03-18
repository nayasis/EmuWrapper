#NoEnv
#Include c:\app\emulator\ZZ_Library\Common.ahk
#Include c:\app\emulator\ZZ_Library\FileUtil.ahk

files := FileUtil.getFiles("c:\Program Files\AutoHotkey\Compiler")
MsgBox % "File count : " files.MaxIndex()

ExitApp