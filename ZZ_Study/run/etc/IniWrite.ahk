#Requires AutoHotkey >=2.0

fileIni := "아쿠요메! [Gemini 2.5 Pro] by 마싯는 뉴케어, 유동적.ini"

IniWrite(A_ScriptDir, fileIni, "PATH", "current")
value := IniRead(fileIni, "PATH", "current")
debug(value)

ExitApp

debug(message := "") {
  if( A_IsCompiled == 1 )
    return
  message .= "`r`n" 
  FileAppend(message, "*")
}