#Requires AutoHotkey >=2.0
#Include "%A_ScriptDir%\..\..\ZZ_Library\Include.ahk"

global emulPid := ""
imageDir := A_Args.Length > 0 ? A_Args[1] : ""
;imageDir := "\\NAS2\emul\image\GameCube\Second Sight (free radical design)(en)"

setConfig(imageDir)

global cdContainer := DiskContainer(imageDir, "i).*\.(gcz|cue|iso|wbfs|rvz)$")
cdContainer.initSlot(1)

emulDir  := A_ScriptDir "\bin\dolphin-2506-x64"
emulPath := emulDir "\Dolphin.exe"

unblockApp(emulPath)

if (cdContainer.hasDisk()) {

	command := emulPath " `"" cdContainer.getFile(1) "`""
	debug(command)
	Run(command, emulDir, , &emulPid)

	waitEmulator()
	if WinExist("ahk_class Qt651QWindowIcon ahk_exe Dolphin.exe") {
		waitEmulatorClosed(emulPid)
	}

} else {
	Run(emulPath, emulDir, , &emulPid)
}

ExitApp()

!F4:: { ; ALT + F4
	WinClose("ahk_class wxWindowNR ahk_exe Dolphin.exe")
	ProcessClose(emulPid)
}

^+PgUp:: {
	if GetKeyState("z", "P") ; Ctrl + Shift + Z + PgUp :: Remove Disk in Drive#1
		cdContainer.removeDisk("1", "removeDisk")
	else ; Ctrl + Shift + PgUp :: Insert Disk in Drive#1
		cdContainer.insertDisk("1", "insertDisk")
}

^+End:: { ; Cancel Disk Change
	cdContainer.cancel()
}

^+Del:: { ; Reset
	reset()
}

getOption(imageDir) {
	dirConf := imageDir "\_EL_CONFIG"
	if FileExist(dirConf "\option\option.json") {
		jsonText := FileRead(dirConf "\option\option.json")
		return JSON.parse(jsonText)
	}
	return {}
}

waitEmulator() {
	WinWait("ahk_class Qt651QWindowIcon ahk_exe Dolphin.exe", , 10)
	if WinExist("ahk_class Qt651QWindowIcon ahk_exe Dolphin.exe")
		activateEmulator()
}

waitEmulatorClosed(emulPid := "") {
	WinWaitClose("ahk_class Qt651QWindowIcon ahk_exe Dolphin.exe")
	if (emulPid != "")
		ProcessWaitClose(emulPid)
}

activateEmulator() {
	WinActivate("ahk_class Qt651QWindowIcon ahk_exe Dolphin.exe")
}

linkSnapshotDir() {
	from := A_ScriptDir "\..\..\ZZ_snapshot"
	to   := FileUtil.getHomeDir() "\Documents\Dolphin Emulator\ScreenShots"
	FileUtil.makeLink(from, to)
}

reset() {
	activateEmulator()
	Send("{ALT}{E}{R}")
}

insertDisk(slotNo, file) {

	if !FileExist(file)
		return

	activateEmulator()
	if (slotNo == "1") {
		Send("{F11}{1}{O}")  ;FDD1
	} else if (slotNo == "2") {
		Send("{F11}{2}{O}")  ;FDD2
	} else {
		return
	}

	WinWait("Select floppy image")
	if WinExist("Select floppy image") {
		Send("!{N}")
		A_Clipboard := file
		Send("^v")
		Send("{Enter}")
	}

}

removeDisk(slotNo) {
	activateEmulator()
	if (slotNo == "1") {
		Send("{F11}{1}{E}")  ;FDD1
	} else if (slotNo == "2") {
		Send("{F11}{2}{E}")  ;FDD2
	} else {
		return
	}
}

setConfig(imageDir) {

	linkSnapshotDir()

	currDir := FileUtil.getDir(imageDir)
	confDir := currDir . "\_EL_CONFIG"

	; Set option
	option := getOption(imageDir)

}

unblockApp(path) {
	command := "powershell -NoProfile -Command `"Unblock-File -LiteralPath '" path "'`""
	debug(command)
	RunWait(command, , "Hide")
}
