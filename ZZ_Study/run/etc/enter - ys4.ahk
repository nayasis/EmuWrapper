WinWait, ahk_exe YscLauncher.exe
IfWinExist
{
	WinActivate, Ys: Memories of Celceta
	Send {Tab}
	Send {Shift Down}{Tab}{Shift Up}
	Sleep, 200
	Send {Enter}
}

ExitApp