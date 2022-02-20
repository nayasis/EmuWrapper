#NoEnv

EnvGet, userHome, userprofile

dirIni  := userHome "\Documents\OpenRCT2"
fileIni := dirIni "\config.ini"
dirGame := getParentDir(A_ScriptDir) "\bin"
dirGame := RegExReplace(dirGame,"\\","\\")

FileCreateDir, % dirIni

debug(dirGame)

IniWrite, "%dirGame%", % fileIni, general, game_path

ExitApp

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