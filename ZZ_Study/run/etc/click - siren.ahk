; WinWait, ahk_exe ShirenTheWanderer5plusLauncher.exe
; WinWait, Shiren The Wanderer
WinWait, ahk_class TVPMainWindow
{
	WinActivate
	Click, 70, 70
}

ExitApp