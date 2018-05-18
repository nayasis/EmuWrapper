#NoEnv
#include %A_ScriptDir%\..\..\ZZ_Library\Include.ahk

emulatorPid   := ""
imageFilePath := %0%
;imageFilePath := "z:\Grandia (T-Kr) disk1.mdx"

isTestVer     := false

cdContainer := new DiskContainer( imageFilePath, "i).*\.(iso|cue|mdx)?$" )
cdContainer.initSlot( 1 )

if ( cdContainer.size() == 0 ) {
	Run, % "SSF.exe"
  ExitApp
}

config := getConfig( imageFilepath )

if ( VirtualDisk.open( cdContainer.getFile(1) ) == false ) {
	Run, % "SSF.exe"
  ExitApp
}

Run, % "SSF.exe",,, emulatorPid

waitEmul()
IfWinExist
{
	activateEmul()

	; if it is test version, alt-enter
	WinGetTitle, ssfWindowTitle, ahk_exe SSF.exe
	if( RegExMatch(ssfWindowTitle, "^SSF TestVer") ) {
		isTestVer := true
	}

	if( isTestVer == true ) {
		debug( "It is test version" )
		sleep, 3500
		activateEmul()
		send !{Enter}
	}

	WinWaitClose, ahk_exe SSF.exe
}

VirtualDisk.close()

ExitApp

!F4:: ; ALT + F4
	WinClose, ahk_exe SSF.exe
	return
	
^+PGUP:: ; Change CD rom
	cdContainer.insertDisk( "1", "changeCdRom" )
	return

^+End:: ; Cancel Disk Change	
	cdContainer.cancel()
	return

^+Del:: ; Reset
	activateEmul()
	if( isTestVer == true ) {
		activateEmul()
		send {F4}
	} else {
		WinMenuSelectItem, ahk_exe SSF.exe,,Hardware,Reset
	}
	
	return

^+F4:: ;Exit
	WinClose, ahk_exe SSF.exe
	return

^+Insert:: ; Toggle Speed
	Tray.showMessage( "Toggle speed is not supported in SSF" )
	return

waitEmul() {
	WinWait, ahk_exe SSF.exe ahk_class SSF Ver0.12,, 20
}

activateEmul() {
	WinActivate, ahk_exe SSF.exe ahk_class SSF Ver0.12
}

changeCdRom( slotNo, file ) {
	WinMenuSelectItem, ahk_exe SSF.exe,,Hardware,CD Open
	VirtualDisk.open( file )
	Sleep, 200
	WinMenuSelectItem, ahk_exe SSF.exe,,Hardware,CD Close
}

getConfig( imageFilePath ) {

	dirConf := FileUtil.getDir( imageFilepath ) . "\_EL_CONFIG"
	option  := ""

	return option
	
}