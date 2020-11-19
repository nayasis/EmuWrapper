#NoEnv

DetectHiddenWindows, On

root      := A_ScriptDir "\bin"
app       := root "\minecraft_server.exe"
wingame   := "ahk_exe Dungeons-Win64-Shipping.exe"
winserver := "ahk_exe minecraft_server.exe"

unblock( app )

Run, % app, % root, hide

WinWait, % wingame,,20
IfWinExist
{
	debug( "detect window !!")
	WinWaitClose
	debug( "close main window !")
}

IfWinExist, % winserver
{
	debug( "detect server window!" )
	WinClose, % winserver
}

ExitApp

unblock( path ) {
	command := "powershell unblock-file ""-path \""" path "\"""""
 	debug( command )
 	RunWait, % command,,Hide	
}

debug( message ) {
 if( A_IsCompiled == 1 )
   return
  message .= "`n" 
  FileAppend %message%, * ; send message to stdout
}