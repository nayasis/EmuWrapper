#NoEnv
#include %A_ScriptDir%\..\..\ZZ_Library\Include.ahk

global emulatorPid := ""

imageDir := %0%
; imageDir := "g:\work\_psx4\Unicorn Overlord"

option   := getOption(imageDir)
imageRom := findRom(imageDir)
debug("- imageRom : " imageRom)

if(imageRom != "") {
	command := "shadPS4.exe"
	command .= " -g " wrap(imageRom)
	debug(command)

	Run, % command,,,emulatorPid

	activateEmulator()
	waitCloseEmulator()

} else {
	command := "shadPS4.exe"
	debug(command)
	Run, % command,,,
}

ExitApp	

findRom(imageDir) {
	if(imageDir == "0" || ! FileUtil.exist(imageDir))
		return
	return FileUtil.getFile(imageDir, "\\eboot.bin", false, 3)
}

waitEmulator() {
	WinWait, ahk_exe shadPS4.exe,, 10
}

activateEmulator() {
	waitEmulator()
	debug("activate emulator")
	WinActivate, ahk_exe shadPS4.exe ahk_class SDL_app,, 10
}

waitCloseEmulator() {
	waitEmulator()
	IfWinExist
	  WinWaitClose, ahk_exe shadPS4.exe,,
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