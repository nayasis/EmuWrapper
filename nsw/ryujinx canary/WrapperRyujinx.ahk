#Requires AutoHotkey >=2.0
#include d:\app\emulator\ZZ_Library\Include.ahk
#include d:\app\emulator\ZZ_Library\EmulCommon.ahk

global emulatorPid := ""

imageDir := A_Args.Length > 0 ? A_Args[1] : ""
;imageDir := "\\NAS2\emul\image\NSW\Ni no Kuni II Revenant Kingdom All In One Edition (T-ko)"

if(imageDir == "")
	ExitApp

option := getOption(imageDir)
debug(">> option.system`n" . JSON.stringify(option))

makeLink(imageDir)
setConfig(option)

imageRom := FileUtil.findFile(imageDir, "i).*\.(nsp|nsz|xci)$")
command  := wrap(A_ScriptDir . "\emul\Ryujinx.exe")
if(imageRom != "") {
	command .= " " . wrap(imageRom)
}
debug(command)

Run(command, , , &emulatorPid)
waitEmulator()
waitCloseEmulator(emulatorPid)

ExitApp

makeLink(imageDir) {
	makeSnapshotLink()
	if(imageDir == "0")
		return
	makeContentLink(imageDir "\emul\games", A_ScriptDir "\emul\portable\games")
	makeContentLink(imageDir "\emul\dlc",   A_ScriptDir "\emul\portable\patchesAndDlc")
	makeContentLink(imageDir "\emul\mods",  A_ScriptDir "\emul\portable\mods\contents")
}

makeSnapshotLink() {
	src := "d:\app\emulator\ZZ_snapshot"
	trg := A_ScriptDir "\emul\portable\screenshots"
	FileUtil.makeLink(src, trg, true)
}

makeContentLink(src,trg) {
	FileUtil.makeDir(src)
	FileUtil.makeLink(src, trg, true)
}

setConfig(option) {
	file   := A_ScriptDir "\emul\portable\Config.json"
	config := FileUtil.readJson(file)
	config.system_language  := option.system.language
	config.system_region    := option.system.region
	config.start_fullscreen := JSON.toBoolean(option.system.fullscreen)
	debug(">> Config.json`n" . JSON.stringify(config))
	FileUtil.write(file, JSON.stringify(config))
}

waitEmulator() {
	WinWait("ahk_exe Ryujinx.exe",, 10)
	if WinExist("ahk_exe Ryujinx.exe")
		activateEmulator()
}

activateEmulator() {
	WinActivate("ahk_exe Ryujinx.exe")
}

waitCloseEmulator(emulatorPid := "") {
	WinWaitClose("ahk_exe Ryujinx.exe")
	if (emulatorPid != "")
		ProcessWaitClose(emulatorPid)
}

!F4:: { ; Close
	if (emulatorPid != "" && ProcessExist(emulatorPid)) {
		debug("Close emulator : " emulatorPid)
		ProcessClose(emulatorPid)
	}
}
