#NoEnv
#include %A_ScriptDir%\..\..\ZZ_Library\Include.ahk

global optionCgaComposite := false

debug( optionCgaComposite )

imageFilePath  := ""
windowsVersion := ""

Loop, %0%
{
	param := %A_Index%
	if ( A_Index == 1 ) {
		imageFilepath := param
	} else if( A_Index == 2 ) {
		windowsVersion := param
	}

}

; imageFilePath := "\\NAS\emul\image\DOS\3x3 Eyes - spirit sucking princess"
; windowsVersion := "win3kr"

cdContainer := getCdContainer( imageFilepath )

option := setConfig( imageFilePath, cdContainer, windowsVersion )

runEmulator( option )

ExitApp	



getCdContainer( imageFilepath ) {

	dirCdrom := imageFilepath "\_EL_CONFIG\cdrom"
	cdContainer := new DiskContainer( dirCdrom, "i).*\.(cue)?$" )
	if ( cdContainer.size() == 0 ) 	{
		cdContainer := new DiskContainer( dirCdrom, "i).*\.(iso|bin)?$" )	
	}
	cdContainer.initSlot( 1 )
	return cdContainer

}

runEmulator( config ) {

	debug( "dosbox.exe " option )

	Run, % "dosbox.exe " config,,,emulatorPid
	WinWait, ahk_class SDL_app ahk_exe dosbox.exe,, 10
	IfWinExist
	{
		WinActivate, ahk_class SDL_app ahk_exe dosbox.exe
		if( optionCgaComposite == true )
		{
			debug( "Enter in CGA composite 16color mode")
			Sleep, 3000
			Send {F12}
		}
		Process, WaitClose, %emulatorPid%
	}

}

!F4:: ; ALT + F4
  WinActivate, ahk_class SDL_app ahk_exe dosbox.exe
  Send {CtrlDown}{F9}{CtrlUp}
  return
	
^+PGUP:: ; Change CD rom
	cdContainer.insertDisk( "1", "changeCdRom", 0 )
	return

^+End:: ; Cancel Disk Change	
	cdContainer.cancel()
	return

^+Del:: ; Reset
Tray.showMessage( "Reset" )
	WinActivate, WinWait, ahk_class SDL_app ahk_exe dosbox.exe
	Send {CtrlDown}{AltDown}{Home}{AltUp}{CtrlUp}
	return

^+Insert:: ; Toggle Speed
	Tray.showMessage( "Toggle speed" )
	WinActivate, WinWait, ahk_class SDL_app ahk_exe dosbox.exe
	Send {CtrlDown}{=}{CtrlUp}
	return

waitEmulator() {
	WinWait, ahk_class SDL_app ahk_exe dosbox.exe,, 10
	IfWinExist
	{
		WinActivate, ahk_class SDL_app ahk_exe dosbox.exe
	}
}

changeCdRom( slotNo, file ) {
	WinActivate, WinWait, ahk_class SDL_app ahk_exe dosbox.exe
	Send {CtrlDown}{F4}{CtrlUp}
}

setConfig( imageFilePath, cdContainer, windowsVersion ) {
	
	option := ""
	
	dirConf          := imageFilepath "\_EL_CONFIG"
	dirDosboxSave    := dirConf "\save"
	dirDosboxConf    := dirConf "\dosboxConf"
	fileDosboxConf   := dirDosboxConf "\dosbox.conf"

	debug( fileDosboxConf )
	
	FileUtil.makeDir( dirConf )
	FileUtil.makeDir( dirDosboxSave )
	FileUtil.makeDir( dirDosboxConf )

	dosboxConfText := ""
	dosboxConfText := dosboxConfText "[autoexec]`n"
	dosboxConfText := dosboxConfText "SET SOUND=X:\SB16`n"
	dosboxConfText := dosboxConfText "SET MIDI=SYNTH:1 MAP:E`n"
	dosboxConfText := dosboxConfText "SET GAMEROOT=""" imageFilePath """`n"
	dosboxConfText := dosboxConfText "mount x """ A_ScriptDir "\mount\util""`n"
	dosboxConfText := dosboxConfText "mount y """ A_ScriptDir "\mount\gus""`n"
	dosboxConfText := dosboxConfText "PATH X:\MDIR;Y:\ULTRASND;Z:\`n"
	dosboxConfText := dosboxConfText "X:\SB16\DIAGNOSE /S`n"
	dosboxConfText := dosboxConfText "X:\SB16\MIXERSET /P /Q`n"
	dosboxConfText := dosboxConfText "MIXER MASTER 100 SPKR 100 GUS 100 SB 90 FM 90 MT32 100`n"
	dosboxConfText := dosboxConfText "SET PROPATS=Y:\PPL161`n"
	dosboxConfText := dosboxConfText "`n"

	dosboxConfText := dosboxConfText "MOUNT C """ imageFilePath """`n"
	dosboxConfText := dosboxConfText "C:`n"

	; set cdrom images
	if( cdContainer.size() > 0 )
	{
		images := ""
		Loop, % cdContainer.size()
		{
			images := images " """ cdContainer.getFile( A_Index ) """"
		}
		dosboxConfText := dosboxConfText "imgmount D: " images " -t iso -ide 2m`n`n"
	}

	if ( windowsVersion == "win3kr") {
		dosboxConfText := dosboxConfText "mount w """ A_ScriptDir "\mount\os\win3kr""`n"
		dosboxConfText := dosboxConfText "PATH %PATH%;W:\WINDOWS;W:\WINDOWS\SYSTEM32`n"
		dosboxConfText := dosboxConfText "SET TEMP=W:\WINDOWS\TEMP`n"
		dosboxConfText := dosboxConfText "copy W:\WINDOWS\시작프로.GRP.bak W:\WINDOWS\시작프로.GRP`n"
		dosboxConfText := dosboxConfText "copy W:\WINDOWS\IMEINFO.INI.bak W:\WINDOWS\IMEINFO.INI`n"
		
		dosboxConfText := dosboxConfText "copy c:\_EL_CO~1\os\win3\시작프로.GRP W:\WINDOWS\`n"
		dosboxConfText := dosboxConfText "copy c:\_EL_CO~1\os\win3\SYSTEM.INI W:\WINDOWS\`n"
		dosboxConfText := dosboxConfText "copy c:\_EL_CO~1\os\win3\WIN.INI W:\WINDOWS\`n"
		dosboxConfText := dosboxConfText "copy c:\_EL_CO~1\os\win3\IMEINFO.INI W:\WINDOWS\`n"

		dosboxConfText := dosboxConfText "ADDKEY p500 enter`n"
		dosboxConfText := dosboxConfText "W:\WINDOWS\WIN`n"

		dosboxConfText := dosboxConfText "copy W:\WINDOWS\시작프로.GRP c:\_EL_CO~1\os\win3`n"
		dosboxConfText := dosboxConfText "copy W:\WINDOWS\SYSTEM.INI c:\_EL_CO~1\os\win3`n"
		dosboxConfText := dosboxConfText "copy W:\WINDOWS\WIN.INI c:\_EL_CO~1\os\win3`n"
		dosboxConfText := dosboxConfText "copy W:\WINDOWS\IMEINFO.INI c:\_EL_CO~1\os\win3`n"

		dosboxConfText := dosboxConfText "EXIT`n"
	}

	; read json option
	IfExist %dirConf%\option\option.json
	{

		FileRead, jsonText, %dirConf%\option\option.json
		jsonObj := JSON.load( jsonText )

		; set default option
		jsonObj.ipx := {}
		jsonObj.ipx.ipx := "true"

		if ( jsonObj.autoexec != "" )
		{
			items := jsonObj.autoexec
			startupCommand := RegExReplace( items.startupCommand, "#{path}", imageFilePath )
			dosboxConfText := dosboxConfText startupCommand "`n"
			dosboxConfText := dosboxConfText items.executable "`n"
		}

		if ( jsonObj.gus != "" )
		{
			jsonObj.gus.ultradir := "Y:\ULTRASND"
		}


		tabs := jsonObj._NewEnum()
		While tabs[tabName, items]
		{

			dosboxConfText := dosboxConfText "`n[" tabName "]`n"

			if ( tabName != "autoexec" )
			{
				items := items._NewEnum()
				While items[key,val]
					dosboxConfText := dosboxConfText key "=" val "`n"
			}

			if ( tabName == "gus" )
			{

			}

		}

		; check option has CGA composite 
		if( jsonObj.dosbox.machine == "cga" && jsonObj.dosbox.cgacomposite == "true" )
		{
			optionCgaComposite := true
		}

	}

	FileDelete, %fileDosboxConf%
	FileAppend, %dosboxConfText%, %fileDosboxConf%

	IfNotExist %dirDosboxSave%\save.001
		FileAppend,,%dirDosboxSave%\save.001

	option := option " -conf """ fileDosboxConf """"
	; option := option " -opensaves """ dirDosboxSave "\save.001"""
	option := option " -noconsole"

	return option

}