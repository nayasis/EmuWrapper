#NoEnv
#include %A_ScriptDir%\..\ZZ_Library\Include.ahk

global EMUL_ROOT     := A_ScriptDir "\1.8.1"
global diskContainer := new DiskContainer()

runEmulator( imageFile, config, appendCommand="", callback="" ) {

	debug( "imageFile : " imageFile           )
	debug( "core      : " config.core         )
	debug( "shader    : " config.video_shader )

	emulator := wrapCmd( EMUL_ROOT "\retroarch.exe" )
  core     := wrapCmd( EMUL_ROOT "\cores\" config.core ".dll" )

	if ( imageFile != "" ) {

		command := emulator " -L " core
		command .= " --set-shader " wrapCmd( config.video_shader )
		if ( appendCommand != "" ) {
			command .= " " appendCommand
		}

		command .= " " wrapCmd( imageFile )
		debug( "command   : " command )

		Run, % command, , Hide, emulPid

	} else {
		Run, % emulator,,Hide, emulPid
	}

	waitEmulator()
	IfWinExist
	{
		activateEmulator()
		if ( imageFile != "" && isFunc(callback) ) {
			Func(callback).( emulPid, core, imageFile, option )
		}
		WinWaitClose, ahk_class RetroArch ahk_exe retroarch.exe
	  Process, WaitClose, emulPid
	}

}

wrapCmd( command ) {
	return """" command """"
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

nvl( val, defaultVal ) {
	if( val != "" )
		return val
	return defaultVal
}

getRomPath( imageDirPath, option, filter ) {
	if ( option.run.rom != "" ) {
		romPath := FileUtil.getFile( imageDirPath, "i)" option.run.rom "\.(" filter ")$" )
		if ( romPath != "" ) {
			return romPath
		}
	}
	filter := nvl(option.run.filter,filter)
	romPath := extractRomPath( imageDirPath, filter, "m3u" )
	if ( romPath != "" )
	  return romPath
	romPath := extractRomPath( imageDirPath, filter, "chd" )
	if ( romPath != "" )
	  return romPath
	romPath := extractRomPath( imageDirPath, filter, "cue" )
	if ( romPath != "" )
	  return romPath
  return FileUtil.getFile( imageDirPath, "i).*\.(" filter ")$" )
}

extractRomPath( dir, filter, extension ) {
	if InStr(filter, extension) {
	  romPath := FileUtil.getFile( dir, "i).*\." extension "$" )
	  if ( romPath != "" ) {
	  	if InStr(filter,"m3u")
	  	  readM3U( romPath )
	    return romPath
	  }
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
	WinWait, ahk_class RetroArch ahk_exe retroarch.exe,, 60
	IfWinExist
	{
	  activateEmulator()
	}
}

activateEmulator( delay:="" ) {
	WinActivate, ahk_class RetroArch ahk_exe retroarch.exe,, 60
	if ( delay != "" && delay > 0 ) {
		Sleep %delay%
	}
}

setConfig( core, option ) {

	config := {}

  setDefaultConfig( config, option )
  fn := Func( "setCoreConfig" )
  if( IsFunc(fn) ) {
  	fn.( config, option )
  }
  writeConfig( getPathCoreConfig(core), config )

  config.core := nvl( option.run.core, core )

  debug( ">> FROM option`n" JSON.dump(option) )
  debug( ">> TO config`n" JSON.dump(config) )
  return config

}

getPathCoreConfig( core ) {

  map := ({
  (join,
    "mednafen_saturn_libretro" : "Beetle Saturn"
    "4do_libretro"             : "4DO"
    "bluemsx_libretro"         : "blueMSX"
    "nekop2_libretro"          : "Neko Project II"
    "np2kai_libretro"          : "Neko Project II kai"
  )})
  trgCore := map[core]

  if( trgCore == "" ) {
	  trgCore := RegExReplace( core, "i)_libretro", "" )
	  StringUpper, trgCore, trgCore
  }

	dir  := EMUL_ROOT "\config\" trgCore
	path := dir "\" trgCore ".cfg"
	FileUtil.makeDir( dir )
	return path

}

writeConfig( fileConfig, config ) {
	buffer := ""
	for key, val in config {
		buffer .= key " = """ val """`n"
	}
	FileUtil.delete( fileConfig )
	FileAppend, % buffer, % fileConfig
}

setDefaultConfig( config, option ) {

	config.cache_directory            := FileUtil.getHomeDir() "\retroarch"
	config.rewind_enable              := nvl( option.run.rewind, "false" )
	config.video_driver               := nvl( option.run.videoDriver, "gl" )
	config.video_shader               := nvl( option.run.videoShader, "\ntsc\ntsc-320px-svideo-gauss-scanline" )
	config.systemfiles_in_content_dir := nvl( option.systemfiles_in_content_dir, "false" )
  setVideoShader( config )
  FileUtil.makeDir( config.cache_directory )

  config.input_enable_hotkey       := "menu"
  config.input_reset               := "h"
  config.input_disk_eject_toggle   := "slash"
  config.input_disk_next           := "period"
  config.input_disk_prev           := "comma"
  config.input_toggle_fast_forward := "space"
  config.input_toggle_fullscreen   := "f"

}

setVideoShader( config ) {
	if ( config.video_driver == "gl" ) {
		config.video_shader := "shaders_glsl\" config.video_shader ".glslp"
	} else {
		config.video_shader := "shaders_slang\" config.video_shader ".slangp"
	}
	config.video_shader := FileUtil.normalizePath( config.video_shader )
}