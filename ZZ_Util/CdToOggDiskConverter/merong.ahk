#NoEnv
#include %A_ScriptDir%\..\..\ZZ_Library\Include.ahk

IfWinExist, ahk_exe ImgBurn.exe, ISO is not an appropriate container format for the current disc but today is your lucky day and I will make the necessary adjustments (convert MODE2/FORM1 to MODE1) if you want me to?
{
	WinActivate
	Send {Enter}
}

ExitApp