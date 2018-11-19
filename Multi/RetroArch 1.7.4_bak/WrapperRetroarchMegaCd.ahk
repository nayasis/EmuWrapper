#NoEnv
#include %A_ScriptDir%\..\..\ZZ_Library\Include.ahk
SetKeyDelay, 10, 0

global emulatorPid  := ""
; global coreName     := "genesis_plus_gx_libretro.dll"
coreName     := "picodrive_libretro.dll"
imageDirPath := %0%
; imageDirPath := "f:\download\megaCd\Fahrenheit (32X) CHD (En)"
; imageDirPath := "\\NAS\emul\image\MegaCd\Shining Force CD (en)"

cdContainer := new DiskContainer( imageDirPath, "i).*\.(cue|chd)$" )
cdContainer.initSlot( 1 )

if ( cdContainer.size() >= 1 ) {
	runEmulator( coreName, cdContainer.getFile(1) )
} else {
	Run, % "retroarch.exe",,Hide,
	ExitApp
}

runEmulator( coreName, imageFilePath ) {

	;RetroArch Mednafen PCE Fast v0.9.38.7 d2080d7 || Frames: 3328
	;RetroArch Genesis Plus GX v1.7.4 0aa222e
	;RetroArch PicoDrive 1.92 f5d7a8d
	; WinWait, RetroArch Mednafen PCE Fast,, 10
	; WinWait, RetroArch Genesis Plus GX,, 10
	; WinWait, RetroArch PicoDrive,, 10

	debug( emulatorPid )

	if ( emulatorPid != "" ) {
		Process, Close, % emulatorPid
	}

	command := "retroarch.exe -L ./cores/" coreName " """ imageFilePath """"
	debug( command )

	Run, % command,,Hide,emulatorPid
	waitEmulator()

}

waitEmulator() {
	WinWait, ahk_class RetroArch ahk_exe retroarch.exe,, 10
	IfWinExist
	  activateEmulator()
}

activateEmulator() {
	WinActivate, ahk_class RetroArch ahk_exe retroarch.exe,, 10
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

ESC::
!F4::
	debug( "Close")
	Process, Close, % emulatorPid
	ExitApp

^+PGUP:: ; Insert Disk in Drive#1
	if( cdContainer.size() > 1 )
		cdContainer.insertDisk( "1", "insertDisk" )
  return

^+End:: ; Cancel Disk Change
  cdContainer.cancel()
  return

insertDisk( slotNo, file ) {
	Tray.showMessage( "Insert disk : " FileUtil.getFileName(file) )
	runEmulator( coreName, file )
}