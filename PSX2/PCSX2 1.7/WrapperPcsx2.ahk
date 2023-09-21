#NoEnv
#include %A_ScriptDir%\..\..\ZZ_Library\Include.ahk

global emulatorPid := ""
global hackPid := ""

makeLink()

imageDir := %0%
; imageDir := "\\NAS2\emul\image\PSX2\Super Robot Taisen Z (T-ko 23.05.08)"

option := getOption(imageDir)
; debug( ">> option`n" JSON.dump(option) )

container := new DiskContainer(imageDir, "i).*\.(chd|cso|iso|bin)$")
container.initSlot( 1 )

; config := getConfig( imageDir, container )

if ( container.hasDisk() ) {
	command := "pcsx2-qt.exe " wrap(container.getFile(1)) config
	debug(command)
	
	Run, % command,,,emulatorPid

	hackPid := runHack(imageDir)
	activateEmulator()
	waitCloseEmulator()

	if(hackPid != "") {
		Process, Close, % hackPid
	}

} else {
	command := "pcsx2-qt " config
	debug(command)
	RunWait, % command,,,emulatorPid
}

ExitApp	

runHack(imageDir) {
	hackFile := FileUtil.getFile(imageDir "\_EL_CONFIG\hack", ".*\.exe")
	debug("hack file : " hackFile)
	if(hackFile != "") {
		fileName := FileUtil.getName(hackFile)
		Sleep, 1000
		Run, % hackFile,, hackPid
		WinWait ahk_exe %fileName%
	}
	return hackPid
}

waitEmulator() {
	WinWait, ahk_exe pcsx2-qt.exe,, 10
}

activateEmulator() {
	waitEmulator()
	debug("activate emulator")
	WinActivate, ahk_exe pcsx2-qt.exe,, 10
}

waitCloseEmulator() {
	waitEmulator()
	IfWinExist
	  WinWaitClose, ahk_exe pcsx2-qt.exe,,
}

!F4:: ; ALT + F4
	Process, Close, % emulatorPid
	if(hackPid != "") {
		Process, Close, % hackPid
	}
  return
	
^+PGUP:: ; Change CD rom
	if( container.size() > 1 )
		container.insertDisk( "1", "changeCdRom" )
	return


^+End:: ; Cancel Disk Change
	if( container.size() > 1 )
		container.cancel()
	return

^+Del:: ; Reset
	openMainGui()
	Send !{R}{R}
	activateEmulator()
	return

^+F4:: ;Exit
	Process, Close, %emulatorPid%
	return

^+Insert:: ; Toggle Speed
	Tray.showMessage( "Toggle speed" )
	activateEmulator()
	sendKey( "F4" )
	return

openMainGui() {
	return
}

changeCdRom( slotNo, file ) {
	return
}

getConfig(imageDir, diskContainer) {

	dirBase := FileUtil.getDir(imageDir) "\_EL_CONFIG"
	option  := getOption(imageDir)

	config := " "
	
	if( diskContainer.hasDisk() ) {
		if( diskContainer.size() == 1 ) {
			; config .= " --nogui"
		}
	}

	if( option.core.renderer == "software" ) {
		config .= " --cfgpath="".\inis-software"""
	}

	return config
	
}

getOption( imageDir ) {
	dirConf := imageDir "\_EL_CONFIG"
	IfExist %dirConf%\option\option.json
	{
		FileRead, jsonText, %dirConf%\option\option.json
		option := JSON.load( jsonText )
	} else {
		option := {}
	}
	return option
}

makeLink() {
	for i,e in ["bios","memcards","snaps","sstates"] {
		src := A_ScriptDir "\..\share\" e
		trg := A_ScriptDir "\" e
		FileUtil.makeLink(src, trg)
	}
}