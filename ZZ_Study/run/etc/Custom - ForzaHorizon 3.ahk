#NoEnv

; restartAsAdmin()

requireToInstall := false

command := "powershell -windowstyle hidden get-appxpackage Microsoft.OpusPG* | grep InstallLocation"
output  := cli( command )

StringGetPos, index, output, % ":"

if ( index < 0 ) {
	requireToInstall := true
} else {

	installDir := SubStr( output, index + 2 )
	installDir := Trim( installDir )
	installDir := StrReplace( installDir, "`r`n" )

	currentDir := A_ScriptDir "\bin\AppFiles"

	debug( "installDir : " installDir )
	debug( "currentDir : " currentDir )

	if ( installDir != currentDir ) {
		debug( "need to reinstall" )
		RunWait, % "powershell -windowstyle hidden remove-appxpackage Microsoft.OpusPG.d31b9c6a3c_1.0.119.1002_x64__8wekyb3d8bbwe",,Hide
		requireToInstall := true
	}

}

if ( requireToInstall == true ) {
	debug( "reinstall")
	command    := "powershell -windowstyle hidden add-appxpackage -register AppxManifest.xml"
	workingDir :=  A_ScriptDir "\bin\AppFiles"
	RunWait, % command, % workingDir, Hide
}

command := "explorer.exe shell:appsFolder\Microsoft.OpusPG.d31b9c6a3c_8wekyb3d8bbwe!OpusReleaseFinal"
Run, % command

ExitApp

restartAsAdmin() {
	if not (A_IsAdmin) {
	    try ; leads to having the script re-launching itself as administrator
	    {
	        if A_IsCompiled
	            Run *RunAs "%A_ScriptFullPath%" /restart
	        else
	            Run *RunAs "%A_AhkPath%" /restart "%A_ScriptFullPath%"
	    }
	    ExitApp
	}
}

cli( command ) {
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

debug( message ) {
 if( A_IsCompiled == 1 )
   return
  message .= "`n" 
  FileAppend %message%, * ; send message to stdout
}