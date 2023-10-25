#NoEnv

path := A_ScriptDir "\ezTransXP"

IniWrite, % path, Config.ini, ezTrans, InstallationPath
IniRead, value, Config.ini, ezTrans, InstallationPath
debug(value)

ExitApp

debug( message="" ) {
  if( A_IsCompiled == 1 )
    return
  message .= "`r`n" 
  FileAppend %message%, *
}