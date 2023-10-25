#NoEnv
#include %A_ScriptDir%\..\..\ZZ_Library\Include.ahk

global emulatorPid := ""

imageDir := %0%
; imageDir := "d:\app\Switch Army Knife\SAK_64bit"
;imageDir := "\\NAS2\emul\image\NSW\Legend of Zelda - Tears of the Kingdom (nintendo)(ko)"

makeLink(imageDir)

container := new DiskContainer( imageDir, "i).*\.(nsp|nsz|xci)$" )
container.initSlot( 1 )

config := getConfig( imageDir, container )

command := A_ScriptDir "\emul\Ryujinx.exe" config
debug(command)
RunWait, % command,,,emulatorPid

ExitApp

makeLink(imageDir) {
	makeSnapshotLink()
	makeContentLink(imageDir "\emul\games",A_ScriptDir "\emul\portable\games")
	makeContentLink(imageDir "\emul\mods", A_ScriptDir "\emul\portable\mods\contents")
}

makeSnapshotLink() {
	src := "c:\app\emulator\ZZ_snapshot"
	trg := A_ScriptDir "\emul\portable\screenshots"
	FileUtil.makeLink( src, trg, true )
}

makeContentLink(src,trg) {
	FileUtil.makeDir(src)
	FileUtil.makeLink(src, trg, true)
}

waitEmulator() {
	WinWait, ahk_exe xemu.exe,, 10
	IfWinExist
	  activateEmulator()
}

activateEmulator() {
	WinActivate, ahk_exe xemu.exe,, 10
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
	activateEmulator()
	; SendInput {Control down}{R}{Control up}
	; Send ^r
	; SendEvent ^r
	; ControlSend, ahk_exe xemu.exe, ^r
	return

^+F4:: ;Exit
	Process, Close, %emulatorPid%
	return

^+Insert:: ; Toggle Speed
	activateEmulator()
	; sendKey("F4")
	return

changeCdRom( slotNo, file ) {
	activateEmulator()
	SendRaw ^{o}
	WinWait, ahk_exe xemu.exe ahk_class #32770,, 10
	IfWinExist
	{
		Clipboard := file
		Send ^v
		Send {Enter}
	}
	waitEmulator()
	return
}

getConfig(imageDir, diskContainer) {

	; dirBase := FileUtil.getDir(imageDir) "\_EL_CONFIG"
	; option  := getOption(imageDir)

	config := ""
	; config .= " --fullscreen"
	; config .= " -r " wrap("d:\Games\Trinagle Strategy\data")

	if( diskContainer.hasDisk() ) {
		config .= " " wrap(diskContainer.getFile(1))
	}

	return config
	
}

getOption(imageDir) {
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