#NoEnv
#include %A_ScriptDir%\..\..\ZZ_Library\Include.ahk

emulatorPid   := ""
imageFilePath := %0%
; imageFilePath := "\\NAS\emul\image\3DO\Adult\Yakyuuken Special"

cdContainer := new DiskContainer( imageFilePath, "i).*\.(iso|cue|mdx)?$" )
cdContainer.initSlot( 1 )

if ( cdContainer.size() == 0 || VirtualDisk.open( cdContainer.getFile(1) ) == false ) {
	Run, % "4DO.exe"
  ExitApp
}

Run, % "4DO.exe -StartLoadDrive H",,, emulatorPid

waitEmul()
IfWinExist
{
	activateEmul()
	waitClose()
}

VirtualDisk.close()

ExitApp

^+PGUP:: ; Change CD rom
	cdContainer.insertDisk( "1", "changeCdRom" )
	return

^+End:: ; Cancel Disk Change	
	cdContainer.cancel()
	return

^+Del:: ; Reset
	activateEmul()
	Send {F12}
	return

^+Insert:: ; Toggle Speed
	Tray.showMessage( "Toggle speed dose not suppoert" )
	return

waitEmul() {
	WinWait, ahk_exe 4DO.exe ahk_class WindowsForms10.Window.8.app.0.338574f_r9_ad1,, 20
}

waitClose() {
	WinWaitClose, ahk_exe 4DO.exe ahk_class WindowsForms10.Window.8.app.0.338574f_r9_ad1
}

activateEmul() {
	WinActivate, ahk_exe 4DO.exe ahk_class WindowsForms10.Window.8.app.0.338574f_r9_ad1
}

changeCdRom( slotNo, file ) {
	VirtualDisk.open( file )
	Sleep, 200
}