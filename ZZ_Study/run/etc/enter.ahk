WinWait, ahk_exe gta_sa.exe
IfWinExist
{
	WinActivate
	Send, {Enter}
}

ExitApp