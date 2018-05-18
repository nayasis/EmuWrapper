#NoEnv
#include %A_ScriptDir%\..\..\ZZ_Library\Include.ahk

imageFilePath := %0%
; imageFilePath := "\\NAS\emul\image\Windows 95\Uncharted Water 3 (ko)\"

cdContainer := getCdContainer( imageFilepath )
option      := setConfig( imageFilePath, cdContainer )

runEmulator( option )

ExitApp	


getCdContainer( imageFilepath ) {

	dirCdrom := imageFilepath "\_EL_CONFIG\cdrom"
	cdContainer := new DiskContainer( dirCdrom, "i).*\.(cue)?$" )
	if( cdContainer.size() == 0 )
	{
		cdContainer := new DiskContainer( dirCdrom, "i).*\.(iso|bin)?$" )	
	}
	cdContainer.initSlot( 1 )
	return cdContainer

}

runEmulator( config ) {

	debug( "dosbox.exe " config )

	Run, % "dosbox.exe " config,,Hide,emulatorPid
	WinWait, ahk_class SDL_app ahk_exe dosbox.exe,, 10
	IfWinExist
	{
		WinActivate, ahk_class SDL_app ahk_exe dosbox.exe
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

setConfig( imageFilePath, cdContainer ) {
	
	option := ""
	
	dirConf          := imageFilepath "\_EL_CONFIG"
	dirDosboxSave    := dirConf "\save"
	fileDosboxConf   := A_ScriptDir "\dosbox.conf"

	FileUtil.makeDir( dirConf )
	FileUtil.makeDir( dirDosboxSave )

	dosboxConfAutoexec := ""
	dosboxConfAutoexec := dosboxConfAutoexec "[autoexec]`n"
	dosboxConfAutoexec := dosboxConfAutoexec "# imgmount 0 .\WIN_IMG\DOS6.IMA -t floppy -fs none `n"
	dosboxConfAutoexec := dosboxConfAutoexec "imgmount 2 .\WIN_IMG\WIN98.img -t hdd -fs none -size 512,63,32,520  -ide 1m`n`n"
	
	; set cdrom images
	if( cdContainer.size() > 0 )
	{
		images := ""
		Loop, % cdContainer.size()
			images := images " """ cdContainer.getFile( A_Index ) """"

		dosboxConfAutoexec := dosboxConfAutoexec "imgmount f: " images " -t iso -fs iso -ide 2m`n"
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
			dosboxConfAutoexec := dosboxConfAutoexec startupCommand "`n"
			dosboxConfAutoexec := dosboxConfAutoexec items.executable "`n"
		}

		tabs := jsonObj._NewEnum()
		While tabs[tabName, items]
		{
			if ( tabName != "autoexec" )
			{
				items := items._NewEnum()
				While items[key,val]
				  IniWrite, %val%, %fileDosboxConf%, %tabName%, %key%
			}
  	}

	}

	dosboxConfAutoexec := dosboxConfAutoexec "boot -l c`n`n"

  debug( fileDosboxConf )
  debug( dosboxConfAutoexec )

  IniDelete, %fileDosboxConf%, autoexec
 	FileAppend, %dosboxConfAutoexec%, %fileDosboxConf%

	IfNotExist %dirDosboxSave%\save.001
		FileAppend,,%dirDosboxSave%\save.001

	option := option " -conf """ fileDosboxConf """"
	; option := option " -opensaves """ dirDosboxSave "\save.001"""
	option := option " -noconsole"

	return option

}