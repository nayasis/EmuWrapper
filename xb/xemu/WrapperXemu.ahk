#Requires AutoHotkey >=2.0
#Include "%A_ScriptDir%\..\..\ZZ_Library\Include.ahk"

emulatorPid := ""

imageDir := A_Args.Length > 0 ? A_Args[1] : ""
;imageDir := "\\NAS2\emul\image\xb\Conker - Live & Reloaded (rare)(T-ko 0.8 by haspi)"

container := DiskContainer(imageDir, "i).*\.(xiso|iso)$")
container.initSlot( 1 )

config := getConfig( imageDir, container )

command := "xemu.exe " config
debug(command)
RunWait(command, , , &emulatorPid)

ExitApp

waitEmulator() {
	WinWait("ahk_exe xemu.exe", , 10)
	if WinExist("ahk_exe xemu.exe")
		activateEmulator()
}

activateEmulator() {
	WinActivate("ahk_exe xemu.exe")
}

!F4:: { ; ALT + F4
	global emulatorPid
	ProcessClose(emulatorPid)
}
	
^+PGUP:: { ; Change CD rom
	global container
	if (container.size() > 1)
		container.insertDisk("1", "changeCdRom")
}


^+End:: { ; Cancel Disk Change
	global container
	if (container.size() > 1)
		container.cancel()
}


^+Del:: { ; Reset
	activateEmulator()
	; SendInput {Control down}{R}{Control up}
	; Send("^r")
	; SendEvent("^r")
	; ControlSend("^r", "ahk_exe xemu.exe")
}

^+F4:: { ;Exit
	global emulatorPid
	ProcessClose(emulatorPid)
}

^+Insert:: { ; Toggle Speed
	activateEmulator()
	; sendKey("F4")
}

changeCdRom(slotNo, file) {
	activateEmulator()
	SendText("^{o}")
	WinWait("ahk_exe xemu.exe ahk_class #32770", , 10)
	if WinExist("ahk_exe xemu.exe ahk_class #32770") {
		A_Clipboard := file
		Send("^v")
		Send("{Enter}")
	}
	waitEmulator()
}

getConfig(imageDir, diskContainer) {

	; dirBase := FileUtil.getDir(imageDir) "\_EL_CONFIG"
	; option  := getOption(imageDir)

  fileIni := setXemuIni(imageDir)

	config := " "
	; config .= " -full-screen"
	config .= " -config_path " wrap(fileIni)

	if (diskContainer.hasDisk()) {
		config .= " -dvd_path " wrap(diskContainer.getFile(1))
	}

	return config
	
}

getOption(imageDir) {
	dirConf := imageDir "\_EL_CONFIG"
	if FileExist(dirConf "\option\option.json") {
		jsonText := FileRead(dirConf "\option\option.json")
		option := JSON.parse(jsonText)
	} else {
		option := {}
	}
	return option
}

setXemuIni(imageDir) {
	fileIni := A_ScriptDir "\xemu.toml"
	saveDir := imageDir "\_EL_CONFIG\save\xemu"
	FileUtil.makeDir(saveDir)
	FileUtil.copy(A_ScriptDir "\bios\xbox_hdd.qcow2.src", saveDir "\xbox_hdd.qcow2", 0)
	IniWrite(" '" A_ScriptDir "\bios\xbox_4627_debug.bin'", fileIni, "sys.files", "flashrom_path")
	IniWrite(" '" A_ScriptDir "\bios\mcpx_1.0.bin'", fileIni, "sys.files", "bootrom_path")
	; IniWrite(" '" A_ScriptDir "\bios\eeprom.bin'", fileIni, "sys.files", "eeprom_path")
	IniWrite(" '" saveDir "\xbox_hdd.qcow2'", fileIni, "sys.files", "hdd_path")
	; IniDelete(fileIni, "system", "dvd_path")
	return fileIni
}
