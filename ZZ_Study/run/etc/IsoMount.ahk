#NoEnv

pathIso := A_ScriptDir "\iso\d7.iso"

mount( pathIso )

RunWait, % A_ScriptDir "\bin\ds7english.exe"

dismount( pathIso )

ExitApp

mount( pathIso ) {
	RunWait, % "powershell -windowstyle hidden Mount-DiskImage -ImagePath '" pathIso "'",,Hide
}

dismount( pathIso ) {
	RunWait, % "powershell -windowstyle hidden DisMount-DiskImage -ImagePath '" pathIso "'",,Hide
}


debug( message ) {
 if( A_IsCompiled == 1 )
   return
  message .= "`n" 
  FileAppend %message%, * ; send message to stdout
}

cli( command ) {
	debug( command )
	DetectHiddenWindows,On
	Run, %ComSpec% /k,,Hide UseErrorLevel, pid
	if not ErrorLevel
	{
		while ! WinExist("ahk_pid" pid)
		Sleep,100
		DllCall( "AttachConsole","UInt",pid )
	}
	shell := ComObjCreate("WScript.Shell")
	return shell.Exec( command ).StdOut.readAll()
}