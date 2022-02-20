#NoEnv

WinWait, ahk_exe CDS95.exe,, 20
IfWinExist
{
	Send {Enter}
}

ExitApp