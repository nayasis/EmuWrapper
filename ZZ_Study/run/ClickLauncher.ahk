#NoEnv

WinWait, ahk_exe JadeEmpireLauncher.exe,, 10
IfWinExist
{
	Click 130, 130, Left
}

ExitApp