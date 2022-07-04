#NoEnv
#include %A_ScriptDir%\..\ZZ_Library\Include.ahk

global EMUL_ROOT := A_ScriptDir "\0.243"
global emulPid   := ""

romName    := %0%
; romName := "f:\download\MAME 0.203 Software List ROMs (split)\apple2\ultima5.zip"
; romName := "gnw_opanic"
; romName := "futari15"
; romName := "unsquad"
; romName := "warlords"
; romName := "aerofgts"

if ( FileUtil.isDir(romName) ) {
	romName := FileUtil.getFile( romName, "i{P up}).*\.(zip|7z)$")
	romName .= FileUtil.getFileName( romName )
}

romPath .= "\\NAS2\emul\image\Mame\chd;"
romPath .= "\\NAS2\emul\image\Mame\bios;"
romPath .= "\\NAS2\emul\image\Mame\rom;"
; romPath .= "\\NAS\emul\image\ArcadeMame\Virtua Racing (en);"
; romPath .= "e:\download\MAME 0.219 ROMs (bios-devices)"

; artpath .= "\\NAS\emul\image\ArcadeMame\Space Invaders Part II (en)\artwork;"

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

emulPid  := ""
emulExe := EMUL_ROOT "\mame.exe"
emulIni := EMUL_ROOT "\mame.ini"

; command := wrap(emulExe) " " options " -rompath " wrap(romPath) " -artpath " wrap(artpath) " " wrap(romName) 
command := wrap(emulExe) " " options " -rompath " wrap(romPath) " " wrap(romName) 

debug( romName )

debug( command )
Run, % command, % EMUL_ROOT, hide, emulPid

waitEmulator()
IfWinExist
{
	waitCloseEmulator( emulPid )	
}

debug( "end !")

ExitApp

waitEmulator() {
	WinWait, ahk_class MAME ahk_exe mame64.exe,, 10
	IfWinExist
	{
	  activateEmulator()
	}
}

activateEmulator() {
	WinActivate, ahk_class MAME ahk_exe mame64.exe,, 10
}

waitCloseEmulator( emulPid:="" ) {
	WinWaitClose, ahk_class MAME ahk_exe mame64.exe,,
	if( emulPid != "" )
	  Process, WaitClose, emulPid
}

sendHotKey( key ) {
	Send {%key% down}
	Sleep 20
	Send {%key% up}
	Sleep 20
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

!F4:: ;Close
  debug( "Close !!" )
  ; SetKeyDelay, -1, 110
  activateEmulator()
  ; PostMessage,0x100, 80, , , ahk_class MAME
  SendRaw, {P down}
  Sleep, 500
  SendRaw, {P up}
  Sleep, 500

  ; Send {ESC Down}
  ; Sleep, 500
  ; Send {ESC Up}
  ; Sleep, 500
	; if( emulPid != "" ) {
	; 	debug( "emulPid : " emulPid )
	;   Process, Close, emulPid	
	; }
	return  