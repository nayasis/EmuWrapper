#NoEnv

iniFile  := A_ScriptDir "\bin\cpkredir.ini"
modsPath := A_ScriptDir "\bin\mods\ModsDB.ini"
IniRead, prevPath, % iniFile, CPKREDIR, ModsDbIni
IniWrite, % modsPath, % iniFile, CPKREDIR, ModsDbIni

Run, % A_ScriptDir "\bin\hedgemodmanager_dd774.exe"
WinWait, ahk_exe hedgemodmanager_dd774.exe
IfWinExist
{
	WinActivate
  If(modsPath != prevPath) {
    debug("changed !!")
    Click 22,146
    ; IniRead, sections, % modsPath, Mods
    ; for k,line in StrSplit(sections,"`n") {
    ;   words := StrSplit(line,"=")
    ;   key   := words[1]
    ;   value := words[2]
    ;   if( InStr(value,"KoreanPatchMod1") ) {
    ;     debug(key " : " value)
    ;     IniWrite, % key, % modsPath, Main, ActiveMod0
    ;     IniWrite,     1, % modsPath, Main, ActiveModCount
    ;   }
    ; }
  }
	Click 516,602

	WinWait, ahk_exe SonicGenerations.exe
	IfWinExist
	{
		WinWaitClose, ahk_exe SonicGenerations.exe
	}
}

ExitApp

debug( message="" ) {
  if( A_IsCompiled == 1 )
    return
  message .= "`r`n" 
  FileAppend %message%, *
}