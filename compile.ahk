#NoEnv
#include %A_ScriptDir%\ZZ_Library\Include.ahk
#SingleInstance Force

global dirCompiler := "c:\Program Files\AutoHotkey\Compiler"
global bin := "Unicode 64-bit.bin"

sources := FileUtil.getFiles(A_ScriptDir "\Retroarch",".*\.ahk",false)
for i,source in sources {
  Progress, % i / sources.MaxIndex() * 100, % "compiling... " FileUtil.getName(source)
  compile(source)
}

ExitApp

compile(src) {
  trg := FileUtil.getDir(src) "\" FileUtil.getName(src,false) ".exe"
  cmd := """" dirCompiler "\Ahk2Exe.exe"" /in """ src """ /out """ trg """ /bin """ dirCompiler "\" bin """ /mpress ""0"""
  debug(cmd)
  RunWait % cmd
}