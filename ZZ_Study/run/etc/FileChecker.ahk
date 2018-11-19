#NoEnv
#Persistent

global tryCount := 0

SetTimer, FileChecker, 500
return

FileChecker:
  tryCount++
  if ( tryCount > 40 ) {
		SetTimer, FileChecker, Off
  }
	config := A_MyDocuments "\My Games\Sid Meier's Civilization 5\config.ini"
	IfExist, % config
	{
		IniWrite, ko_KR, % config, User Settings, Language
		SetTimer, FileChecker, Off
		ExitApp
	}