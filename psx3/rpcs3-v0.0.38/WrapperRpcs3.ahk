#NoEnv
#include %A_ScriptDir%\..\..\ZZ_Library\Include.ahk

global emulatorPid := ""
global hackPid := ""

imageDir := %0%
;imageDir := "\\NAS2\emul\image\psx3\Persona 4 - The Ultimate in Mayonaka Arena (arc system works)(en)"

option    := getOption(imageDir)
imagePath := getImagePath(imageDir)

debug("imagePath:" imagePath)

if(imagePath != "") {
	command := "rpcs3.exe "
	command .= "--no-gui "
	command .= wrap(imagePath)
	debug(command)

	Run, % command,,,emulatorPid

	activateEmulator()
	waitCloseEmulator()

} else {
	command := "rpcs3.exe"
	debug(command)
	Run, % command,,,
}

ExitApp	

getImagePath(imageDir) {
	imagePath := FileUtil.getFile(imageDir "\PS3_GAME\USRDIR", "i)eboot\.bin")
	if(imagePath == "") {
	  imagePath := FileUtil.getFile(imageDir "\PS3_GAME\USRDIR", "i).*\.(bin)$")
	  if(imagePath == "") {
	  	mountDir  := FileUtil.getFile(imageDir, "\\([a-zA-Z0-9]{9})$", true)
	  	imagePath := FileUtil.getFile(mountDir "\USRDIR", "i).*\.(bin)$")
	  	if(imagePath != "") {
				trgDir := A_ScriptDir "\dev_hdd0\game\" FileUtil.getName(mountDir)
	  		FileUtil.makeLink(mountDir, trgDir, true)
	  	}
	  }
	}
  return imagePath
}

waitEmulator() {
	WinWait, ahk_exe rpcs3.exe,, 10
}

activateEmulator() {
	waitEmulator()
	debug("activate emulator")
	WinActivate, ahk_exe rpcs3.exe,, 10
}

waitCloseEmulator() {
	waitEmulator()
	IfWinExist
	  WinWaitClose, ahk_exe rpcs3.exe,,
}

!F4:: ; ALT + F4
	Process, Close, % emulatorPid
  return
	
^+F4:: ;Exit
	Process, Close, %emulatorPid%
	return

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