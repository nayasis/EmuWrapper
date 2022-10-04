#NoEnv

SetTimer, threadClickSafeMode, 100
SetTimer, threadClickOptimalSettings, 100
SetTimer, threadCheckGameWindow, -1

sleep 10000

ExitApp

threadCheckGameWindow:
	debug("run1")
	WinWait, ahk_class CoDBlackOps,, 10
	IfWinExist
	{
    debug("found 1")
		ExitApp
	}
	return

threadClickSafeMode:
  debug("run2")
	IfWinExist, Run In Safe Mode?
	{
		debug("found 2")
		WinActivate
		Click 190, 170, Left
	}
	return

threadClickOptimalSettings:
  debug("run3")
	IfWinExist, Set Optimal Settings?
	{
		debug("found 3")
		WinActivate
		Click 440, 210, Left
	}
	return

debug( message="" ) {
  if( A_IsCompiled == 1 )
    return
  message .= "`r`n" 
  FileAppend %message%, *
}