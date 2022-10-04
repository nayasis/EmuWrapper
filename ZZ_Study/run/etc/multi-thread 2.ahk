#NoEnv

SetTimer, threadClickSafeMode, 100
sleep 5000
ExitApp

threadClickSafeMode:
	IfWinExist, 안전 모드로 실행하시겠습니까?
	{
		WinActivate
		Click 176, 170, Left
		ExitApp
	}
	return

debug( message="" ) {
  if( A_IsCompiled == 1 )
    return
  message .= "`r`n" 
  FileAppend %message%, *
}