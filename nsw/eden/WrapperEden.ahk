#Requires AutoHotkey >=2.0
#include d:\app\emulator\ZZ_Library\Include.ahk
#include d:\app\emulator\ZZ_Library\EmulCommon.ahk

global emulatorPid := ""

imageDir := A_Args.Length > 0 ? A_Args[1] : ""
;imageDir := "\\NAS2\emul\image\NSW\Final Fantasy Tactics - The Ivalice Chronicles (square enix,creative business unit iii)(ko)"

if(imageDir == "")
	ExitApp

option := getOption(imageDir)
debug(">> option`n" . JSON.stringify(option))

makePortable()
setConfig(option)

imageRom := FileUtil.getFile(imageDir, "i).*\.(nsp|nsz|xci)$")
command  := wrap(A_ScriptDir . "\eden.exe")
if(imageRom != "") {
	command .= " " . wrap(imageRom)
}
debug(command)

Run(command, , , &emulatorPid)
waitEmulator()
waitCloseEmulator(emulatorPid)

ExitApp

makePortable() {
	userDir := A_ScriptDir "\user"
	if FileUtil.exist(userDir)
		return
	srcDir := EnvGet("APPDATA") "\eden"
	FileUtil.makeDir(userDir)
	copyPortableDir(srcDir, userDir, "config")
	copyPortableDir(srcDir, userDir, "keys")
	copyPortableDir(srcDir, userDir, "nand")
	copyPortableDir(srcDir, userDir, "sdmc")
	copyPortableDir(srcDir, userDir, "load")
}

copyPortableDir(srcDir, userDir, name) {
	src := srcDir "\" name
	if FileUtil.exist(src)
		FileUtil.copy(src, userDir "\" name)
}

setConfig(option) {
	file := A_ScriptDir "\user\config\qt-config.ini"
	copyDefaultConfig(file)
	system := option.get("system", JSON.Obj())
	if !(system is Object)
		return
	if system.has("language")
		writeSetting(file, "System", "language_index", toLanguageIndex(system.language))
	if system.has("region")
		writeSetting(file, "System", "region_index", toRegionIndex(system.region))
	if system.has("multicore")
		writeSetting(file, "Core", "use_multi_core", toIniBoolean(system.multicore))
	if system.has("fullscreen")
		writeSetting(file, "UI", "fullscreen", toIniBoolean(system.fullscreen))
	debug(">> qt-config.ini`n" . file)
}

copyDefaultConfig(file) {
	if FileUtil.exist(file)
		return
	src := EnvGet("APPDATA") "\eden\config\qt-config.ini"
	if FileUtil.exist(src)
		FileUtil.copy(src, file)
}

writeSetting(file, section, key, value) {
	if (value == "")
		return
	FileUtil.writeIni(file, section, key "\default", "false")
	FileUtil.writeIni(file, section, key, value)
}

toIniBoolean(value) {
	return JSON.toBoolean(value, false) ? "true" : "false"
}

toLanguageIndex(value) {
	static aliases := Map(
		"japanese", 0,
		"englishamerican", 1, "english", 1, "en", 1,
		"french", 2,
		"german", 3,
		"italian", 4,
		"spanish", 5,
		"chinese", 6,
		"korean", 7, "ko", 7,
		"dutch", 8,
		"portuguese", 9,
		"russian", 10,
		"taiwanese", 11,
		"englishbritish", 12,
		"frenchcanadian", 13,
		"spanishlatin", 14,
		"chinesesimplified", 15,
		"chinesetraditional", 16,
		"portuguesebrazilian", 17,
		"polish", 18,
		"thai", 19
	)
	return toEnumIndex(value, aliases)
}

toRegionIndex(value) {
	static aliases := Map(
		"japan", 0,
		"usa", 1, "us", 1, "america", 1,
		"europe", 2,
		"australia", 3,
		"china", 4,
		"korea", 5, "kr", 5,
		"taiwan", 6
	)
	return toEnumIndex(value, aliases)
}

toEnumIndex(value, aliases) {
	if (value == "")
		return ""
	if IsInteger(value)
		return value
	text := Trim("" value)
	if (text ~= "^\d+$")
		return text
	key := RegExReplace(StrLower(text), "[^a-z0-9]", "")
	return aliases.Has(key) ? aliases[key] : ""
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
