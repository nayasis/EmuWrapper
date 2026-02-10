#NoEnv
#include d:\app\emulator\ZZ_Library\Include.ahk

global emulatorPid := ""
global emulatorExe := "duckstation-qt-x64-ReleaseLTCG.exe"

;makeLink()

imageDir := %0%
;imageDir := "\\NAS2\emul\image\psx1\Shin Megami Tensei if... (atlus)(T-ko 1.0 by K)"

imageFile := FileUtil.getFile( imageDir, "m3u|chd|cue|pbp|bin" )

option := getOption(imageDir)

if ( imageFile != "" ) {
	command := emulatorExe " " wrap(imageFile)
	debug(command)
	Run, % command,,,emulatorPid

} else {
	command := emulatorExe
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
		Run, % hackFile,,, hackPid
		WinWait ahk_exe %fileName%
		return fileName
	}
}

waitEmulator() {
	WinWait, ahk_exe %emulatorExe%,, 10
}

activateEmulator() {
	waitEmulator()
	WinActivate, ahk_exe %emulatorExe%,, 10
}

waitCloseEmulator() {
	waitEmulator()
	IfWinExist
	  WinWaitClose, ahk_exe %emulatorExe%,,

}

!F4:: ; ALT + F4
	Process, Close, % emulatorPid
  return
	
^+Insert:: ; Toggle Speed
	Tray.showMessage( "Toggle speed" )
	activateEmulator()
	sendKey( "F4" )
	return

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

getOption(imageDir) {
	dirConf := imageDir "\_EL_CONFIG"
	IfExist %dirConf%\option\option.json
	{
		FileRead, jsonText, %dirConf%\option\option.json
		option := JSON.parse( jsonText )
	} else {
		option := {}
	}
	return option
}

makeLink() {
	for i,e in ["bios","memcards","snaps","sstates"] {
		src := A_ScriptDir "\..\share\" e
		trg := A_ScriptDir "\" e
		FileUtil.makeLink(src, trg, true)
	}
}
