#NoEnv
#include %A_ScriptDir%\..\..\ZZ_Library\Include.ahk

global emulatorPid := ""

imageDir := %0%
imageDir := "g:\work\_psx4\Unicorn Overlord"

option  := getOption(imageDir)
titleId := getTitleId(imageDir)

if(titleId != "") {
	command := "Vita3k.exe"
	command .= " --fullscreen -r " titleId
	debug(command)

	Run, % command,,,emulatorPid

	activateEmulator()
	waitCloseEmulator()

} else {
	command := "Vita3k.exe"
	debug(command)
	Run, % command,,,
}

ExitApp	

getTitleId(imageDir) {
	if(imageDir == "0" || ! FileUtil.exist(imageDir)) {
		debug("No imageDir exist : " imageDir)
		for i,e in ["pref\ux0\addcont","pref\ux0\app","pref\ux0\license","textures"] {
			FileUtil.delete(A_ScriptDir "\" e)
		}
		return
	}
	titleDir := FileUtil.findFile(imageDir "\pref\ux0\app", ".*", true)
	titleId  := FileUtil.getName(titleDir)
	debug("- titleId  :" titleId)

	for i,e in ["pref\ux0\addcont","pref\ux0\app","pref\ux0\license","textures"] {
		src := imageDir    "\" e
		trg := A_ScriptDir "\" e
		FileUtil.makeDir(src)
		FileUtil.makeLink(src, trg, true)
	}

	return titleId
}

waitEmulator() {
	WinWait, ahk_exe Vita3k.exe,, 10
}

activateEmulator() {
	waitEmulator()
	debug("activate emulator")
	WinActivate, ahk_exe Vita3k.exe,, 10
}

waitCloseEmulator() {
	waitEmulator()
	IfWinExist
	  WinWaitClose, ahk_exe Vita3k.exe,,
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
		option := JSON.parse( jsonText )
	} else {
		option := {}
	}
	return option
}
