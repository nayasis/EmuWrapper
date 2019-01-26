#NoEnv
#include \\NAS\emul\emulator\ZZ_Library\Include.ahk

global emulatorPid
global emulatorHandler
global diskContainer := new DiskContainer()

runRomEmulator( imageFilePath, core ) {

	if ( imageFilePath != "" ) {

		command := "retroarch.exe -L ./cores/" core ".dll """ imageFilePath """"
		debug( command )

		Run, % command,,Hide,emulatorPid
		waitEmulator()
		IfWinExist
		{
			WinGet, emulatorHandler, ID
			activateEmulator()
		  Process, WaitClose, %emulatorPid%
		}

	} else {
		Run, % "retroarch.exe",,Hide,emulatorPid
	}

}

getOption( imageDirPath ) {
	dirConf := imageDirPath "\_EL_CONFIG"
	IfExist %dirConf%\option\option.json
	{
		FileRead, jsonText, %dirConf%\option\option.json
		option := JSON.load( jsonText )

		; IfExist %dirConf%\option\gameMeta.json
		; {
		; 	FileRead, jsonText, %dirConf%\option\gameMeta.json
		; 	gameMeta := JSON.load( jsonText )
		; 	gameMeta := JSON.load( gameMeta.option )
		; 	option.layout := gameMeta.layout
		; }

		return option
	}
	return {}
}

getGameMeta( imageDirPath ) {
	dirConf := imageDirPath "\_EL_CONFIG"
	IfExist %dirConf%\option\gameMeta.json
	{
		FileRead, jsonText, %dirConf%\option\gameMeta.json
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
		romPath := FileUtil.getFile( imageDirPath, "i)" option.run.rom "\.(" filter ")$" )
		if ( romPath != "" ) {
			return romPath
		}
	}
	romPath := FileUtil.getFile( imageDirPath, "i).*\.(m3u)$")
	if ( romPath != "" ) {
		readM3U( romPath )
		return romPath
	} else {
		return FileUtil.getFile( imageDirPath, "i).*\.(" filter ")$" )
	}
}

readM3U( path ) {
	Loop, Read, %path%
	{
		disc := Trim( A_LoopReadLine )
		if( disc == "" )
			Continue
		diskContainer.addPath( disc )
		diskContainer.slot[0] := 1

	}
}

waitEmulator() {
	WinWait, ahk_class RetroArch ahk_exe retroarch.exe,, 30
	IfWinExist
	{
	  activateEmulator()
	}
}

activateEmulator( delay:="" ) {
	WinActivate, ahk_class RetroArch ahk_exe retroarch.exe,, 30
	if ( delay != "" && delay > 0 ) {
		Sleep %delay%
	}
}