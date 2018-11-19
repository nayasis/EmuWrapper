#NoEnv
#include %A_ScriptDir%\..\..\ZZ_Library\Include.ahk

emulatorPid := ""

imageFilePath := %0%
; imageFilePath := "f:\download\Tokimeki Memorial 2 Substories - Dancing Summer Vacation (Japan) (Disc 1)\Tokimeki Memorial 2 Substories - Dancing Summer Vacation (Japan) (Disc 1).cue"

cdContainer := new DiskContainer( imageFilePath, "i).*\.(cue|mdx)$" )
if ( cdContainer.size() == 0 ) {
	cdContainer := new DiskContainer( imageFilePath, "i).*\.(iso|bin)$" )
}
cdContainer.initSlot( 1 )

emulatorPath := "d:\app\Emul\PlayStation\PSX 1.13\psxfin.exe"

if ( cdContainer.size() >= 1 ) {

	config := getConfig( imageFilepath )

	if ( VirtualDisk.open( cdContainer.getFile(1) ) == true ) {

		Run, % emulatorPath " " config,,,emulatorPid

		WinWait, ahk_exe psxfin.exe ahk_class ConsoleWindowClass,, 10
		IfWinExist
		{
		 	WinHide, ahk_exe psxfin.exe ahk_class ConsoleWindowClass
		}


		WinWait, ahk_class pSX,, 60
		IfWinExist
		{
			WinActivate, ahk_class pSX
			WinWaitClose, ahk_class pSX
		}

		Process, Close, %emulatorPid%
		VirtualDisk.close()
		
	} else {
		config := config " """ cdContainer.getFile(1) """"
		RunWait, % emulatorPath " " config,,,emulatorPid
	}

} else {
	RunWait, % emulatorPath " " config,,,emulatorPid
}

ExitApp	


!F4:: ; ALT + F4
	WinClose,  ahk_class pSX
	return
	
^+PGUP:: ; Change CD rom
	cdContainer.insertDisk( "1", "changeCdRom" )
	return

^+End:: ; Cancel Disk Change	
	cdContainer.cancel()
	return

^+Del:: ; Reset
	WinActivate, ahk_class pSX
	send {Alt}
	send {Down}
	send {Down}
	send {Down}
	send {Down}
	send {Enter}
	return

^+F4:: ;Exit
	WinClose,  ahk_class pSX
	return

^+Insert:: ; Toggle Speed
	Tray.showMessage( "Toggle speed" )
	if( GetKeyState( "Tab" ) == true ) {
		SendInput {Tab up}
	} else {
		SendInput {Tab Down}
	}
	return

changeCdRom( slotNo, file ) {
	VirtualDisk.open( file )
}

getConfig( imageFilePath ) {

	dirConf   := FileUtil.getDir( imageFilepath ) . "\_EL_CONFIG"
	dirBios   := dirConf "\bios"
	dirMemory := dirConf "\memcards"

	FileUtil.makeDir( dirConf )
	FileUtil.makeDir( dirMemory )	

	customBiosPath := ""

	IfExist %dirBios%
	{
		Loop, %dirBios%\*.bin
		{
			customBiosPath := A_LoopFileFullPath
			break
		}
	}

	IfNotExist %dirMemory%\epsxe001.mcr
		FileAppend,,%dirMemory%\epsxe001.mcr
	IfNotExist %dirMemory%\epsxe002.mcr
		FileAppend,,%dirMemory%\epsxe002.mcr

	option := ""

	; if( customBiosPath != "" ) {
	; 	option := option " -bios """ customBiosPath """"
	; }

	option := option " -a1,""" dirMemory "\epsxe001.mcr" """"
	option := option " -a2,""" dirMemory "\epsxe002.mcr" """"
	option := option " -f " ;full screen
	option := option " G:"  ;Drive letter

	return option
	
}