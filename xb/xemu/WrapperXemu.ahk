#Requires AutoHotkey >=2.0
#Include "%A_ScriptDir%\..\..\ZZ_Library\Include.ahk"

emulatorPid := ""

imageDir := A_Args.Length > 0 ? A_Args[1] : ""
;imageDir := "\\NAS2\emul\image\xb\Panzer Dragoon Orta (T-ko 0.9)"

option   := getOption(imageDir)
config   := getConfig(imageDir, option)

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
	
getConfig(imageDir, option) {

  fileIni := setXemuIni(imageDir, option)

	config := " "
	; config .= " -full-screen"
	config .= " -config_path " wrap(fileIni)

	imageFile := FileUtil.findFile(imageDir, "i).*\.(xiso|iso)$")
	if (imageFile != "") {
		config .= " -dvd_path " wrap(imageFile)
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

setXemuIni(imageDir, option) {
	fileIni := A_ScriptDir "\xemu.toml"
	saveDir := imageDir "\_EL_CONFIG\save\xemu"
	FileUtil.makeDir(saveDir)
	FileUtil.copy(A_ScriptDir "\bios\xbox_hdd.qcow2.src", saveDir "\xbox_hdd.qcow2")

	if(option.system.region == "") {
		option.system.region := "na"
	}

	IniWrite(wrap(A_ScriptDir "\bios\xbox_4627_debug.bin", "'"),         fileIni, "sys.files", "flashrom_path")
	IniWrite(wrap(A_ScriptDir "\bios\mcpx_1.0.bin", "'"),                fileIni, "sys.files", "bootrom_path")
	IniWrite(wrap(A_ScriptDir "\bios\eeprom." option.system.region ".bin","'"), fileIni, "sys.files", "eeprom_path")
	IniWrite(wrap(saveDir "\xbox_hdd.qcow2","'"),                        fileIni, "sys.files", "hdd_path")
	return fileIni
}
