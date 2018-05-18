WinWait, ahk_exe trine3_launcher.exe
IfWinExist
{
	WinActivate
	;ControlGetText, var, Edit9
	ControlFocus, Edit9
	Sleep, 10
	ControlFocus, Edit9
	Sleep, 10
	Send {Down}
	Send {Down}

	ControlFocus, Button3
	Send {Enter}	

}

ExitApp
