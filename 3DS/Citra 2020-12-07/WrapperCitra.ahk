#NoEnv
#include c:\app\emulator\ZZ_Library\Include.ahk

emulatorPid  := ""
imageDir := %0%
;imageDir := "\\NAS2\emul\image\3DS\3D After Burner II (m2)(en)"

prepareFont()

imageFile := FileUtil.getFile(imageDir, "i).*\.(zip|3ds|3dsx|elf|axf|cci|cxi|cia|app)$")

if(imageFile != "") {
	command :=  wrap(A_ScriptDir "\nightly\citra-qt.exe") " " wrap(imageFile)
	debug( command )

	Run, % command,,,emulatorPid
	waitEmulator()	
	IfWinExist
	{
		activateEmulator()		
	  Process, WaitClose, %emulatorPid%
	}

} else {
	Run, % A_ScriptDir "\nightly\citra.exe",,,
}

ExitApp

waitEmulator() {
	WinWait, ahk_exe citra-qt.exe,, 10
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

	trgDir := userHome "\AppData\Roaming\Citra"
	srcDir := FileUtil.getDir(A_LineFile) "\fix"

	if ( FileUtil.exist(trgDir "\sysdata\shared_font.bin") )
	  return

  FileUtil.copyDir( srcDir "\config",  trgDir "\config"  )
	FileUtil.copyDir( srcDir "\nand",    trgDir "\nand"    )
	FileUtil.copyDir( srcDir "\sysdata", trgDir "\sysdata" )
	FileUtil.copyDir( srcDir "\sdmc",    trgDir "\sdmc"    )

}