#NoEnv
#include %A_ScriptDir%\..\..\ZZ_Library\Include.ahk

global emulPid  := ""
imageDir := %0%
imageDir := "\\NAS\emul\image\GameCube\Star Wars Rogue Squadron III - Rebel Strike (en)"

setConfig( imageDir )

cdContainer := new DiskContainer( imageDir, "i).*\.(gcz|cue|iso)$" )
cdContainer.initSlot( 1 )

; emulDir  := A_ScriptDir "\bin\dolphin-master-5.0-6766-x64"
emulDir  := A_ScriptDir "\bin\dolphin-master-5.0-11590-x64"
emulPath := emulDir "\Dolphin.exe"

unblockApp( emulPath )

if ( cdContainer.hasDisk() ) {

	; ResolutionChanger.change( 1024, 768 )

  command := emulPath " """ cdContainer.getFile(1) """"
  debug( command )
	Run, % command, % emulDir,,emulPid

	waitEmulator()
	IfWinExist
	{
		waitEmulatorClosed( emulPid )
	}

	; ResolutionChanger.restore()
	
} else {
	Run, % emulPath, % emulDir,,emulPid
}

ExitApp

!F4:: ; ALT + F4
  WinClose, ahk_class wxWindowNR ahk_exe Dolphin.exe,,
	Process, Close, %emulPid%
	return

^+PGUP::
	If GetKeyState( "z", "P" ) ; Ctrl + Shift + Z + PgUp :: Remove Disk in Drive#1
		fddContainer.removeDisk( "1", "removeDisk" )
	else ; Ctrl + Shift + PgUp :: Insert Disk in Drive#1
		fddContainer.insertDisk( "1", "insertDisk" )
	return

^+End:: ; Cancel Disk Change	
	fddContainer.cancel()
	return

^+Del:: ; Reset
  reset()
	return

getOption( imageDir ) {
	dirConf := imageDir "\_EL_CONFIG"
	IfExist %dirConf%\option\option.json
	{
		FileRead, jsonText, %dirConf%\option\option.json
		return JSON.load( jsonText )
	}
	return {}
}

waitEmulator() {
	; Dolphin 5.0-11590 | JIT64 DC | OpenGL | HLE | FPS: 60 - VPS: 60 - 100% | Metroid Prime: Trilogy (R3ME01)
	; ahk_class Qt5QWindowIcon ahk_exe Dolphin.exe
	; ahk_class wxWindowNR ahk_exe Dolphin.exe
	; WinWait, ahk_class Qt5QWindowIcon ahk_exe Dolphin.exe,,10
	WinWait, ahk_class wxWindowNR ahk_exe Dolphin.exe,,10
	IfWinExist
	  activateEmulator()
}

waitEmulatorClosed( emulPid:="" ) {
	WinWaitClose, ahk_class wxWindowNR ahk_exe Dolphin.exe,,
	if( emulPid != "" )
	  Process, WaitClose, emulPid
}

activateEmulator() {
	WinActivate, ahk_class wxWindowNR ahk_exe Dolphin.exe,,10
}

activatePanel() {
  WinActivate, ahk_class Qt5QWindowIcon ahk_exe Dolphin.exe,,10	
}

reset() {
	activateEmulator()
	Send {ALT}{E}{R}
}

insertDisk( slotNo, file ) {

	IfNotExist % file 
    return

  activateEmulator()
	if( slotNo == "1" ) {
		Send {F11}{1}{O}  ;FDD1
	} else if( slotNo == "2" ) {
		Send {F11}{2}{O}  ;FDD2
	} else {
		return
	}
	
	WinWait, Select floppy image
	IfWinExist
	{
		Send !{N}
		Clipboard = %file%
		Send ^v
		Send {Enter}
	}
    
}

removeDisk( slotNo ) {
	activateEmulator()
	if( slotNo == "1" ) {
		Send {F11}{1}{E}  ;FDD1
	} else if( slotNo == "2" ) {
		Send {F11}{2}{E}  ;FDD2
	} else {
		return
	}
}

setConfig( imageDir ) {

	currDir := FileUtil.getDir( imageDir )
	confDir := currDir . "\_EL_CONFIG"
	
	; Set option
	option := getOption( imageDir )

}

unblockApp( path ) {
	command := "powershell unblock-file ""-path \""" path "\"""""
 	debug( command )
 	RunWait, % command,,Hide	
}