#NoEnv
#include WrapperAbstrctFunction.ahk

imageDirPath := %0%
imageDirPath := "f:\c64-testimg\Bards Tale 3"

option := getOption( imageDirPath )
core   := getCore( option, "vice_x64_libretro" )
filter := getFilter( option, "vfl$" )

imageFilePath := getRomPath( imageDirPath, option, filter )

runRomEmulator( imageFilePath, core )

	; if ( imageFilePath != "" ) {

	; 	command := "retroarch.exe -L ./cores/" core ".dll """ imageDirPath "\game.cmd"""
	; 	debug( command )

	; 	Run, % command,,Hide,emulatorPid
	; 	waitEmulator()
	; 	IfWinExist
	; 	{
	; 		activateEmulator()		
	; 	  Process, WaitClose, %emulatorPid%
	; 	}

	; } else {
	; 	Run, % "retroarch.exe",,Hide,
	; }

ExitApp

#include %A_ScriptDir%\WrapperAbstrctHotkey.ahk