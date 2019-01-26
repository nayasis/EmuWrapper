#Persistent

sendHotKey( key ) {
	Send {AppsKey down}
	Sleep 20
	Send {%key% down}
	Sleep 20
	Send {%key% up}
	Sleep 20
	Send {AppsKey up}
	Sleep 20
}

^+Del:: ; Reset
	Tray.showMessage( "Reset" )
	activateEmulator()
	sendHotKey( "H" )
	return

^+Insert:: ; Toggle Speed
	Tray.showMessage( "Toggle speed" )
	activateEmulator()
	sendHotKey( "space" )
	return

!Enter:: ;Toggle FullScreen
	debug( "Toggle fullscreen" )
	activateEmulator()
	sendHotKey( "f" )
	return

; Change Next Disk
^+PGUP::
	if ( diskContainer.size() <= 1 || onChangeDisk == true )
		return
	if ( diskContainer.slot[0] >= diskContainer.size() ) {
		Tray.showMessage( "It is last disc")
		return
	}
	diskContainer.slot[0] += 1
  Tray.showMessage( "Next disk`n`n" diskContainer.container[ diskContainer.slot[0] ] )
	onChangeDisk := true
	BlockInput On
	activateEmulator()
	sendHotKey( "/" )
	sendHotKey( "." )
	sendHotKey( "/" )
	onChangeDisk := false
	BlockInput Off
	return

; Change Previous Disk
^+PGDN::
	if ( diskContainer.size() <= 1 || onChangeDisk == true )
		return
	if ( diskContainer.slot[0] <= 1 ) {
		Tray.showMessage( "It is first disc")
		return
	}
	diskContainer.slot[0] -= 1
	Tray.showMessage( "Previous disc`n`n" diskContainer.container[ diskContainer.slot[0] ] )
	onChangeDisk := true
	BlockInput On
	activateEmulator()
	sendHotKey( "/" )
	sendHotKey( "," )
	sendHotKey( "/" )
	onChangeDisk := false
	BlockInput Off
	return
