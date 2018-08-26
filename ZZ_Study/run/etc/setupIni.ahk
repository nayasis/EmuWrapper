#NoEnv

fileIni := A_ScriptDir "\bin\baldur.ini"

IniDelete, % fileIni, Alias

IniWrite, % A_ScriptDir "\bin",      % fileIni, Alias, HD0
IniWrite, % A_ScriptDir "\bin\data", % fileIni, Alias, CD1
IniWrite, % A_ScriptDir "\bin\data", % fileIni, Alias, CD2
IniWrite, % A_ScriptDir "\bin\data", % fileIni, Alias, CD3
IniWrite, % A_ScriptDir "\bin\data", % fileIni, Alias, CD4
IniWrite, % A_ScriptDir "\bin\data", % fileIni, Alias, CD5
IniWrite, % A_ScriptDir "\bin\data", % fileIni, Alias, CD6

ExitApp


debug( message ) {

 if( A_IsCompiled == 1 )
   return

  message .= "`n" 
  FileAppend %message%, * ; send message to stdout
    
}