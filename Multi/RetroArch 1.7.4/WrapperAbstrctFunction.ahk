#NoEnv
#include \\NAS\emul\emulator\ZZ_Library\Include.ahk

global emulPid
global diskContainer := new DiskContainer()

runRomEmulator( imageFilePath, core ) {

	if ( imageFilePath != "" ) {

		command := "retroarch.exe -L ./cores/" core ".dll """ imageFilePath """"
		debug( command )

		Run, % command, , Hide, emulPid
		waitEmulator()
		IfWinExist
		{
			activateEmulator()
			; for reicast (DC)
			WinWaitClose, ahk_class RetroArch ahk_exe retroarch.exe
		  Process, WaitClose, emulPid
		  debug( "wait close" )
		}

	} else {
		Run, % "retroarch.exe",,Hide, emulPid
	}

}

getOption( imageDirPath ) {
	dirConf := imageDirPath "\_EL_CONFIG"
	IfExist %dirConf%\option\option.json
	{
		FileRead, jsonText, %dirConf%\option\option.json
		option := JSON.load( jsonText )
	} else {
		option := {}
	}

	modifyConfigDefault( option )
	modifyConfigCore( option )
	return option
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

nvl( val, defaultVal ) {
	if( val != "" )
		return val
	return defaultVal
}

getFilter( option, defaultVal ) {
	if ( option.run.filter != "" )
		return option.run.filter
	return defaultVal
}

getRomPath( imageDirPath, option, filter, readM3u=true ) {
	if ( option.run.rom != "" ) {
		romPath := FileUtil.getFile( imageDirPath, "i)" option.run.rom "\.(" filter ")$" )
		if ( romPath != "" ) {
			return romPath
		}
	}
	if ( readM3u == true ) {
		romPath := FileUtil.getFile( imageDirPath, "i).*\.(m3u)$")
		if ( romPath != "" ) {
			readM3U( romPath )
			return romPath
		}
	}
	return FileUtil.getFile( imageDirPath, "i).*\.(" filter ")$" )
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
	WinWait, ahk_class RetroArch ahk_exe retroarch.exe,, 60
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

readConfig( fileConfig ) {
	config := {}
	loop, read, % fileConfig
	{
		words := StrSplit( A_LoopReadLine, " = " )
		key   := words[1]
		val   := SubStr( words[2], 2, StrLen(words[2]) - 2 )
		config[ key ] := val
	}
	return config
}

writeConfig( fileConfig, config ) {
	buffer := ""
	for key, val in config {
		buffer .= key " = """ val """`n"
	}
	FileUtil.delete( fileConfig )
	FileAppend, % buffer, % fileConfig
}

modifyConfig( fileConfig, option, functionName ) {
	lambdaFunc := Func( functionName )
	if( lambdaFunc == null || ! IsFunc(lambdaFunc) )
	  return
	config := readConfig( fileConfig )
	lambdaFunc.( config, option )
	writeConfig( fileConfig, config )
}

modifyConfigDefault( option ) {
	modifyConfig( "retroarch.cfg", option, "setDefaultConfig" )
}

modifyConfigCore( option ) {
	modifyConfig( "retroarch-core-options.cfg", option, "setCoreConfig" )
}

setDefaultConfig( config, option ) {
	config.video_driver := nvl( option.run.videoDriver, "gl" )
	config.video_shader := nvl( option.run.videoShader, "\\ntsc\\ntsc-320px-svideo-gauss-scanline" )
	if ( config.video_driver == "gl" ) {
		config.video_shader := ":\shaders\shaders_glsl" config.video_shader ".glslp"
	} else {
		config.video_shader := ":\shaders\shaders_slang" config.video_shader ".glangp"
	}
	debug( "option.run.videoDriver : " option.run.videoDriver )
	debug( "option.run.videoShader : " option.run.videoShader )
	debug( "config.video_driver : " config.video_driver )
	debug( "config.video_shader : " config.video_shader )
}