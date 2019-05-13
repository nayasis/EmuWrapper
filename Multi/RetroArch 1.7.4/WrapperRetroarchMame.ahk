#NoEnv
#include WrapperAbstrctFunction.ahk

imageDirPath := %0%
; imageDirPath := "\\NAS\emul\image\SuperFamicom\Excitebike - Bunbun Mario Battle - Stadium 1 (ja)"
imageDirPath := "\\NAS\emul\image\ArcadeMame\Super Shanghai Dragon's Eye (en)"

option := getOption( imageDirPath )
core   := getCore( option, "mame_libretro" )
filter := getFilter( option, "zip|7z" )

imageFilePath := getRomPath( imageDirPath, option, filter )

runRomEmulator( imageFilePath, core, option, "waitSubModule" )

ExitApp

#include %A_ScriptDir%\WrapperAbstrctHotkey.ahk

waitSubModule( processId, core, imageFilePath, option ) {
	debug( "in core : " core )
	WinWait, RetroArch MAME,, 60
	WinActivate, RetroArch MAME,, 60
	WinWaitClose, RetroArch MAME
}

; RetroArch MAME