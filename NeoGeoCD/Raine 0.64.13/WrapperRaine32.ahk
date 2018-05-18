#NoEnv
#include %A_ScriptDir%\..\..\ZZ_Library\Include.ahk

emulatorPid   := ""
imageFilePath := %0%
; imageFilePath := "\\NAS\emul\image\NeoGeo CD\3 Count Bout"

romFile := FileUtil.getFile( imageFilepath, "i).*\.(iso)" )

if( romFile != "" ) {
	RunWait, % "raine32.exe -nogui """ romFile """"
} else {
	Run, neoraine32.exe
}

ExitApp