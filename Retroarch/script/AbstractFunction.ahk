#NoEnv
#include %A_ScriptDir%\..\ZZ_Library\Include.ahk

global EMUL_ROOT     := A_ScriptDir "\1.8.4"
global diskContainer := new DiskContainer()

runEmulator( imageFile, config, appendCommand="", callback="", appendImageFile="" ) {

	debug( "imageFile : " imageFile           )
	debug( "core      : " config.core         )
	debug( "shader    : " config.video_shader )

	emulator := wrap( EMUL_ROOT "\retroarch.exe" )
  core     := wrap( EMUL_ROOT "\cores\" config.core ".dll" )

	command := emulator " -L " core
	command .= " --set-shader " wrap( config.video_shader )
	if ( appendCommand != "" )
		command .= " " appendCommand
	if ( imageFile != "" )
		command .= " " wrap( imageFile )
	if ( appendImageFile != "" )
		command .= " " wrap( appendImageFile )

  debug( "command   : " command )
	Run, % command, % EMUL_ROOT,Hide, emulPid

	waitEmulator()
	IfWinExist
	{
		activateEmulator()
		if ( imageFile != "" && isFunc(callback) ) {
			Func(callback).( emulPid, core, imageFile, option )
		}
		waitCloseEmulator( emulPid )
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

nvl( val, defaultVal ) {
	if( val != "" )
		return val
	return defaultVal
}

getRomPath( imageDir, option, filter ) {
	if ( option.run.rom != "" ) {
		romPath := FileUtil.getFile( imageDir, "i)" option.run.rom "\.(" filter ")$" )
		if ( romPath != "" ) {
			return romPath
		}
	}
	filters := StrSplit( nvl(option.run.filter, filter), "|" )
	for key, val in filters {
		romPath := extractRomPath( imageDir, filter, val )
		if ( romPath != "" )
	  	return romPath		
	}
}

extractRomPath( dir, filter, extension ) {
	if InStr(filter, extension) {
	  romPath := FileUtil.getFile( dir, "i).*\." extension "$" )
	  if ( romPath != "" ) {
	  	if ( extension == "m3u" )
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

waitEmulator( delay:=10 ) {
	WinWait, ahk_class RetroArch ahk_exe retroarch.exe,, % delay
	IfWinExist
	{
	  activateEmulator()
	}
}

activateEmulator( delay:="" ) {
	WinActivate, ahk_class RetroArch ahk_exe retroarch.exe,, 10
	if ( delay != "" && delay > 0 ) {
		Sleep %delay%
	}
}

waitCloseEmulator( emulPid:="" ) {
	WinWaitClose, ahk_class RetroArch ahk_exe retroarch.exe,,
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

  config.core := nvl( nvl(option.core.common_core,option.run.core), core )

  debug( ">> FROM option`n" JSON.dump(option) )
  debug( ">> TO config`n" JSON.dump(config) )
  return config

}

getPathCoreConfig( core ) {

  map := ({
  (join,
    "4do_libretro"                    : "4DO"
    "bluemsx_libretro"                : "blueMSX"
    "fmsx_libretro"                   : "FMSX"
    "nekop2_libretro"                 : "Neko Project II"
    "np2kai_libretro"                 : "Neko Project II kai"
    "genesis_plus_gx_libretro"        : "Genesis Plus GX"
    "fceumm_libretro"                 : "FCEUmm"
    "mednafen_psx_libretro"           : "Beetle PSX"
    "mednafen_psx_hw_libretro"        : "Beetle PSX HW"
    "pcsx_rearmed_libretro"           : "PCSX-ReARMed"
    "yabause_libretro"                : "Yabause"
    "mednafen_saturn_libretro"        : "Beetle Saturn"
    "mupen64plus_next_libretro"       : "Mupen64Plus-Next GLES3"
    "mupen64plus_next_gles3_libretro" : "Mupen64Plus-Next OpenGL"
    "parallel_n64_libretro"           : "ParaLLEl N64"
    "flycast_libretro"                : "Flycast"
    "fbneo_libretro"                  : "FinalBurn Neo"
    "fbalpha_libretro"                : "FB Alpha"
    "fbalpha2012_libretro"            : "FB Alpha 2012"
    "fbalpha2012_cps1_libretro"       : "FB Alpha 2012 CPS-1"
    "fbalpha2012_cps2_libretro"       : "FB Alpha 2012 CPS-2"
    "fbalpha2012_neogeo_libretro"     : "FB Alpha 2012 NEOGEO"
    "mednafen_ngp_libretro"           : "Beetle NeoPop"
  	"dolphin_libretro"                : "dolphin-emu"
  	"play_libretro"                   : "Play!"
  	"gambatte_libretro"               : "GAMBATTE"
  	"mame_libretro"                   : "MAME"
  	"mame2000_libretro"               : "MAME 2000"
  	"mame2003_plus_libretro"          : "MAME 2003-Plus"
  	"mame2010_libretro"               : "MAME 2010"
  	"mame2014_libretro"               : "MAME 2014"
  	"mame2015_libretro"               : "MAME 2015"
  	"mame2016_libretro"               : "MAME 2016"
  )})
  trgCore := map[core]

  if( trgCore == "" ) {
	  trgCore := RegExReplace( core, "i)_libretro", "" )
	  StringUpper, trgCore, trgCore
  }

	dir  := EMUL_ROOT "\config\" trgCore
	path := dir "\" trgCore
	FileUtil.makeDir( dir )
	return path

}

writeConfig( config, imageFile ) {

  ROM_NAME := FileUtil.getName( imageFile, false )
  debug( "ROM_NAME : " ROM_NAME )

	fileConfig := getPathCoreConfig( config.core )
	config.core_options_path := fileConfig

	buffer := ""
	for key, val in config {
		debug( RegExReplace(key,"#{romname}",ROM_NAME) ":" val )
		buffer .= RegExReplace(key,"#{romname}",ROM_NAME) " = """ val """`n"
	}

	FileUtil.delete( fileConfig ".cfg")
	FileUtil.delete( fileConfig ".opt")
	FileAppend, % buffer, % fileConfig ".cfg"
	FileAppend, % buffer, % fileConfig ".opt"

}

setDefaultConfig( config, option ) {

	config.cache_directory            := FileUtil.getHomeDir() "\retroarch"
	config.video_driver               := nvl( option.run.videoDriver, "vulkan" )
	config.video_shader               := nvl( option.run.videoShader, "\\ntsc\\ntsc-320px-svideo-gauss-scanline" )
	config.systemfiles_in_content_dir := nvl( option.systemfiles_in_content_dir, "false" )

  config.input_enable_hotkey       := "menu"
  config.input_reset               := "h"
  config.input_disk_eject_toggle   := "slash"
  config.input_disk_next           := "period"
  config.input_disk_prev           := "comma"
  config.input_toggle_fast_forward := "space"
  config.input_toggle_fullscreen   := "f"

  for key, val in option.run
  	config[key] := val
  for key, val in option.core
  	config[key] := val

  setVideoShader( config )
  setResolution( config )

	FileUtil.makeDir( config.cache_directory )

}

setVideoShader( config ) {
	if ( config.video_driver == "gl" ) {
		config.video_shader := "shaders_glsl\" config.video_shader ".glslp"
	} else {
		config.video_shader := "shaders_slang\" config.video_shader ".slangp"
	}
	config.video_shader := FileUtil.normalizePath( config.video_shader )
}

setResolution( config ) {
  if( config.fullscreen_resolution == "" || config.fullscreen_resolution == "none" ) {
  	config.video_windowed_fullscreen := "true"
  } else {
  	width  := RegExReplace( config.fullscreen_resolution, "^(\d*?)x(\d*?)$", "$1" )
    height := RegExReplace( config.fullscreen_resolution, "^(\d*?)x(\d*?)$", "$2" )
    config.video_windowed_fullscreen := "false"
    config.video_fullscreen_x        := width
		config.video_fullscreen_y        := height
  }
}