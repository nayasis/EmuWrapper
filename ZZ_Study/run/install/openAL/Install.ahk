#NoEnv

osPath := getEnv("SystemRoot")

path := osPath "\System32\OpenAL32.dll"

if ( ! exist(osPath "\System32\OpenAL32.dll") && ! exist(osPath "\SysWOW64\OpenAL32.dll") ) {
	restartAsAdmin()
	installOpenAl()	
}

ExitApp

installOpenAl() {
	cmd :=  A_ScriptDir "\oalinst.exe"
	Run *RunAs "%cmd%"
}

getEnv( environmentName ) {
    EnvGet, env, % environmentName
    return env
}

exist( path ) {
	return FileExist( path )
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