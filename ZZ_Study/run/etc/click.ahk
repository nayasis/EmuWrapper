WinWait, ahk_exe cod6cn.exe
IfWinExist
{
	WinActivate
	Send, {Alt down}{R}
	Click, 140, 495
}

ExitApp