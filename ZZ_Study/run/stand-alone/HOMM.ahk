#NoEnv

global pid

writeWogcnConfig()

Run, % A_ScriptDir "\bin\start.exe", % A_ScriptDir "\bin",,

WinWait, ahk_exe start.exe,,10
IfWinExist
{
  WinActivate, ahk_exe start.exe
  Send {TAB}
  Send {Enter}

  WinWait, ahk_exe Heroes3HD.exe,,10
  IfWinExist
  {
    WinGet, pid, PID, ahk_exe Heroes3HD.exe
    debug( "process id : " pid )
    WinWaitClose, ahk_exe Heroes3HD.exe,,
  }
}

ExitApp

!F4::
  Process, Close, % pid
  return

writeWogcnConfig() {
  fileGame := A_ScriptDir "\bin\Heroes3HD.exe" 
  fileIni  := A_ScriptDir "\bin\WogcnConfig.ini"
  IniWrite, % fileGame, % fileIni, Path, H3FileName
}

getParentDir( path ) {
  path := RegExReplace( path, "^(.*?)\\$", "$1" )
  path := RegExReplace( path, "^(.*)\\.+?$", "$1" )
  return path
}

debug( message ) {
 if( A_IsCompiled == 1 )
   return
  message .= "`n" 
  FileAppend %message%, * ; send message to stdout
}