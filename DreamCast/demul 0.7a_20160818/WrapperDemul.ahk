#NoEnv
#include %A_ScriptDir%\..\..\ZZ_Library\Include.ahk

imageDir := %0%
; imageDir := "\\NAS\emul\image\Atomiswave\Extreme Hunting 2 (en)"
; imageDir := "\\NAS\emul\image\Naomi\Initial D Arcade Stage (en)"
imageDir := "\\NAS\emul\image\Naomi\Brave Fire Fighter"

option  := getOption( imageDir )
runType := nvl( option.option.run_type, "dc" )
padini  := getPadIniFiles( option )

debug( JSON.dump(option) )
debug( JSON.dump(padini) )

writeConfig( option )

diskContainer := new DiskContainer( imageDir, "i).*\.(chd|gdi|cdi)$" )

if ( diskContainer.hasDisk() ) {
	diskContainer.initSlot(1)
	command := "demul.exe -run=" runType " -image=" wrap(diskContainer.getFileInSlot(1))
} else {
	romPath := FileUtil.getFile( imageDir, "i).*\.(zip|7z)$" )
	if ( romPath != "" ) {
    setRomPath( romPath )
    romName := FileUtil.getName( romPath, false )
		command := "demul.exe -run=" runType " -rom=" wrap(romName)
	}
}

if( command != "" ) {

	debug( command )

	FileUtil.copy( padini.src, padini.trg )

	Run, % command,,,emulPid
	waitEmulator()
	IfWinExist
	{
		activateEmulator()
	  Process, WaitClose, % emulPid
	}

	Sleep, 500
	FileUtil.copy( padini.trg, padini.src )

} else {
	Run, % "demul.exe",,,		
}

ExitApp

getPadIniFiles( option ) {
	map := {}
	map.trg := A_ScriptDir "\padDemul.ini"

  if( option.option.use_custom_joyconfig == "true" ) {
  	map.src := option.imageDir "\_EL_CONFIG\option\padDemul.ini"
  } else {
  	map.src := A_ScriptDir "\padDemul.ini.src"
  }

  if( FileUtil.exist(map.trg) == false ) {
	FileUtil.write( map.trg )
  }
  if( FileUtil.exist(map.src) == false ) {
	FileUtil.copy( map.trg, map.src )
  	
  }

  return map
}

setRomPath( romfile ) {

  pathCfg  := A_ScriptDir "\demul.ini"
  pathBios := A_ScriptDir "\roms"
  pathRom  := FileUtil.getDir( romfile )

  IniWrite, % pathBios, % pathCfg, files, roms0
  IniWrite, % pathRom , % pathCfg, files, roms1
  IniWrite, 2, % pathCfg, files, romsPathsCount	

}

writeConfig( option ) {

	fileIni := "Demul.ini"
	IniWrite, % A_ScriptDir "\memsaves\vms00.bin", % fileIni, VMS, VMSA0
	IniWrite, % A_ScriptDir "\memsaves\vms10.bin", % fileIni, VMS, VMSB0
	IniWrite, % A_ScriptDir "\plugins\", % fileIni, plugins, directory
	IniWrite, % A_ScriptDir "\nvram\", % fileIni, files, nvram
	IniWrite, % A_ScriptDir "\roms\", % fileIni, files, roms0

  if( option.option.ini == "" )
  	return

  for tab, items in option.option.ini {
  	for key, value in items {
  		IniWrite % value, % fileIni, % tab, % key
  	}
  }

}

waitEmulator() {
	WinWait, ahk_exe demul.exe,, 10
	IfWinExist
	  activateEmulator()
}

getOption( imageDir ) {
	dirConf := imageDir "\_EL_CONFIG"
	IfExist %dirConf%\option\option.json
	{
		FileRead, jsonText, %dirConf%\option\option.json
		option := JSON.load( jsonText )
	} else {
		option := {}
	}
	option.imageDir := imageDir
	return option
}

activateEmulator() {
	WinActivate, ahk_exe demul.exe,, 10
}

getGameMeta( imageDir ) {
	dirConf := imageDir "\_EL_CONFIG"
	IfExist %dirConf%\option\gameMeta.json
	{
		FileRead, jsonText, %dirConf%\option\gameMeta.json
		return JSON.load( jsonText )
	}
	return {}
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