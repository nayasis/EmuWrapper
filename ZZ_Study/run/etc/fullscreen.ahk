#NoEnv

WinWait, ahk_exe ActraiserR.exe
IfWinExist
{
	WinSet, Style, -0xC40000, ahk_exe ActraiserR.exe
}

WinWaitNotActive, ahk_exe ActraiserR.exe
{
	WinSet, Style, -0xC40000, ahk_exe ActraiserR.exe
}
