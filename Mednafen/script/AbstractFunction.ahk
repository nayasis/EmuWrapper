#NoEnv
#include %A_ScriptDir%\..\ZZ_Library\Include.ahk

global EMUL_ROOT     := A_ScriptDir "\1.24.3"
global diskContainer := new DiskContainer()

runEmulator( imageFile, config, appendCommand="", callback="" ) {

	debug( "imageFile : " imageFile           )
	debug( "core      : " config.core         )
	debug( "shader    : " config.video_shader )

	emulator := wrap( EMUL_ROOT "\mednafen.exe" )
  
  command := emulator
  ; if( config.core != "" )
    ; command .= " -force_module " config.core
	if ( appendCommand != "" )
		command .= " " appendCommand
	if ( imageFile != "" )
		command .= " " wrap( imageFile )

  debug( "command   : " command )
	Run, % command, % EMUL_ROOT,Hide, emulPid

	waitEmulator()
	IfWinExist
	{
		activateEmulator()
		if ( imageFile != "" && isFunc(callback) ) {
			Func(callback).( emulPid, core, imageFile, option )
		}
		closeEmulator( emulPid )
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
	WinWait, ahk_class SDL_app ahk_exe mednafen.exe,, 60
	IfWinExist
	{
	  activateEmulator()
	}
}

activateEmulator( delay:="" ) {
	WinActivate, ahk_class SDL_app ahk_exe mednafen.exe,, 60
	if ( delay != "" && delay > 0 ) {
		Sleep %delay%
	}
}

closeEmulator( emulPid:="" ) {
	WinWaitClose, ahk_class SDL_app ahk_exe mednafen.exe,, 60
	if( emulPid != "" )
	  Process, WaitClose, emulPid
}

setConfig( core, option ) {

	config := {}

  setDefaultConfig( config, option )
  fn := Func( "setCoreConfig" )
  if( IsFunc(fn) ) {
  	fn.( config, option )
  }
  config.core := nvl( option.run.core, core )

  writeConfig( getPathCoreConfig(config.core), config )

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
    "genesis_plus_gx_libretro" : "Genesis Plus GX"
    "fceumm_libretro"          : "FCEUmm"
    "mednafen_psx_libretro"    : "Beetle PSX"
    "mednafen_psx_hw_libretro" : "Beetle PSX HW"
    "pcsx_rearmed_libretro"    : "PCSX-ReARMed"
    "yabause_libretro"         : "Yabause"
    "mednafen_saturn_libretro" : "Beetle Saturn"
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

	overwrite := config._overwrite
	config._overwrite := ""

	debug( ">> Final config`n" JSON.dump(config) )

	config.core_options_path := fileConfig
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
	config.video_shader               := nvl( option.run.videoShader, "\\ntsc\\ntsc-320px-svideo-gauss-scanline" )
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

  for key, val in option.core {
  	config[key] := val
  }


}

setVideoShader( config ) {
	if ( config.video_driver == "gl" ) {
		config.video_shader := "shaders_glsl\" config.video_shader ".glslp"
	} else {
		config.video_shader := "shaders_slang\" config.video_shader ".slangp"
	}
	config.video_shader := FileUtil.normalizePath( config.video_shader )
}