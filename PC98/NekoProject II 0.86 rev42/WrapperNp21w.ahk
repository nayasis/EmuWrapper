#NoEnv
#include %A_ScriptDir%\..\..\ZZ_Library\Include.ahk

emulatorPid  := ""
imageDirPath := %0%
; imageDirPath := "\\NAS\emul\image\PC98\Brandish 3 Renewal (ja)"

fddContainer := new DiskContainer( imageDirPath, "i).*\.(d88|fdi|fdd|hdm|nfd|xdf|tfd)" )
fddContainer.initSlot( 2 )

if ( setConfig( imageDirPath ) == true ) {

	; ResolutionChanger.change( 1366, 768 )
	; ResolutionChanger.change( 1024, 768 )
	; ResolutionChanger.change( 1280, 720 )
	
	Run, % "np21x64w.exe " fddContainer.toOption(),,,emulatorPid
	
	WinWait, ahk_class NP2-MainWindow,, 5
	IfWinExist
	{
		Send {F11}{S}{F}  ;Send !{Enter}
		WinWaitClose, ahk_class NP2-MainWindow
	}
	
	ResolutionChanger.restore()
	
} else {
	RunWait, % "np21x64w.exe",,,emulatorPid
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

getOption( imageDirPath ) {
	dirConf := imageDirPath "\_EL_CONFIG"
	IfExist %dirConf%\option\option.json
	{
		FileRead, jsonText, %dirConf%\option\option.json
		return JSON.load( jsonText )
	}
	return {}
}

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

getCdRom( imageDirPath ) {
	dirCdrom := imageDirpath "\_EL_CONFIG\cdrom"
	cdRom := FileUtil.getFile( dirCdrom, "i).*\.(cue)$" )
	if( cdRom == "" )
		cdRom := FileUtil.getFile( dirCdrom, "i).*\.(ccd)$" )
	if( cdRom == "" )
		cdRom := FileUtil.getFile( dirCdrom, "i).*\.(iso|bin|img)$" )
	return cdRom
}

setConfig( imageDirPath ) {

	currDir := FileUtil.getDir( imageDirpath )
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
	
  ; Init Hdd. Fdd, CdRom
	Loop, 4
	{
		IniWrite, % "", %NekoIniFile%, NekoProject21, HDD%a_index%FILE
		IniWrite, % "", %NekoIniFile%, NekoProject21, FDD%a_index%FILE
		IniWrite, % "", %NekoIniFile%, NekoProject21, CD%a_index%_FILE
	}

	; Set Hdd, Fdd, CdRom
	files := FileUtil.getFiles( currDir, "i).*\.(hdi|hdd)$" )
	Loop, % files.MaxIndex()
	{
		if( A_Index > 2 )
			break
		IniWrite, % files[a_index], %NekoIniFile%, NekoProject21, HDD%a_index%FILE
	}

	files := FileUtil.getFiles( currDir, "i).*\.(d88|fdi|fdd|hdm|nfd|xdf|tfd)$" )
	Loop, % files.MaxIndex()
	{
		if( A_Index > 2 )
			break
		IniWrite, % files[a_index], %NekoIniFile%, NekoProject21, FDD%a_index%FILE
	}

	cdRom := getCdRom( imageDirPath )
	if( cdRom != "" )
		IniWrite, % cdRom, %NekoIniFile%, NekoProject21, CD3_FILE

	if( option.config.clk_multi != "" )
		IniWrite, % option.config.clk_multi, %NekoIniFile%, NekoProject21, clk_multi
	if( option.config.ExMemory != "" )
		IniWrite, % option.config.ExMemory, %NekoIniFile%, NekoProject21, ExMemory

	return true

}

