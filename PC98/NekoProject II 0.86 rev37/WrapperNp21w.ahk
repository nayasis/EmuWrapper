#NoEnv
#include %A_ScriptDir%\..\..\ZZ_Library\Include.ahk

emulatorPid    := ""
imageFilePath  := %0%
;imageFilePath  := "\\NAS\emul\image\PC9801\0_imagesFdi\Ys 2 (1988)(Nihon Falcom)(T-Kr)\Disk 1.d88"
; imageFilePath  := "\\NAS\emul\image\PC9801\OnWorking\0_imagesFdi\Ys 1"
; imageFilePath  := "\\NAS\emul\image\PC9801\OnWorking\0_imagesFdi\Ys 2 (1988)(Nihon Falcom)(T-Kr)"
; imageFilePath := "f:\download\pc98\Ultima IV (T-ko)"
; imageFilePath := "f:\download\pc98\Ultima IV - The False Prophet (19xx)(Origin)"
; imageFilePath  := "\\NAS\emul\image\PC9801\Ys 2 (T-ko)"
; imageFilePath  := "\\NAS\emul\image\PC9801\Steam Heart's (T-en 0.99 by Psyklax)"
imageFilePath  := "\\NAS\emul\image\PC98\Ys 3 - Wanderers from Ys (ja)"

fddContainer := new DiskContainer( imageFilePath, "i).*\.(d88|fdi|fdd)" )
fddContainer.initSlot( 2 )

if ( setConfig( imageFilePath ) == true ) {

	; ResolutionChanger.change( 1366, 768 )
	ResolutionChanger.change( 1280, 720 )
	
	Run, % "np21x64w.exe " fddContainer.toOption(),,,emulatorPid
	
	WinWait, ahk_class NP2-MainWindow,, 5
	IfWinExist
	{
		Send {F11}{S}{F}  ;Send !{Enter}
		WinWaitClose, ahk_class NP2-MainWindow
	}
	
	ResolutionChanger.restore()
	
} else {
	Run, % "np21x64w.exe",,,emulatorPid
}

ExitApp

!F4:: ; ALT + F4
	Process, Close, %emulatorPid%
	return

^+PGUP::
	If GetKeyState( "z", "P" ) ; Ctrl + Shift + Z + PgUp :: Remove Disk in Drive#1
		fddContainer.removeDisk( "1", "removeDisk" )
	else ; Ctrl + Shift + PgUp :: Insert Disk in Drive#1
		fddContainer.insertDisk( "1", "insertDisk" )
	return

^+PGDN:: ; Insert Disk in Drive#2
	If GetKeyState( "z", "P" ) ; Ctrl + Shift + Z + PgDn :: Remove Disk in Drive#2
		fddContainer.removeDisk( "2", "removeDisk" )
	else ; Ctrl + Shift + PgDn :: Insert Disk in Drive#2
		fddContainer.insertDisk( "2", "insertDisk" )
	return

^+End:: ; Cancel Disk Change	
	fddContainer.cancel()
	return

^+Del:: ; Reset
    reset()
	return

waitEmulator() {
	WinWait, ahk_class NP2-MainWindow,,10
	IfWinExist
	  activateEmulator()
}

activateEmulator() {
	WinActivate, ahk_class NP2-MainWindow,,10
}

reset() {
	activateEmulator()
	Send {F11}{E}{R}
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

setConfig( imageFilePath ) {

	currDir := FileUtil.getDir( imageFilepath )
	confDir := currDir . "\_EL_CONFIG"
	
	NekoIniFile := % A_ScriptDir "\np21x64w.ini"
	
	if( currDir == "" ) {
		IniWrite, %A_ScriptDir%\font.rom, %NekoIniFile%, NekoProject21, fontfile
		IniWrite, 0, %NekoIniFile%, NekoProject21, windtype
		IniWrite, false, %NekoIniFile%, NekoProject21, Mouse_sw
		return false
	}
	
	; Set font
	
	IfExist %confDir%\font
	{
		Loop, %confDir%\font\*.*
		{
			IniWrite, %A_LoopFileFullPath%, %NekoIniFile%, NekoProject21, fontfile
			break
		}
	} else {
		IniWrite, %A_ScriptDir%\font.rom, %NekoIniFile%, NekoProject21, fontfile
	}

	; Set WindowType
	IniWrite, 0, %NekoIniFile%, NekoProject21, WindposX
	IniWrite, 0, %NekoIniFile%, NekoProject21, WindposY
	IniWrite, 1, %NekoIniFile%, NekoProject21, windtype
	
	; Lock Mouse
	IniWrite, true, %NekoIniFile%, NekoProject21, Mouse_sw

	; Init INI
	IniWrite, %currDir%, %NekoIniFile%, NekoProject21, FDfolder
	IniWrite, %currDir%, %NekoIniFile%, NekoProject21, HDfolder
	
	Loop, 8
	{
		fdIndex := A_Index - 1
		IniDelete, %NekoIniFile%, NP2 tool, FD1NAME%fdIndex%
		IniDelete, %NekoIniFile%, NP2 tool, FD2NAME%fdIndex%		
	}
	
	IniDelete, %NekoIniFile%, NekoProject21, HDD1FILE
	IniDelete, %NekoIniFile%, NekoProject21, HDD2FILE

	; Set Hdd & Fdd
	files := FileUtil.getFiles( currDir, "i).*\.(hdi|hdd)$" )
	Loop, % files.MaxIndex()
	{
		if( A_Index > 2 )
			break
		IniWrite, % files[a_index], %NekoIniFile%, NekoProject21, HDD%a_index%FILE
	}

	Loop, 4
	{
		IniWrite, % "", %NekoIniFile%, NekoProject21, FDD%a_index%FILE
	}

	files := FileUtil.getFiles( currDir, "i).*\.(d88|fdi|fdd)$" )
	Loop, % files.MaxIndex()
	{
		if( A_Index > 4 )
			break
		IniWrite, % files[a_index], %NekoIniFile%, NekoProject21, FDD%a_index%FILE
	}

	return true

}