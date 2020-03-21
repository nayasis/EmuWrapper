#NoEnv
#include %A_ScriptDir%\..\..\ZZ_Library\Include.ahk

emulPid  := ""
imageDir := %0%
; imageDir := "\\NAS\emul\image\PC98\Policenauts"
; imageDir := "\\NAS\emul\image\PC98\Tamashii no Mon (ja)"
; imageDir  := "\\NAS\emul\image\PC98\Ys 2 (T-ko)"
; imageDir  := "\\NAS\emul\image\PC98\Carmine (ja)"
; imageDir  := "\\NAS\emul\image\PC98\Policenauts (ja)"

fddContainer := new DiskContainer( imageDir, "i).*\.(d88|fdi|fdd|hdm|nfd|xdf|tfd)" )
fddContainer.initSlot( 2 )

if ( setConfig( imageDir ) == true ) {

	ResolutionChanger.change( 1366, 768 )
	
	Run, % "np21x64w.exe " fddContainer.toOption(),,,emulPid
	
	WinWait, ahk_class NP2-MainWindow,, 5
	IfWinExist
	{
		Send {F11}{S}{F}  ;Send !{Enter}
		WinWaitClose, ahk_class NP2-MainWindow
	}
	
	ResolutionChanger.restore()
	
} else {
	RunWait, % "np21x64w.exe",,,emulPid
}

ExitApp

!F4:: ; ALT + F4
	Process, Close, %emulPid%
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

getCdRom( imageDir ) {
	dirCdrom := imageDir "\_EL_CONFIG\cdrom"
	cdRom := FileUtil.getFile( dirCdrom, "i).*\.(cue)$" )
	if( cdRom == "" )
		cdRom := FileUtil.getFile( dirCdrom, "i).*\.(ccd)$" )
	if( cdRom == "" )
		cdRom := FileUtil.getFile( dirCdrom, "i).*\.(iso|bin|img)$" )
	return cdRom
}

setConfig( imageDir ) {

	currDir := FileUtil.getDir( imageDir )
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
		Loop, %confDir%\font\*.* {
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
	Loop, 4 {
	  IniWrite, % "",  %NekoIniFile%, NekoProject21, HDD%a_index%FILE
		IniWrite, % "",  %NekoIniFile%, NekoProject21, FDD%a_index%FILE
		IniWrite, % "",  %NekoIniFile%, NekoProject21, CD%a_index%_FILE
		IniWrite, % "1", %NekoIniFile%, NekoProject21, IDE%a_index%TYPE
	}
	IniWrite, % "2", %NekoIniFile%, NekoProject21, IDE3TYPE

	; Set Hdd, Fdd, CdRom
	hdds := FileUtil.getFiles( currDir, "i).*\.(hdi|hdd)$" )
	Loop, 2 {
		IniWrite, % hdds[a_index], %NekoIniFile%, NekoProject21, HDD%a_index%FILE
	}

	fdds := FileUtil.getFiles( currDir, "i).*\.(d88|fdi|fdd|hdm|nfd|xdf|tfd)$" )
	Loop, 4 {
		IniWrite, % fdds[a_index], %NekoIniFile%, NekoProject21, FDD%a_index%FILE
	}
	
	cdRom := getCdRom( imageDir )
	IniWrite, % cdRom, % NekoIniFile, NekoProject21, CD3_FILE

	; Set option
	option := getOption( imageDir )
	if( option.config.clk_mult != "" )
		IniWrite, % option.config.clk_mult, %NekoIniFile%, NekoProject21, clk_mult
	if( option.config.ExMemory != "" )
		IniWrite, % option.config.ExMemory, %NekoIniFile%, NekoProject21, ExMemory

	if( option.config.GdcBlock == "2.5" )
		; IniWrite, % "3e f3 7b", %NekoIniFile%, NekoProject21, DIPswtch
		IniWrite, % "3e e3 7b", %NekoIniFile%, NekoProject21, DIPswtch
	Else
		; IniWrite, % "3e 73 7b", %NekoIniFile%, NekoProject21, DIPswtch
		IniWrite, % "3e 63 7b", %NekoIniFile%, NekoProject21, DIPswtch

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

