#NoEnv
#include FileUtil.ahk

restartAsAdmin()

pathSrc := FileUtil.getDir(A_LineFile) "\apppatch\CustomSDB\{6309ad21-54e0-4a29-bbc4-7705b285de2e}.sdb"
pathTrg := getWinDir() "\apppatch\CustomSDB"

debug( pathSrc " -> " pathTrg )

FileUtil.makeDir( pathTrg )
FileUtil.copy( pathSrc, pathTrg )

ExitApp

getWinDir() {
	EnvGet, windir, windir
	return nvl( windir, "C:\WINDOWS" )
}

debug( message ) {
  message .= "`n" 
  FileAppend %message%, * ; send message to stdout
}

nvl( val, defaultVal ) {
	if( val != "" )
		return val
	return defaultVal
}

restartAsAdmin() {
	if not (A_IsAdmin) {
    try ; leads to having the script re-launching itself as administrator
    {
        if A_IsCompiled
            Run *RunAs "%A_ScriptFullPath%" /restart
        else
            Run *RunAs "%A_AhkPath%" /restart "%A_ScriptFullPath%"
    }
    ExitApp
	}
}