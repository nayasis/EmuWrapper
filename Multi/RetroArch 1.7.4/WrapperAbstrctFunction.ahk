#NoEnv
#include \\NAS\emul\emulator\ZZ_Library\Include.ahk

runRomEmulator( imageFilePath, core ) {

	if ( imageFilePath != "" ) {

		command := "retroarch.exe -L ./cores/" core ".dll """ imageFilePath """"
		debug( command )

		Run, % command,,Hide,emulatorPid
		waitEmulator()
		IfWinExist
		{
			activateEmulator()		
		  Process, WaitClose, %emulatorPid%
		}

	} else {
		Run, % "retroarch.exe",,Hide,
	}

}

getOption( imageDirPath ) {
	dirConf := imageDirPath "\_EL_CONFIG"
	IfExist %dirConf%\option\option.json
	{
		FileRead, jsonText, %dirConf%\option\option.json
		return JSON.load( jsonText )
	}
	return {}
}

getCore( option, defaultVal ) {
	if ( option.run.core != "" )
		return option.run.core
	return defaultVal
}

getFilter( option, defaultVal ) {
	if ( option.run.filter != "" )
		return option.run.filter
	return defaultVal
}

getRomPath( imageDirPath, option, filter ) {
	if ( option.run.rom != "" ) {
		romFile := FileUtil.getFile( imageDirPath, "i)" option.run.rom "\.(" filter ")$" )
		if ( romFile != "" ) {
			return romFile
		}
	}
	return FileUtil.getFile( imageDirPath, "i).*\.(" filter ")$" )
}

waitEmulator() {
	WinWait, ahk_class RetroArch ahk_exe retroarch.exe,, 30
	IfWinExist
	{
	  activateEmulator()
	}
}

activateEmulator() {
	WinActivate, ahk_class RetroArch ahk_exe retroarch.exe,, 30
}