#NoEnv
#include %A_ScriptDir%\..\..\ZZ_Library\Include.ahk

emulatorPid := ""

imageFilePath := %0%
; imageFilePath := "\\NAS\emul\image\PlayStation\어드벤쳐\BioHazard - Director'sCut - Resident Evil - Director'sCut (T-ko)\"

writeRegistry()

cdContainer := new DiskContainer( imageFilePath, "i).*\.(cue|mdx)$" )
if ( cdContainer.size() == 0 ) {
	cdContainer := new DiskContainer( imageFilePath, "i).*\.(iso|bin)$" )
}
cdContainer.initSlot( 1 )


if ( cdContainer.size() >= 1 ) {

	config := getConfig( imageFilepath )

	firstCdImage := cdContainer.getFile(1)

	if ( FileUtil.isExt(firstCdImage, "mdx") ) {

		if ( VirtualDisk.open(firstCdImage) == false )
			ExitApp

		Run, % "ePSXe.exe " config,,,emulatorPid

		WinWait, ahk_class EPSXGUI,, 10
		IfWinExist
		{
			WinActivate, ahk_class EPSXGUI
			Send !{F}{Enter}
			Process, WaitClose, %emulatorPid%
		}

		VirtualDisk.close()

	} else {

		Run, % "ePSXe.exe " config,,,emulatorPid

		WinWait, ahk_class EPSXGUI,, 10
		IfWinExist
		{
			WinActivate, ahk_class EPSXGUI
			Send !{F}
			Send {Down}
			Send {Enter}
			Clipboard := firstCdImage
	    Send ^v
	    Send {Enter}
			Process, WaitClose, %emulatorPid%
		}

	}

} else {
	RunWait, % "ePSXe.exe",,,emulatorPid	
}

ExitApp	


!F4:: ; ALT + F4
	Tray.showMessage( "Close" )
  ;SetWinDelay, 50
	;PostMessage, 0x111, 40007,,,ahk_class EPSX	; Exit ePSXe ; ControlSend,, {Esc down}{Esc up}, ePSXe ahk_class EPSX
	;RunWait, taskkill /im ePSXe.exe /f
  ;ResolutionChanger.restore()
  openMainGui()
	Send !{F}{E}
	Process, Close, %emulatorPid%
  return
	
^+PGUP:: ; Change CD rom
	if( cdContainer.size() > 1 )
		cdContainer.insertDisk( "1", "changeCdRom" )
	return


^+End:: ; Cancel Disk Change
	if( cdContainer.size() > 1 )
		cdContainer.cancel()
	return

^+Del:: ; Reset
	openMainGui()
	Send !{R}{R}
	waitEmulator()
	return

^+F4:: ;Exit
	Process, Close, %emulatorPid%
  ResolutionChanger.restore()
  VirtualDisk.close()
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

waitEmulator() {
	WinWait, ahk_class EPSX,, 10
	IfWinExist
		WinActivate, ahk_class EPSX
}

changeCdRom( slotNo, file ) {
	openMainGui()
	if ( FileUtil.isExt(file, "mdx") )
	{
		Send !{F}{C}{C}
		if ( VirtualDisk.open(file) == true ) {
			WinActivate, ahk_exe ePSXe.exe ahk_class #32770
			Send {Enter}
		} else {
			WinActivate, ahk_exe ePSXe.exe ahk_class #32770
			Send {Escape}
		}
	} else {
		Send !{F}{C}{I}
		Clipboard := file
    Send ^v
    Send {Enter}
	}
	waitEmulator()
	return
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

	if ( customBiosPath == "" ) {
		dirBios := A_ScriptDir "\bios"
		IfExist %dirBios%
		{
			Loop, %dirBios%\*.bin
			{
				customBiosPath := A_LoopFileFullPath
				break
			}
		}		
	}

	IfNotExist %dirMemory%\epsxe001.mcr
		FileAppend,,%dirMemory%\epsxe001.mcr
	IfNotExist %dirMemory%\epsxe002.mcr
		FileAppend,,%dirMemory%\epsxe002.mcr

	option := ""

	if ( customBiosPath != "" ) {
		option := option " -bios """ customBiosPath """"
	}

	option := option " -loadmemc0 """ dirMemory "\epsxe001.mcr" """"
	option := option " -loadmemc1 """ dirMemory "\epsxe002.mcr" """"

	;option := option " -slowboot"
	;option := option " -nogui"

	return option
	
}

writeRegistry() {

	RegRead, epsxeVersion, HKEY_CURRENT_USER, SOFTWARE\epsxe\config, Version
	if( epsxeVersion == "" ) return

	SplitPath, A_ScriptName, , , , NoextScriptFileName

	Registry.write( A_ScriptDir "\" NoextScriptFileName ".reg" )

}