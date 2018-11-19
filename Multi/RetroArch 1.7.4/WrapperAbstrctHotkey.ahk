#Persistent
SetKeyDelay, 10, 0

^+Del:: ; Reset
	debug( "Reset" )
	activateEmulator()
	Send {H Down} {H Up}
	return

^+Insert:: ; Toggle Speed
	debug( "Toggle speed" )
	Tray.showMessage( "Toggle speed" )
	activateEmulator()
	Send {Space Down} {Space Up}
	return

!Enter:: ;Toggle FullScreen
	debug( "Toggle fullscreen" )
	activateEmulator()
	Send {f Down} {f Up}
	return