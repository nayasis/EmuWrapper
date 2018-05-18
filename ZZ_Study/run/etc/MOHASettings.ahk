#NoEnv
#Persistent

fileSetting := A_MyDocuments "\EA Games\Medal of Honor Airborne(tm)\Config\MOHASettings.ini"

Goto, ModifyFile

return


ModifyFile:

	IfExist, % fileSetting
	{
	  IniWrite, KOR,  %fileSetting%, Engine.Engine, Language
	  IniWrite, True, %fileSetting%, Engine.Engine, bSubtitlesEnabled
	  SetTimer, ModifyFile, Off
	  ExitApp
	} else {
		SetTimer, ModifyFile, 500
		return
	}

