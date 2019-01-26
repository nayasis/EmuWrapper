#NoEnv
#include \\NAS\emul\emulator\ZZ_Library\Include.ahk

emulatorPid := ""
emulatorPath := "d:\app\Emul\Arcade\0.203\mame64.exe"
romName    := %0%
romName := "f:\download\MAME 0.203 Software List ROMs (split)\apple2\ultima5.zip"
; romName := "bm1stmix"

if ( FileUtil.isDir(romName) ) {
	romName := FileUtil.getFile( romName, "i).*\.(zip|7z)$")
	romName := FileUtil.getFileName( romName )
}

; romPath := " -rompath "
romPath := romPath A_ScriptDir "\bios;"
; romPath := romPath A_ScriptDir "\rom;"
; romPath := romPath "\\NAS\emul\image\Mame\chd;"
; romPath := romPath "\\NAS\emul\image\Mame\bios;"
romPath := romPath "\\NAS\emul\image\Mame\rom;"
romPath := romPath "f:\download\MAME 0.203 Software List ROMs (split)\apple2;"

if ( FileUtil.exist("\\NAS\emul\image\Mame\chd\" romName) ) {
	romPath := romPath "\\NAS\emul\image\Mame\chd;"
}

options := " "
; options := options " -hlsl_enable"
options := options " -waitvsync"
; options := options " -screen ""\\.\DISPLAY1"""
; options := options " -skip_gameinfo"
options := options " -priority 1"

command := emulatorPath " """ romName """" options " -rompath """ romPath """"

debug( command )
Run, % command,,Hide,

activateEmulator()
waitEmulator()

ExitApp

waitEmulator() {
	WinWait, ahk_class MAME,, 10
	IfWinExist
	  activateEmulator()
}

activateEmulator() {
	WinActivate, ahk_class MAME,, 10
}

^+Del:: ; Reset
	activateEmulator()
	Send {H Down} {H Up}
	return

^+Insert:: ; Toggle Speed
	Tray.showMessage( "Toggle speed" )
	activateEmulator()
	Send {Space Down} {Space Up}
	return

!Enter:: ;Toggle FullScreen
	activateEmulator()
	Send {f Down} {f Up}
	return