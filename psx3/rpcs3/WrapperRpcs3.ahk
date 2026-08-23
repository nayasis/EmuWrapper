#Include "%A_ScriptDir%\..\..\ZZ_Library\Include.ahk"

global emulatorPid := ""
global hackPid := ""

imageDir := A_Args.Length > 0 ? A_Args[1] : ""
;imageDir := "\\NAS2\emul\image\psx3\Siren - New Translation (sce)(T-ko 2.0 fix by SCPH1000)"

mountDir(imageDir)

option    := getOption(imageDir)
setSystemConfig(option)
imagePath := getImagePath(imageDir)

debug("imagePath:" imagePath)

if(imagePath != "") {
	command := "rpcs3.exe "
	command .= "--no-gui "
	command .= "--fullscreen "
	command .= wrap(imagePath)
	debug(command)

	Run(command, , , &emulatorPid)

	activateEmulator()
	waitCloseEmulator()

} else {
	command := "rpcs3.exe"
	debug(command)
	Run(command)
}

ExitApp()

mountDir(imageDir) {
	Loop Files, imageDir "\hdd\*", "D" {
		srcDir := A_LoopFileFullPath
		trgDir := A_ScriptDir "\dev_hdd0\game\" FileUtil.getName(srcDir)
		FileUtil.makeLink(srcDir, trgDir, true)
	}
	Loop Files, imageDir "\home\00000001\exdata\*", "F" {
		srcDir := A_LoopFileFullPath
		trgDir := A_ScriptDir "\dev_hdd0\home\00000001\exdata\" FileUtil.getName(srcDir)
		FileUtil.makeLink(srcDir, trgDir, true)
	}
}

getImagePath(imageDir) {
	imagePath := FileUtil.findFile(imageDir "\disc\PS3_GAME\USRDIR", "i)eboot\.bin")
	if(imagePath == "") {
	  imagePath := FileUtil.findFile(imageDir "\disc\PS3_GAME\USRDIR", "i).*\.(bin)$")
	}
	if(imagePath == "") {
		imagePath := FileUtil.findFile(imageDir "\hdd\.*\USRDIR", "i)eboot\.(bin)$")
	}
	if(imagePath == "") {
		imagePath := FileUtil.findFile(imageDir "\hdd\.*\USRDIR", "i).*\.(bin)$")
	}
  return imagePath
}

setSystemConfig(option) {
	if (option.Has("settings") && option.settings.Has("system"))
		system := option.settings.system
	else if option.Has("system")
		system := option.system
	else
		return
	if (!system.Has("language") && !system.Has("region"))
		return

	file := A_ScriptDir "\config\config.yml"
	config := FileRead(file)
	if (system.Has("language") && system.language != "")
		config := RegExReplace(config, "m)^  Language: .*$", "  Language: " system.language)
	if (system.Has("region") && system.region != "")
		config := RegExReplace(config, "m)^  License Area: .*$", "  License Area: " getLicenseArea(system.region))

	FileUtil.write(file, config)
}

getLicenseArea(region) {
	regionCode := Map(
		"Japan", "SCEJ",
		"USA", "SCEA",
		"United States", "SCEA",
		"Europe", "SCEE",
		"Australia", "SCEE",
		"Korea", "SCEK",
		"Taiwan", "SCEH",
		"Hong Kong", "SCEH",
		"China", "SCH"
	)
	return regionCode.Has(region) ? regionCode[region] : region
}

waitEmulator() {
	WinWait("ahk_exe rpcs3.exe",, 10)
}

activateEmulator() {
	waitEmulator()
	debug("activate emulator")
	WinActivate("ahk_exe rpcs3.exe")
}

waitCloseEmulator() {
	waitEmulator()
	if WinExist("ahk_exe rpcs3.exe")
	  WinWaitClose("ahk_exe rpcs3.exe")
}

!F4:: { ; ALT + F4
	global emulatorPid
	ProcessClose(emulatorPid)
}
	
^+F4:: { ;Exit
	global emulatorPid
	ProcessClose(emulatorPid)
}

getOption( imageDir ) {
	dirConf := imageDir "\_EL_CONFIG"
	optionFile := dirConf "\option\option.json"
	if FileExist(optionFile) {
		jsonText := FileRead(optionFile)
		option := JSON.parse( jsonText )
	} else {
		option := {}
	}
	return option
}
