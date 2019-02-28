#NoEnv
; #include %A_ScriptDir%\..\..\ZZ_Library\Include.ahk
#include \\NAS\emul\emulator\ZZ_Library\Include.ahk

imageDirPath := %0%
; imageDirPath := "\\NAS\emul\image\DreamCast\Shenmue (en)"

initEmulator()

diskContainer := new DiskContainer( imageDirPath, "i).*\.(chd|gdi|cdi)$" )

if ( diskContainer.hasDisk() ) {

	diskContainer.initSlot(1)

	command := "demul.exe -run=dc -image=""" diskContainer.getFileInSlot(1) """"
	debug( command )

	Run, % command,,,emulPid
	Sleep, 5000
	waitEmulator()
	IfWinExist
	{
		activateEmulator()
	  Process, WaitClose, % emulPid
	}

} else {
	Run, % "demul.exe",,Hide,
}

debug( "end" )

ExitApp

waitEmulator() {
	WinWait, ahk_exe demul.exe,, 10
	IfWinExist
	  activateEmulator()
}

activateEmulator() {
	WinActivate, ahk_exe demul.exe,, 10
}

getOption( imageDirPath ) {
	dirConf := imageDirPath "\_EL_CONFIG"
	IfExist %dirConf%\option\option.json
	{
		FileRead, jsonText, %dirConf%\option\option.json
		option := JSON.load( jsonText )
	} else {
		option := {}
	}
	return option
}

getGameMeta( imageDirPath ) {
	dirConf := imageDirPath "\_EL_CONFIG"
	IfExist %dirConf%\option\gameMeta.json
	{
		FileRead, jsonText, %dirConf%\option\gameMeta.json
		return JSON.load( jsonText )
	}
	return {}
}

initEmulator() {
	fileIni := "Demul.ini"
	IniWrite, % A_ScriptDir "\memsaves\vms00.bin", % fileIni, VMS, VMSA0
	IniWrite, % A_ScriptDir "\memsaves\vms10.bin", % fileIni, VMS, VMSB0
	IniWrite, % A_ScriptDir "\plugins\", % fileIni, plugins, directory
	IniWrite, % A_ScriptDir "\nvram\", % fileIni, files, nvram
	IniWrite, % A_ScriptDir "\roms\", % fileIni, files, roms0
}

^+Del:: ; Reset
	activateEmulator()
	return

^+Insert:: ; Toggle Speed
	Tray.showMessage( "Toggle speed" )
	activateEmulator()
	return

; Change Next CD-ROM
^+PGUP::
	if ( diskContainer.hasMultiDisc() == false ) return
	diskContainer.insertDisk( "1", "insertDisk" )
	return

^+End:: ; Cancel Disk Change
  diskContainer.cancel()
  return

insertDisk( slotNo, file ) {
  activateEmulator()
	debug( "insert next disk : " file )
}