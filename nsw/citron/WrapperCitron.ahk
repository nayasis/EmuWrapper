#NoEnv
#include %A_ScriptDir%\..\..\ZZ_Library\Include.ahk

global emulatorPid := ""

imageDir := %0%
;imageDir := "\\NAS2\emul\image\NSW\Final Fantasy Tactics - The Ivalice Chronicles (square enix,creative business unit iii)(T-ko 0.9 by ayadya.kr)"

imageRom := findRom(imageDir)

if(imageRom != "") {
	makeLink(imageDir)
	command := A_ScriptDir "\citron.exe " wrap(imageRom)
	debug(command)
	RunWait, % command,,,emulatorPid
} else {
	command := A_ScriptDir "\citron.exe"
	debug(command)
	RunWait, % command,,,emulatorPid
}

ExitApp

findRom(imageDir) {
	if(imageDir == "0" || ! FileUtil.exist(imageDir))
		return
	return FileUtil.getFile(imageDir, "i).*\.(nsp|nsz|xci)$")
}

makeLink(imageDir) {
	makeSnapshotLink()
	if(imageDir == "0")
		return
	makeContentLink(imageDir "\emul\games",A_ScriptDir "\user\shader	")
	makeContentLink(imageDir "\emul\mods", A_ScriptDir "\user\sdmc\atmosphere\contents")
}

makeSnapshotLink() {
	src := "d:\app\emulator\ZZ_snapshot"
	trg := A_ScriptDir "\user\screenshots"
	FileUtil.makeLink(src, trg, true)
}

makeContentLink(src,trg) {
	FileUtil.makeDir(src)
	FileUtil.makeLink(src, trg, true)
}

waitEmulator() {
	WinWait, ahk_exe citron-cmd.exe,, 10
	IfWinExist
	  activateEmulator()
}

activateEmulator() {
	WinActivate, ahk_exe citron-cmd.exe,, 10
}

!F4:: ; ALT + F4
	Process, Close, %emulatorPid%
  return
	
^+F4:: ;Exit
	Process, Close, %emulatorPid%
	return

^+Insert:: ; Toggle Speed
	activateEmulator()
	; sendKey("F4")
	return

getOption(imageDir) {
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