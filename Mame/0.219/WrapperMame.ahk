#NoEnv
#include \\NAS\emul\emulator\ZZ_Library\Include.ahk

emulatorPid  := ""
emulatorPath := "c:\app\emulator\Mame\0.219\mame64.exe"
romName    := %0%
; romName := "f:\download\MAME 0.203 Software List ROMs (split)\apple2\ultima5.zip"
; romName := "bmiidx"
romName := "futari15"
romName := "galaga88"

if ( FileUtil.isDir(romName) ) {
	romName := FileUtil.getFile( romName, "i).*\.(zip|7z)$")
	romName := FileUtil.getFileName( romName )
}

romPath := ""
romPath .= "\\NAS\emul\image\Mame\chd;"
romPath .= "\\NAS\emul\image\Mame\bios;"
romPath .= "\\NAS\emul\image\Mame\rom;"

options := ""
; options .= " -hlsl_enable"
options .= " -waitvsync"
; options .= " -screen ""\\.\DISPLAY1"""
options .= " -skip_gameinfo"
options .= " -priority 1"
; options .= " -video opengl"
; options .= " -gl_glsl"
; options .= " -gl_glsl_filter 1"
; options .= " -glsl_shader_mame1"
; options .= " -glsl_shader_screen1"

; options .= " -video d3d"
; options .= " -filter 0"
; options .= " -hlsl_enable 0"

command := emulatorPath " " options " -rompath " wrapCmd(romPath) " " wrapCmd(romName) 

debug( command )
Run, % command,,Hide,

waitEmulator()

debug( "end !")

ExitApp

wrapCmd( command ) {
	return """" command """"
}

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