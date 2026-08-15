#Requires AutoHotkey >=2.0
#Include "%A_ScriptDir%\..\..\ZZ_Library\Include.ahk"

emulatorPid := ""

imageDir := A_Args.Length > 0 ? A_Args[1] : ""
;imageDir := "\\NAS2\emul\image\vita\Saenai Heroine no Sodatekata - Blessing Flowers (5pb)(T-ko 1.01 by team hkhk)"

option  := getOption(imageDir)
titleId := getTitleId(imageDir)

if (titleId != "") {
	command := "Vita3k.exe"
	command .= " --fullscreen -r " titleId
	debug(command)

	Run(command, , , &emulatorPid)

	activateEmulator()
	waitCloseEmulator()

} else {
	command := "Vita3k.exe"
	debug(command)
	Run(command)
}

ExitApp()

getTitleId(imageDir) {
	if(imageDir == "0" || ! FileUtil.exist(imageDir)) {
		debug("No imageDir exist : " imageDir)
		for i,e in ["pref\ux0\addcont","pref\ux0\app","pref\ux0\license","pref\ux0\user\00\savedata","pref\ux0\user\00\VitaShell","textures"] {
			FileUtil.delete(A_ScriptDir "\" e)
		}
		return
	}
	titleDir := FileUtil.findFile(imageDir "\pref\ux0\app", ".*", true)
	titleId  := FileUtil.getName(titleDir)
	debug("- titleId  :" titleId)

	for i,e in ["pref\ux0\addcont","pref\ux0\app","pref\ux0\license","pref\ux0\user\00\savedata","pref\ux0\user\00\VitaShell","textures"] {
		src := imageDir    "\" e
		trg := A_ScriptDir "\" e
		FileUtil.makeDir(src)
		FileUtil.makeLink(src, trg, true)
	}

	return titleId
}

waitEmulator() {
	WinWait("ahk_exe Vita3k.exe", , 10)
}

activateEmulator() {
	waitEmulator()
	debug("activate emulator")
	WinActivate("ahk_exe Vita3k.exe")
}

waitCloseEmulator() {
	waitEmulator()
	if WinExist("ahk_exe Vita3k.exe")
		WinWaitClose("ahk_exe Vita3k.exe")
}

!F4:: { ; ALT + F4
	global emulatorPid
	ProcessClose(emulatorPid)
}
	
^+F4:: { ;Exit
	global emulatorPid
	ProcessClose(emulatorPid)
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
