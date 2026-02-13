#Requires AutoHotkey >=2.0
#Include "%A_ScriptDir%\..\..\ZZ_Library\Include.ahk"

emulatorPid := ""
imageDir    := A_Args.Length > 0 ? A_Args[1] : ""
; imageDir := "\\NAS2\emul\image\3DS\Super Robot Taisen UX (T-ko)"
 ;imageDir := "\\NAS2\emul\image\3DS\Dragon Quest VIII - Journey of the Cursed King (square enix)(T-ko 1.2)"

imageFile := FileUtil.getFile(imageDir, "i).*\.(zip|3ds|3dsx|elf|axf|cci|cxi|cia|app)$")

linkSaveFolder(imageFile)

if (imageFile != "") {

	command := wrap(A_ScriptDir "\nightly\citra-qt.exe") " " wrap(imageFile)
	debug(command)
	Run(command, , , &emulatorPid)

	waitEmulator()
	waitEmulatorClose(emulatorPid)

} else {
	Run(A_ScriptDir "\nightly\citra.exe")
}

ExitApp

waitEmulator() {
	WinWait("ahk_exe citra-qt.exe", , 10)
	if WinExist("ahk_exe citra-qt.exe")
		activateEmulator()
}

activateEmulator() {
	WinActivate("ahk_class Qt5QWindowIcon ahk_exe citra-qt.exe")
}

waitEmulatorClose(pid) {
	WinWaitClose("ahk_exe citra-qt.exe")
	;Process, WaitClose, %pid%
}

^+Del:: { ; Reset
	activateEmulator()
	Send("!e{Alt Up}{Down}{Down}{Down}{Enter}")
}

^+Insert:: { ; Toggle Speed
	Tray.showMessage("Not supported in CITRA yet")
}

!Enter:: { ; Toggle FullScreen
	activateEmulator()
	Send("{F11}")
}


linkSaveFolder(gameFile) {

	currDir := FileUtil.getDir(A_LineFile)
	gameDir := FileUtil.getDir(gameFile)

	; symlink save foliders
	src := gameDir "\_EL_CONFIG\save\ra\save\Citra\Citra"
	trg := Environment.getUserHome() "\AppData\Roaming\Citra"
	if (gameDir == "") {
		src := currDir "\save"
	}
	for i, e in ["nand","sysdata","sdmc"] {
		debug(src "\" e "->" trg "\" e)
		FileUtil.makeDir(src "\" e)
		FileUtil.makeLink(src "\" e, trg "\" e, true)
	}
	FileUtil.makeLink(currDir "\save\config", trg "\config", true)

	; copy shared font
	fontSrc := currDir "\save\sysdata\shared_font.bin"
	fontTrg := gameDir "\_EL_CONFIG\save\ra\save\Citra\Citra\sysdata\shared_font.bin"
	if (!FileUtil.exist(fontTrg)) {
		FileUtil.copy(fontSrc, fontTrg)
	}

	;FileUtil.makeLink(currDir "\save\sysdata\shared_font.bin", trg "\sysdata\shared_font.bin", false)

	; symlink shapshot
	FileUtil.makeLink(FileUtil.getParentDir(currDir) . "\..\ZZ_snapshot", trg . "\screenshots", true)

}
