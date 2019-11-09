; CoordMode, Mouse, Relative

WinWaitActive, Ys: Memories of Celceta
If WinExist( "Ys: Memories of Celceta" ) {
	WinActivate
	Send {Tab}
	Send +{Tab}
	Send {Enter}
}

ExitApp