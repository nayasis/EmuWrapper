#Include "%A_ScriptDir%\..\..\ZZ_Library\Include.ahk"

global emulatorPid := ""
global hackPid := ""

imageDir := A_Args.Length > 0 ? A_Args[1] : ""
;imageDir := "\\NAS2\emul\image\psx3\Super Robot Taisen OG - Dark Prison (bb studio)(T-ko 20240826 by Doukyusen)"
;imageDir := "\\NAS2\emul\image\psx3\Shin Gundam Musou (omega force)(ja)"
;imageDir := "\\NAS2\emul\image\psx3\Super Robot Taisen OG Saga - Masou Kishin F - Coffin of the End (winky soft)(T-ko)"

mountDir(imageDir)

option    := getOption(imageDir)
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
