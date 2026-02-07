#Requires AutoHotkey >=2.0

SetTimer, threadClickSafeMode, 100
sleep 5000
ExitApp

threadClickSafeMode:
	IfWinExist, ���� ���� �����Ͻðڽ��ϱ�?
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