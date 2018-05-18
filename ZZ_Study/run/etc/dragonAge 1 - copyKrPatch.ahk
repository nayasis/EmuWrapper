EnvGet, userHome, userprofile

targetPath := userHome "\Documents\BioWare\Dragon Age"
sourcePath := RegExReplace( A_ScriptDir, "(^.+\\).+", "$1" ) "bin\Dragon Age"

IfExist, % targetPath
{
	runCommand( "/c rmdir """ targetPath """" )
}

runCommand( "/c mklink /d """ targetPath """ """ sourcePath """" )

ExitApp


debug( message ) {

 if( A_IsCompiled == 1 )
   return

  message .= "`n" 
  FileAppend %message%, * ; send message to stdout
    
}

runCommand( command ) {

	dhw := A_DetectHiddenWindows

	DetectHiddenWindows On
	Run "%ComSpec%" /k,, Hide, pid
	while !( hConsole := WinExist("ahk_pid" pid) )
  		Sleep 10

	DllCall("AttachConsole", "UInt", pid)
	DetectHiddenWindows %dhw%

	objShell := ComObjCreate( "WScript.Shell" )
	objExec  := objShell.Exec( comspec " " command )
	While ! objExec.Status
		Sleep 100
	
	result :=  objExec.StdOut.ReadAll()

	DllCall("FreeConsole")
	Process Exist, %pid%
	if ( ErrorLevel == pid )
		Process Close, %pid%		

	return result
}