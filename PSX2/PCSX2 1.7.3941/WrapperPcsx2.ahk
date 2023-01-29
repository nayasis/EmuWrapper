#NoEnv
#include %A_ScriptDir%\..\..\ZZ_Library\Include.ahk

emulatorPid := ""

makeLink()

imageDir := %0%
; imageDir := "\\NAS2\emul\image\PSX2\Crash - Twin Sanity (traveller's tales)(en)"

container := new DiskContainer( imageDir, "i).*\.(chd|cso|iso|bin)$" )
container.initSlot( 1 )

; config := getConfig( imageDir, container )

if ( container.hasDisk() ) {
	command := "pcsx2-qtx64-avx2.exe " wrap(container.getFile(1)) config
	debug(command)
	RunWait, % command,,,emulatorPid
} else {
	command := "pcsx2-qtx64-avx2.exe " config
	debug(command)
	RunWait, % command,,,emulatorPid
}

ExitApp	

waitEmulator() {
	WinWait, ahk_exe pcsx2.exe,, 10
	IfWinExist
	  activateEmulator()
}

activateEmulator() {
	WinActivate, ahk_exe pcsx2.exe,, 10
}

!F4:: ; ALT + F4
	Process, Close, %emulatorPid%
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
	waitEmulator()
	return

^+F4:: ;Exit
	Process, Close, %emulatorPid%
	return

^+Insert:: ; Toggle Speed
	Tray.showMessage( "Toggle speed" )
	WinActivate, ahk_class EPSX
	sendKey( "F4" )
	return

openMainGui() {

	IfWinExist ahk_class EPSX
		sendKey( "Esc" )

	WinWait, ahk_class EPSXGUI,, 10
	IfWinExist
		WinActivate, ahk_class EPSXGUI

}

changeCdRom( slotNo, file ) {
	openMainGui()
	if ( FileUtil.isExt(file, "mdx") )
	{
		; Send !{F}{C}{C}
		; if ( VirtualDisk.open(file) == true ) {
		; 	WinActivate, ahk_exe ePSXe.exe ahk_class #32770
		; 	Send {Enter}
		; } else {
		; 	WinActivate, ahk_exe ePSXe.exe ahk_class #32770
		; 	Send {Escape}
		; }
	} else {
		Send !{F}{C}{I}
		Clipboard := file
    Send ^v
    Send {Enter}
	}
	waitEmulator()
	return
}

getConfig( imageDir, diskContainer ) {

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
		FileUtil.makeLink( src, trg )
	}
}