#NoEnv
DetectHiddenWindows, On

RunWait, % A_ScriptDir "\bin\Monkeys.exe"

WinWait, ahk_exe Monkeys.exe,, 10
IfWinExist
{
  debug("found!")
	WinWaitClose, ahk_exe Monkeys.exe
}

ExitApp

debug( message="" ) {
  if( A_IsCompiled == 1 )
    return
  message .= "`r`n" 
  FileAppend %message%, *
}
