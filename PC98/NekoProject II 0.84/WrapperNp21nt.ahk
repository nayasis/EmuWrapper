#NoEnv
#include %A_ScriptDir%\..\..\ZZ_Library\Include.ahk

emulatorPid   := ""
imageDirPath  := %0%
; imageDirPath  := "\\NAS\emul\image\PC98\Ys 2 (T-ko)"
; imageDirPath := "\\NAS\emul\image\PC98\Mahou no Shougakusei Clit-chan (ja)"

fddContainer := new DiskContainer( imageDirPath, "i).*\.(d88|fdi|fdd|hdm|nfd|xdf|tfd)" )
fddContainer.initSlot( 2 )

if ( setConfig( imageDirPath ) == true ) {

	; ResolutionChanger.change( 1366, 768 )
	; ResolutionChanger.change( 1024, 768 )
	; ResolutionChanger.change( 1280, 720 )
	
	Run, % "np2nt.exe " fddContainer.toOption(),,,emulatorPid
	
	WinWait, ahk_class NP2-MainWindow,, 5
	IfWinExist
	{
		Send {F11}{S}{F}  ;Send !{Enter}
		WinWaitClose, ahk_class NP2-MainWindow
	}
	
	ResolutionChanger.restore()
	
} else {
	RunWait, % "np2nt.exe",,,emulatorPid
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
		Clipboard := %file%
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
	dirCdrom := imageDirPath "\_EL_CONFIG\cdrom"
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
	
	NekoIniFile := % A_ScriptDir "\np2nt.ini"
	
	if( currDir = "" ) {
		IniWrite, %A_ScriptDir%\font.rom, %NekoIniFile%, NekoProjectII, fontfile
		IniWrite, 0, %NekoIniFile%, NekoProjectII, windtype
		IniWrite, false, %NekoIniFile%, NekoProjectII, Mouse_sw
		return false
	}
	
	; Set font
	
	IfExist %confDir%\font
	{
		Loop, %confDir%\font\*.*
		{
			IniWrite, %A_LoopFileFullPath%, %NekoIniFile%, NekoProjectII, fontfile
			break
		}
	} else {
		IniWrite, %A_ScriptDir%\font.rom, %NekoIniFile%, NekoProjectII, fontfile
	}

	; Set WindowType
	IniWrite, 0, %NekoIniFile%, NekoProjectII, WindposX
	IniWrite, 0, %NekoIniFile%, NekoProjectII, WindposY
	IniWrite, 1, %NekoIniFile%, NekoProjectII, windtype

	; Set Bios for sound
	; IniWrite, 3e 63 7b,                %NekoIniFile%, NekoProjectII, DIPswtch
	; IniWrite, 48 05 04 08 0b 20 00 6e, %NekoIniFile%, NekoProjectII, MEMswtch
	
	; Lock Mouse
	IniWrite, true, %NekoIniFile%, NekoProjectII, Mouse_sw

	; Init INI
	IniWrite, %currDir%, %NekoIniFile%, NekoProjectII, FDfolder
	IniWrite, %currDir%, %NekoIniFile%, NekoProjectII, HDfolder
	
	; Loop, 8
	; {
	; 	fdIndex := A_Index - 1
	; 	IniDelete, %NekoIniFile%, NP2 tool, FD1NAME%fdIndex%
	; 	IniDelete, %NekoIniFile%, NP2 tool, FD2NAME%fdIndex%		
	; }
	
	; IniDelete, %NekoIniFile%, NekoProjectII, HDD1FILE
	; IniDelete, %NekoIniFile%, NekoProjectII, HDD2FILE

	; Init Hdd. Fdd, CdRom
	Loop, 4
	{
		IniWrite, % "", %NekoIniFile%, NekoProjectII, HDD%a_index%FILE
		IniWrite, % "", %NekoIniFile%, NekoProjectII, FD%a_index%NAME0
		IniWrite, % "", %NekoIniFile%, NekoProjectII, CD%a_index%_FILE
	}

	; Set Hdd, Fdd, CdRom
	files := FileUtil.getFiles( currDir, "i).*\.(hdi|hdd)" )
	Loop, % files.MaxIndex()
	{
		if( A_Index > 2 )
			break
		IniWrite, % files[a_index], %NekoIniFile%, NekoProjectII, HDD%a_index%FILE
	}

	files := FileUtil.getFiles( currDir, "i).*\.(d88|fdi|fdd|hdm|nfd|xdf|tfd)$" )
	Loop, % files.MaxIndex()
	{
		if( A_Index > 2 )
			break
		IniWrite, % files[a_index], %NekoIniFile%, NP2 tool, FD%a_index%NAME0
	}

	cdRom := getCdRom( imageDirPath )
	if( cdRom != "" )
		IniWrite, % cdRom, %NekoIniFile%, NekoProjectII, CD3_FILE

	; Set option
	option := getOption( imageDirPath )

	if( option.config.clk_mult != "" )
		IniWrite, % option.config.clk_mult, %NekoIniFile%, NekoProjectII, clk_mult
	if( option.config.ExMemory != "" )
		IniWrite, % option.config.ExMemory, %NekoIniFile%, NekoProjectII, ExMemory

	; set DIP switch
  dipswitch := "3e"

  if( option.config.GdcBlock == "2.5" ) {
    dipswitch .= " e3"
  } else {
    dipswitch .= " 63"
  }

  if( option.config.cpuMode == "low" ) {
    dipswitch .= " fb"
  } else {
    dipswitch .= " 7b"
  }

  IniWrite, % dipswitch, %NekoIniFile%, NekoProject21, DIPswtch

  ; boot priority
  ; - MEMswtch=48 05 04 08 0b 20 00 6e : 1 Floopy disk -> Hard disk
  ; - MEMswtch=48 05 04 08 2b 20 00 6e : 2 Boot on 640KB Floop disk
  ; - MEMswtch=48 05 04 08 4b 20 00 6e : 3 Boot on 1MB Floop disk
  ; - MEMswtch=48 05 04 08 ab 20 00 6e : 4 Boot on hard disk 1
  ; - MEMswtch=48 05 04 08 bb 20 00 6e : 5 Boot on hard disk 2
  ; - MEMswtch=48 05 04 08 fb 20 00 6e : 6 ROM BASIC

  IniRead, MemorySwitch, %NekoIniFile%, NekoProject21, MEMswtch
  debug( "MEMswtch (before) : " MemorySwitch )

  switch option.config.bootPrior {
   	case "1" : MemorySwitch := RegExReplace( MemorySwitch, "(.. .. .. ..) .(.) (.. .. ..)", "$1 0$2 $3")
  	case "2" : MemorySwitch := RegExReplace( MemorySwitch, "(.. .. .. ..) .(.) (.. .. ..)", "$1 2$2 $3")
  	case "3" : MemorySwitch := RegExReplace( MemorySwitch, "(.. .. .. ..) .(.) (.. .. ..)", "$1 4$2 $3")
  	case "4" : MemorySwitch := RegExReplace( MemorySwitch, "(.. .. .. ..) .(.) (.. .. ..)", "$1 a$2 $3")
  	case "5" : MemorySwitch := RegExReplace( MemorySwitch, "(.. .. .. ..) .(.) (.. .. ..)", "$1 b$2 $3")
  	case "6" : MemorySwitch := RegExReplace( MemorySwitch, "(.. .. .. ..) .(.) (.. .. ..)", "$1 f$2 $3")
  }
  debug( "MEMswtch (after)  : " MemorySwitch )
    
	IniWrite, % MemorySwitch, %NekoIniFile%, NekoProject21, MEMswtch

	return true

}