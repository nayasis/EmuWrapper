#NoEnv
#include %A_ScriptDir%\..\..\ZZ_Library\Include.ahk

emulatorPid    := ""
imageFilePath  := %0%
;imageFilePath  := ""

fddContainer := new DiskContainer( imageFilePath, "i).*\.dsk(\.zip)?$" )
fddContainer.initSlot( 2 )

option := setConfig( imageFilePath )

if( option != false ) {

	; commandLine := "openmsx.exe -machine Panasonic_FS-A1GT -control stdio" option
	commandLine := "openmsx.exe -machine BOOSTED_MSX2_EN -control stdio" option
	; commandLine := "openmsx.exe -machine C-BIOS_MSX2_JP -ext Sony_HBD-F1 -control stdio" option
	; commandLine := "openmsx.exe -machine C-BIOS_MSX1 -control stdio" option
	; commandLine := "openmsx.exe -machine Sony_HB-75P -control stdio" option
	;commandLine := "openmsx.exe -machine Boosted_MSXturboR -control stdio" option
	; commandLine := "openmsx.exe -machine Boosted_MSXturboR_with_IDE -control stdio" option
	;commandLine := "openmsx.exe -machine Gradiente_Expert_DD_Plus -control stdio" option

	global cmd := new Cli( commandLine, false )

	while "" == ( line := cmd.readPipe() )
	{
		Sleep, 200
		if ( a_index > 25 ) {
			executor.close()
			ExitApp
		}		
	}

	sendCommand( "<openmsx-control>" )
	sendCommand( "unset renderer" )
	sendCommand( "set power on" )

	cmd.waitForClose()

	cmd.close()	
	
} else {
	Run, % ".\Catapult\bin\Catapult.exe",,,emulatorPid
}

ExitApp

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
	sendCommand( "reset" )
	return

^+F4:: ;Exit
	cmd.close()
	return

!F4:: ;Exit
	cmd.close()
	return

^+Insert:: ; Toggle Speed
	Tray.showMessage( "Toggle speed" )
	WinActivate, ahk_class SDL_app ahk_exe openmsx.exe
	Send {F9}
	return

sendCommand( command ) {

	command := RegExReplace( command, "&", "&amp;" )

	if ! RegExMatch( command, "^<.+?>$")
		command := "<command>" command "</command>"

	cmd.writePipe( command, "UTF-8" )

}

insertDisk( slotNo, file ) {

	IfNotExist % file 
		return

	command := file
	command := RegExReplace( command, "\\", "/" )
	command := RegExReplace( command, "( |\[|\])", "\$1" )

	if ( slotNo == "1" ) {
		command := "diska " command
	} else if( slotNo == "2" ) {
		command := "diskb " command
	} else {
		return
	}

	sendCommand( command )

}

removeDisk( slotNo ) {

	WinActivate, ahk_class blueMSX

	if ( slotNo == "1" ) {
		sendCommand( "diska eject" )
	} else if( slotNo == "2" ) {
		sendCommand( "diskb eject" )
	}

}

setConfig( imageFilePath ) {

	currDir := FileUtil.getDir( imageFilepath )
	confDir := currDir . "\_EL_CONFIG"

	if( currDir == "" ) {
		return false
	}

	option := ""

	; Add Casette
	files := FileUtil.getFiles( currDir, "i).*\.cas(\.zip)?$" )
	if ( files.MaxIndex() > 0 ) {
		option := % option " -cassetteplayer """ files[ 1 ] """"
		return option
	}

	; Add Rom
	files := FileUtil.getFiles( currDir, "i).*\.rom(\.zip)?$" )
	if ( files.MaxIndex() > 0 ) {
		Loop, % files.MaxIndex()
		{
			if( a_index == 1 )
			option := % option " -carta """ files[a_index] """"

			if( a_index == 2 )
			option := % option " -cartb """ files[a_index] """"

			if( a_index > 2 )			
			break
		}
		return option
	}

	; Add Disk
	files := FileUtil.getFiles( currDir, "i).*\.dsk(\.zip)?$" )
	if ( files.MaxIndex() > 0 ) {
		Loop, % files.MaxIndex()
		{
			if( a_index == 1 )
			option := % option " -diska """ files[a_index] """"

			if( a_index == 2 )
			option := % option " -diskb """ files[a_index] """"

			if( a_index > 2 )			
			break
		}
		return option
	}

	return false

}
