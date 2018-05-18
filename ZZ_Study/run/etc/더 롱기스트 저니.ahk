RunWait, %A_ScriptDir%\bin\game.exe, %A_ScriptDir%\bin,,emulatorPid

ExitApp

!F4:: ;Exit
	Process, Close, %emulatorPid%
	return