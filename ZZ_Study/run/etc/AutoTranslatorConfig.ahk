#Requires AutoHotkey >=2.0
#Include, d:\app\emulator\ZZ_Library\FileUtil.ahk

root := FileUtil.getParentDir(A_ScriptDir)

fileIni := root "\bin\BepInEx\config\AutoTranslatorConfig.ini"

IniWrite, % root "\bin\notosanscjkjp_bold", % fileIni, Behaviour, OverrideFontTextMeshPro
IniRead, value, % fileIni, Behaviour, OverrideFontTextMeshPro
debug(value)

ExitApp

debug( message="" ) {
  if( A_IsCompiled == 1 )
    return
  message .= "`r`n" 
  FileAppend %message%, *
}