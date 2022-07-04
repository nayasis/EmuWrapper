#NoEnv
#include %A_ScriptDir%\..\..\ZZ_Library\Include.ahk

global emulatorPid := ""

imageDir := %0%
imageDir := "\\NAS2\emul\image\xb\Star Wars - Knights of the Old Republic\"

container := new DiskContainer( imageDir, "i).*\.(iso)$" )
container.initSlot( 1 )

config := getConfig( imageDir, container )

command := "xemu.exe " config
debug(command)
RunWait, % command,,,emulatorPid

ExitApp

waitEmulator() {
	WinWait, ahk_exe xemu.exe,, 10
	IfWinExist
	  activateEmulator()
}

activateEmulator() {
	WinActivate, ahk_exe xemu.exe,, 10
}

!F4:: ; ALT + F4
	Process, Close, %emulatorPid%
  return
	
^+PGUP:: ; Change CD rom
	if( container.size() > 1 )
		container.insertDisk( "1", "changeCdRom" )
	return


^+End:: ; Cancel Disk Change
	if( container.size() > 1 )
		container.cancel()
	return

^+Del:: ; Reset
	activateEmulator()
	; SendInput {Control down}{R}{Control up}
	; Send ^r
	; SendEvent ^r
	; ControlSend, ahk_exe xemu.exe, ^r
	return

^+F4:: ;Exit
	Process, Close, %emulatorPid%
	return

^+Insert:: ; Toggle Speed
	activateEmulator()
	; sendKey("F4")
	return

changeCdRom( slotNo, file ) {
	activateEmulator()
	SendRaw ^{o}
	WinWait, ahk_exe xemu.exe ahk_class #32770,, 10
	IfWinExist
	{
		Clipboard := file
		Send ^v
		Send {Enter}
	}
	waitEmulator()
	return
}

getConfig( imageDir, diskContainer ) {

	; dirBase := FileUtil.getDir(imageDir) "\_EL_CONFIG"
	; option  := getOption(imageDir)

  fileIni := setXemuIni()

	config := " "
	; config .= " -full-screen"
	; config .= " -config_path " wrap(fileIni)

	if( diskContainer.hasDisk() ) {
		config .= " -dvd_path " wrap(diskContainer.getFile(1))
	}

	return config
	
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
	return option
}

setXemuIni() {
	fileIni := A_ScriptDir "\xemu.ini"
  ; IniWrite, % A_ScriptDir "\bios\complex_4627_v1.03.bin", % fileIni, system, flash_path
  IniWrite, % " " A_ScriptDir "\bios\complex_4627.bin", % fileIni, system, flash_path
  IniWrite, % " " A_ScriptDir "\bios\mcpx_1.0.bin",     % fileIni, system, bootrom_path
  IniWrite, % " " A_ScriptDir "\bios\eeprom.bin",       % fileIni, system, eeprom_path
  IniWrite, % " " A_ScriptDir "\bios\xbox_hdd.qcow2",   % fileIni, system, hdd_path
  ; IniDelete, % fileIni, system, dvd_path
	return fileIni
}