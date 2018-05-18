EnvGet, userHome, userprofile

scumeExeFile := A_ScriptDir "\scumm\scummvm.exe"
scummIniFile := A_ScriptDir "\scumm\scummvm.ini"
scummHome    := userHome "\AppData\Roaming\ScummVM"


IniWrite, %A_ScriptDir%\bin, %scummIniFile%, freddypharkas-cd, path

FileCopy, %scummIniFile%, %scummHome%, 1

Run, %scumeExeFile%, %A_ScriptDir%\scumm

WinWait, ahk_class SDL_app ahk_exe scummvm.exe,, 5
IfWinExist
{
	Send {Enter}
}

ExitApp

debug( message ) {

 if( A_IsCompiled == 1 )
   return

  message .= "`n" 
  FileAppend %message%, * ; send message to stdout
    
}