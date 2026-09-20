#Requires AutoHotkey >=2.0
#Include "%A_ScriptDir%\..\..\ZZ_Library\Include.ahk"

emulatorPid  := ""
isFullScreen := true

imageDir := A_Args.Length > 0 ? A_Args[1] : ""
;imageDir := "\\NAS2\emul\image\PSP\DJ Max Portable 2 - Collector's Edition (pentavision)(ko)(H-1.2)"

imageFile := FileUtil.findFile(imageDir, "i).*\.(chd|cso|iso)$")

if(imageFile != "") {
	setConfig(imageDir)
	command := "PPSSPPWindows64.exe " wrap(imageFile)
	Run(command, , , &emulatorPid)
	waitEmulator()
	if WinExist("ahk_class PPSSPPWnd")
		ProcessWaitClose(emulatorPid)
} else {
	RunWait("PPSSPPWindows64.exe", , , &emulatorPid)
}

ExitApp()

waitEmulator() {
	WinWait("ahk_class PPSSPPWnd", , 10)
	if WinExist("ahk_class PPSSPPWnd")
		activateEmulator()
}

activateEmulator() {
	WinActivate("ahk_class PPSSPPWnd")
}

setConfig(imageDir) {
	dirConf := FileUtil.getDir(imageDir) . "\_EL_CONFIG"
	FileUtil.makeDir(dirConf)

	; set custom font
	fontCustom   := dirConf "\font\jpn0.pgf"
	fontCurr     := A_ScriptDir "\assets\flash0\font\jpn0.pgf"
	fontOriginal := A_ScriptDir "\assets\flash0\font\jpn0.pgf.src"

	if (FileUtil.exist(fontCustom)) {
		if (!FileUtil.exist(fontCurr) || !isEqualAttr(fontCustom, fontCurr))
			FileUtil.copyFile(fontCustom, fontCurr)
	} else if (FileUtil.exist(fontOriginal)) {
		if (!FileUtil.exist(fontCurr) || !isEqualAttr(fontOriginal, fontCurr))
			FileUtil.copyFile(fontOriginal, fontCurr)
	}

	; copy custom save data
	dirCustomSave := dirConf "\save"
	dirEmulSave   := A_ScriptDir "\memstick\PSP\SAVEDATA"
	if (FileUtil.exist(dirCustomSave)) {
		zipFiles := FileUtil.findFiles(dirCustomSave, "i).*\.(zip|7z)$")
		Loop zipFiles.Length {
			zipFile := zipFiles[A_Index]
			pureName := FileUtil.getFileName(zipFile, false)
			if (FileUtil.exist(dirEmulSave "\" pureName))
				continue

			zipHandler := SevenZip(zipFile)
			zipHandler.extract(dirEmulSave)
			zipHandler.close()

			debug(zipFile " -> " dirEmulSave)
		}

		; FileUtil.copyDir(dirCustomSave "\*", )
	}

	; set full screen
	iniFile := A_ScriptDir "\memstick\PSP\System\ppsspp.ini"
	IniWrite(true, iniFile, "Graphics", "FullScreen")
}

isEqualAttr(src, trg) {
	if (FileUtil.getSize(src) != FileUtil.getSize(trg))
		return false
	if (FileUtil.getTime(src) != FileUtil.getTime(trg))
		return false
	return true
}
