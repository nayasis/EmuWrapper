#Requires AutoHotkey >=2.0

WinWait, ahk_exe CDS95.exe,, 20
IfWinExist
{
	Send {Enter}
}

ExitApp