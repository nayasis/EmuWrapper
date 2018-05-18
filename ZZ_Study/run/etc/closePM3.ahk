WinWait, ahk_class #32770 ahk_exe PM3WIN.EXE
IfWinExist
{
	WinActivate
	Sleep, 1000
	Send {Enter}
	Sleep, 1000
	Send {Enter}
}

ExitApp