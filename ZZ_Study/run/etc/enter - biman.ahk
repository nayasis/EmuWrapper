WinWait, ahk_exe biman2.exe ahk_class TBltModeForm
IfWinExist
{
	WinActivate
	Send, {Enter}
}

ExitApp