#Requires AutoHotkey >=2.0
#Include %A_ScriptDir%\..\ZZ_Library\Include.ahk

res := cmdlet("dir e:\download")

debug(res)

ExitApp

debugA(message) {
  message .= "`n"
  FileAppend(message, "*")
}
