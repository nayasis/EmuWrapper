#NoEnv
#include \\NAS\emul\emulator\ZZ_Library\Include.ahk

emulatorPid  := ""
imageDirPath := %0%
; imageDirPath := "\\NAS\emul\image\3DS\Mario Kart 7 (en)"

prepareFont()

imageFilePath := FileUtil.getFile( imageDirPath, "i).*\.(zip|3ds)$")

if ( imageFilePath != "" ) {

	command := "citra-qt.exe """ imageFilePath """"
	debug( command )

	Run, % command,,,emulatorPid
	waitEmulator()	
	IfWinExist
	{
		activateEmulator()		
	  Process, WaitClose, %emulatorPid%
	}

} else {
	Run, % "citra-qt.exe",,,
}

ExitApp

waitEmulator() {
	WinWait, ahk_class Qt5QWindowIcon ahk_exe citra-qt.exe,, 10
	IfWinExist
	  activateEmulator()
}

activateEmulator() {
	WinActivate, ahk_class Qt5QWindowIcon ahk_exe citra-qt.exe,, 10
}

^+Del:: ; Reset
	activateEmulator()
	Send !e{Alt up}{Down}{Down}{Down}{Enter}
	return

^+Insert:: ; Toggle Speed
	Tray.showMessage( "Not supported in CITRA yet" )
	return

!Enter:: ;Toggle FullScreen
	activateEmulator()
	Send {f11}
	return


prepareFont() {

	EnvGet, userHome, userprofile

	debug( "userHome : " userHome )

	trgDir := userHome "\AppData\Roaming\Citra"
	srcDir := FileUtil.getDir(A_LineFile) "\fix"

	if ( FileUtil.exist(trgDir "\sysdata\shared_font.bin") )
	  return

  FileUtil.copyDir( srcDir "\config",  trgDir "\config"  )
	FileUtil.copyDir( srcDir "\nand",    trgDir "\nand"    )
	FileUtil.copyDir( srcDir "\sysdata", trgDir "\sysdata" )
	FileUtil.copyDir( srcDir "\sdmc",    trgDir "\sdmc"    )

}