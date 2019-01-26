#NoEnv

DetectHiddenWindows, ON
Gui0 := WinExist( A_ScriptFullPath " ahk_class AutoHotkey" )
Gui +LastFound
Gui1 := WinExist()
Gui 2:+LastFound
Gui2 := WinExist()

Gui, Add, Text, w200, % "Hidden`t: " Gui0
Gui, Add, Text, w200, % "GUI #1`t: " Gui1
Gui, Add, Text, w200, % "GUI #2`t: " Gui2
Gui, Add, Text, w200, % "PID`t: " DllCall("GetCurrentProcessId")
Gui, 2:Show, w480 h300, Gui 2
Gui, 1:Show, w240 h240, Gui 1
Return

GuiEscape:
 ExitApp