#NoEnv
#include c:\app\emulator\ZZ_Library\Include.ahk

; global windowMain := "ahk_exe HDLGManClient.exe"
global windowMain := "ahk_exe HDLGManClient-timeout-160.exe"


checkMainAppRunning()

WinActivate, % windowMain

; send {Tab}

; for i, e in getGames() {
; 	debug( i ":" e )
; }

; debug( getGames() )


While True
{

	currGame := getSelectedGame()

  if( prevGame == currGame ) {
  	debug( "all games copied !!" )
  	ExitApp
  }

	debug( "copy : " currGame )

	copyGame( currGame )
	waitCopyDone()

	prevGame := currGame

  ; cursor down on main table (game list)
  WinActivate, % windowMain
	Send +{Tab}
	Send +{Tab}
	Send +{Tab}
	Send {Down}	
  Sleep, 500

}

ExitApp

checkMainAppRunning() {
	IfWinNotExist, % windowMain
	{
		MsgBox, % "HDL Client is not running !"
		ExitApp
	}	
}

getGames() {
	games := []
	ControlGet, contents, List,, ListBox1, % windowMain
	Loop, Parse, contents, `n
	{
		games.push( A_LoopField )
	}
  return games
}

getSelectedGame() {
	ControlGet, selected, Choice,, ListBox1, % windowMain
	return selected
}

copyGame( gameName ) {

	Clipboard := gameName ".iso"
	clickBtnCopy()

	Sleep, 1000
  Send ^v
  Sleep, 10
  Send {Enter}

}

waitCopyDone() {
	WinWait, Copying game...
	IfWinExist
	{
		; debug( "copy window exist !")
		WinWait, Reading complete.
		IfWinExist
		{
			; debug( "copy done !")
			WinActivate, Reading complete.
			Send {Enter}
			return true
		}
	}
	return false
}

clickBtnCopy() {
	ControlClick, Button4, % windowMain
}

clickMainTable() {
	ControlClick, ListBox1, % windowMain	
}