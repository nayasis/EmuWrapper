#Requires AutoHotkey >=2.0
#Include "%A_ScriptDir%\..\ZZ_Library\Include.ahk"

global EMUL_ROOT := A_ScriptDir "\0.276"
global emulPid := ""

romName := A_Args.Length > 0 ? A_Args[1] : ""
; romName := "ctower"

if (FileUtil.isDir(romName)) {
	romName := FileUtil.getFile(romName, "i).*\.(zip|7z)$")
	romName .= FileUtil.getName(romName)
}

romPath := ""
romPath .= "\\NAS2\emul\image\Mame\chd;"
romPath .= "\\NAS2\emul\image\Mame\bios;"
romPath .= "\\NAS2\emul\image\Mame\rom;"
; romPath .= "\\NAS\emul\image\ArcadeMame\Virtua Racing (en);"
; romPath .= "e:\download\MAME 0.219 ROMs (bios-devices)"

; artpath .= "\\NAS\emul\image\ArcadeMame\Space Invaders Part II (en)\artwork;"

options := ""
options .= " -hlsl_enable"
options .= " -waitvsync"
options .= ' -screen "\\.\DISPLAY3"'
; options .= " -skip_gameinfo"
options .= " -priority 1"
; options .= " -video opengl"
; options .= " -gl_glsl"
; options .= " -gl_glsl_filter 1"
; options .= " -glsl_shader_mame1"
; options .= " -glsl_shader_screen1"

; options .= " -video d3d"
; options .= " -filter 0"
; options .= " -hlsl_enable 0"

emulPid := ""
emulExe := EMUL_ROOT "\mame.exe"
emulIni := EMUL_ROOT "\mame.ini"

FileUtil.makeLink("d:\app\emulator\ZZ_snapshot", EMUL_ROOT "\snap", true)

; command := wrap(emulExe) " " options " -rompath " wrap(romPath) " -artpath " wrap(artpath) " " wrap(romName)
command := wrap(emulExe) " " options " -rompath " wrap(romPath) " " wrap(romName)

debug(romName)
debug(command)

Run(command, EMUL_ROOT, "Hide", &emulPid)

waitEmulator()
if WinExist("ahk_class MAME ahk_exe mame.exe") {
	waitCloseEmulator(emulPid)
}

debug("end !")
ExitApp

waitEmulator() {
	WinWait("ahk_class MAME ahk_exe mame.exe", , 10)
	if WinExist("ahk_class MAME ahk_exe mame.exe") {
		activateEmulator()
	}
}

activateEmulator() {
	WinActivate("ahk_class MAME ahk_exe mame.exe")
}

waitCloseEmulator(emulPid := "") {
	WinWaitClose("ahk_class MAME ahk_exe mame.exe")
	if (emulPid != "")
		ProcessWaitClose(emulPid)
}

sendHotKey(key) {
	Send("{" key " down}")
	Sleep(20)
	Send("{" key " up}")
	Sleep(20)
}

^+Del:: { ; Reset
	activateEmulator()
	Send("{H down}{H up}")
}

^+Insert:: { ; Toggle Speed
	Tray.showMessage("Toggle speed")
	activateEmulator()
	Send("{Space down}{Space up}")
}

!Enter:: { ; Toggle FullScreen
	activateEmulator()
	Send("{f down}{f up}")
}

!F4:: { ; Close
	debug("Close !!")
	activateEmulator()
	Send("{P down}")
	Sleep(500)
	Send("{P up}")
	Sleep(500)

	; Send("{ESC down}")
	; Sleep(500)
	; Send("{ESC up}")
	; Sleep(500)
	; if (emulPid != "") {
	; 	debug("emulPid : " emulPid)
	; 	ProcessClose(emulPid)
	; }
}
