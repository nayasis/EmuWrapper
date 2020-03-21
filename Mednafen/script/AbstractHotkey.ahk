#Persistent

; Change CD rom
^+PGUP::
	if ( hasMultiDisc == false ) return
	activateEmulator()
	Send {F8 Down}{F8 Up}
	debug( "Open Tray" )
	Sleep, 40
	Send {F6 Down}{F6 Up}
	debug( "Swap disc" )
	Sleep, 40
	Send {F8 Down}{F8 Up}
	debug( "Close Tray" )
	return

; Reset
^+Del:: 
	activateEmulator()
	Send {F11 Down}{F11 Up}
	return

; Toggle Speed
^+Insert::
	Tray.showMessage( "Toggle speed" )
	activateEmulator()
	if( GetKeyState( "``" ) == true ) {
		SendInput {`` up}
	} else {
		SendInput {`` Down}
	}

	return

;Exit
!F4::
	Tray.showMessage( "Close" )
	activateEmulator()
	Send {Esc Down}{Esc Up}
	return
