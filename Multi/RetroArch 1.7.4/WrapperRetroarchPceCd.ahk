#NoEnv
#include WrapperAbstrctFunction.ahk

imageDirPath := %0%
; imageDirPath := "\\NAS\emul\image\PcEngineCd\Ys 4 - The Dawn of Ys (T-en 1.0)"

option := getOption( imageDirPath )
core   := getCore( option, "mednafen_pce_fast_libretro" )
filter := getFilter( option, "zip|pce" )

imageFilePath := getRomPath( imageDirPath, option, filter )

runRomEmulator( imageFilePath, core, option, "pressStart" )

ExitApp

#include %A_ScriptDir%\WrapperAbstrctHotkey.ahk

pressStart( processId, core, imageFilePath, option ) {
	WinWait, RetroArch Beetle PCE Fast,, 10
	Send {Enter Down}
	Sleep 20
	Send {Enter Up}
}