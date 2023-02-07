#NoEnv

restartAsAdmin()

makeSaveDir()
writeDxwndIni()
pid_dxwnd := runDxwnd()
clickDxWnd()
waitProcessClose(pid_dxwnd)

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

writeDxwndIni() {
	exeDir  := A_ScriptDir "\bin"
	exe     := exeDir "\ED4.exe"
	fileIni := exeDir "\_dxwnd\dxwnd.ini"
	IniWrite, % exeDir, % fileIni, window, exepath
	IniWrite, % exeDir "\ED4.exe", % fileIni, target, path0
}

runDxwnd() {
	Run, % A_ScriptDir "\bin\_dxwnd\dxwnd_wait.exe",,, pid
	return pid
}

makeSaveDir() {
	EnvGet, userHome, userprofile
	targetDir  := userHome "\AppData\Roaming\FALCOM\ED4\SAVEDATA"
	IfNotExist, % targetDir
		FileCreateDir, % targetDir
}

clickDxWnd() {
	WinWait, ahk_exe dxwnd.exe
	IfWinExist
	{
		WinActivate
		Send, {Down}
		sleep, 100
		Send, {Enter}
	}
}

waitProcessClose(pid_dxwnd) {
	WinWait, ahk_exe ED4.exe
	WinWaitClose, ahk_exe ED4.exe
	sleep,1000
	WinClose, ahk_exe dxwnd.exe
	Process, Close, % pid_dxwnd
}

debug( message ) {
 if( A_IsCompiled == 1 )
   return
  message .= "`n"
  FileAppend %message%, * ; send message to stdout
}