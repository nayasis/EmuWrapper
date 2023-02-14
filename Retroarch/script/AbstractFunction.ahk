#NoEnv
#WinActivateForce
#include %A_ScriptDir%\..\ZZ_Library\Include.ahk

global EMUL_ROOT     := A_ScriptDir "\1.14.0"
global diskContainer := new DiskContainer()
global CFG_RA_APPEND := EMUL_ROOT "\retroarch.append.cfg"

makeLink()

makeLink() {
	for i,e in ["assets","autoconfig","bearer","cheats","config","cores","database","filters","iconengines","imageformats","info","layouts","overlays","platforms","recordings","saves","screenshots","shaders","states","styles","system","thumbnails","playlists","downloads", "logs"] {
		src := A_ScriptDir "\share\" e
		trg := EMUL_ROOT "\" e
		if(FileUtil.isSymlink(trg))
			continue
		FileUtil.makeLink(src, trg, true)
	}
}

runEmulator(imageFile, config, appendCommand="", callback="", appendImageFile="") {

	debug( "imageFile : " imageFile           )
	debug( "core      : " config.core         )
	debug( "shader    : " config.video_shader )

	emulator := wrap( EMUL_ROOT "\retroarch.exe" )
  core     := wrap( EMUL_ROOT "\cores\" config.core ".dll" )

	command := emulator " -L " core
	command .= " --appendconfig " wrap(CFG_RA_APPEND)
	command .= " --set-shader " wrap(config.video_shader)
	if( appendCommand != "" )
		command .= " " appendCommand
	if( imageFile != "" )
		command .= " " wrap( imageFile )
	if( appendImageFile != "" )
		command .= " " wrap( appendImageFile )

  debug( "command   : " command )
	Run, % command, % EMUL_ROOT, Hide, emulPid

	waitEmulator()
	IfWinExist
	{
		if ( imageFile != "" && isFunc(callback) ) {
			Func(callback).( emulPid, core, imageFile, option )
		}
		waitCloseEmulator( emulPid )
	}

}

getOption(imageDir) {
	setAppendConfig(imageDir)
	dirConf := imageDir "\_EL_CONFIG"
	IfExist %dirConf%\option\option.json
	{
		FileRead, jsonText, %dirConf%\option\option.json
		option := JSON.load( jsonText )
	} else {
		option := {}
	}
	return flattenJson(option)
}

flattenJson(jsonObj) {
	res := {}
	for i, obj in jsonObj {
		for key, val in obj {
			res[key] := val
		}
	}
	return res
}

setAppendConfig(imageDir) {
	dirRoot  := imageDir "\_EL_CONFIG\save\ra"
	dirSave  := dirRoot "\save"
	dirState := dirRoot "\states"

	FileUtil.makeDir(dirSave)
	FileUtil.makeDir(dirState)

	cfg := "savefile_directory = " wrap(dirSave) "`n"
	cfg .= "savestate_directory = " wrap(dirState) "`n"
	FileUtil.write(CFG_RA_APPEND, cfg)
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

getRomPath( imageDir, option, filter, excludeBios=false ) {
	if ( option.rom != "" ) {
		romPath := FileUtil.getFile( imageDir, "i)" option.rom "\.(" filter ")$" )
		if ( romPath != "" ) {
			return romPath
		}
	}
	filters := StrSplit( nvl(option.filter, filter), "|" )
	for key, val in filters {
		romPath := extractRomPath( imageDir, filter, val )
		if ( romPath != "" ) {
			if( excludeBios == false ) {
				return romPath		
			} else {
				if( Instr("neogeo|neocd",FileUtil.getName(romPath,false)) ) {
					continue
				} else {
					return romPath
				}
			}
	  	
		}
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

waitEmulator(delay:=15) {
	WinWait, ahk_class RetroArch ahk_exe retroarch.exe,, % delay
}

activateEmulator(delay:="") {
	loop, 50
	{
		WinActivate, ahk_class RetroArch ahk_exe retroarch.exe
		; debug( ">> activate emulator ... " A_Index )
		sleep 20
	}
	if ( delay != "" && delay > 0 ) {
		Sleep %delay%
	}
}

waitCloseEmulator(emulPid:="") {
	WinWaitClose, ahk_class RetroArch ahk_exe retroarch.exe,,
	if( emulPid != "" )
	  Process, WaitClose, emulPid
}

setConfig(defaultCore, option, log:=false) {

	config := {}
  for key, val in option
  	config[key] := val

  config.core := nvl(option.core, defaultCore)
  setDefaultConfig(config, option)

  fn := Func("setCoreConfig")
  if( IsFunc(fn) ) {
  	fn.(config, option)
  }

  ; overwrite option
  if(option.option_overwrite != "") {
  	overwrite := toMapFromProperties(option.option_overwrite)
  	; if(log)
  	; 	debug( ">> overwrite option`n" JSON.dump(overwrite) )
		for key, val in overwrite
			config[key] := val
  }

  if(log) {
	  debug( ">> FROM option`n" JSON.dump(option) )
	  debug( ">> TO config`n" JSON.dump(config) )
  }
  return config

}

getCoreName(core) {
	map := ({
	(join,
	  "4do_libretro"                    : "4DO"
	  "bluemsx_libretro"                : "blueMSX"
	  "fmsx_libretro"                   : "FMSX"
	  "nekop2_libretro"                 : "Neko Project II"
	  "np2kai_libretro"                 : "Neko Project II kai"
	  "genesis_plus_gx_libretro"        : "Genesis Plus GX"
	  "picodrive_libretro"              : "PicoDrive"
	  "fceumm_libretro"                 : "FCEUmm"
	  "mednafen_pce_fast_libretro"      : "Beetle PCE Fast"
	  "mednafen_supergrafx_libretro"    : "Beetle SuperGrafx"
	  "mednafen_psx_libretro"           : "Beetle PSX"
	  "mednafen_psx_hw_libretro"        : "Beetle PSX HW"
	  "pcsx_rearmed_libretro"           : "PCSX-ReARMed"
	  "pcsx2_libretro"                  : "LRPS2 (alpha)"
	  "yabause_libretro"                : "Yabause"
	  "yabasanshiro_libretro"           : "Yabasanshiro"
	  "mesen_libretro"                  : "Mesen"
	  "mednafen_saturn_libretro"        : "Beetle Saturn"
	  "mupen64plus_next_libretro"       : "Mupen64Plus-Next"
	  "mupen64plus_next_gles3_libretro" : "Mupen64Plus-Next GLES3"
	  "parallel_n64_libretro"           : "Parallel N64"
	  "flycast_libretro"                : "Flycast"
	  "fbneo_libretro"                  : "FinalBurn Neo"
	  "fbalpha_libretro"                : "FB Alpha"
	  "fbalpha2012_libretro"            : "FB Alpha 2012"
	  "fbalpha2012_cps1_libretro"       : "FB Alpha 2012 CPS-1"
	  "fbalpha2012_cps2_libretro"       : "FB Alpha 2012 CPS-2"
	  "fbalpha2012_cps3_libretro"       : "FB Alpha 2012 CPS-2"
	  "fbalpha2012_neogeo_libretro"     : "FB Alpha 2012 Neo Geo"
	  "mednafen_ngp_libretro"           : "Beetle NeoPop"
	  "mednafen_wswan_libretro"         : "Beetle WonderSwan"
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
		"dosbox_pure_libretro"            : "DOSBox-pure"
		"dosbox_svn_libretro"             : "DOSBox-SVN"
		"dosbox_core_libretro"            : "DOSBox-core"
	)})
  coreName := map[core]
  if( coreName == "" ) {
	  coreName := RegExReplace( core, "i)_libretro", "" )
	  StringUpper, coreName, coreName
  }
  return coreName
}

writeConfig(config, imageFile="") {

	; debug( ">> config`n" JSON.dump(config) )
  romName := FileUtil.getName(imageFile, false)
  debug( ">> romName : " romName )

  coreName  := getCoreName(config.core)

	; write remap
	remap := ""
	opt   := ""
	for key, val in config {
		if( RegExMatch(key, "i)^input_libretro_device_p(\d)$") || RegExMatch(key, "i)^input_player(\d)_analog_dpad_mode$") ) {
			remap .= key " = " wrap(val) "`n"
		} else {
			opt   .= RegExReplace(key,"#{romname}",romName) " = " wrap(val) "`n"
		}
	}

  ; debug( ">> remap`n" remap)

	configDir := EMUL_ROOT "\config\" coreName
	FileUtil.makeDir(configDir)		
	FileUtil.write( configDir "\" coreName ".cfg", opt )
	FileUtil.write( configDir "\" coreName ".opt", opt )

	remapDir := EMUL_ROOT "\config\remaps\" coreName
	FileUtil.makeDir(remapDir)
	FileUtil.write(EMUL_ROOT "\config\remaps\" coreName "\" coreName ".rmp", remap)

}

toMapFromProperties( properties ) {
	map := {}
	Loop, parse, properties, `n
	{
		words := StrSplit( A_LoopField, "=" )
		key   := Trim(words[1])
		val   := Trim(words[2])
		val   := RegExReplace( val, "^""", "" )
		val   := RegExReplace( val, """$", "" )
    map[key] := val
	}
	return map
}

setDefaultConfig( config, option ) {

	config.cache_directory            := FileUtil.getHomeDir() "\retroarch"
	config.video_driver               := nvl( option.video_driver, "vulkan" )
	config.video_shader               := nvl( option.video_shader, "\\ntsc\\ntsc-320px-svideo-gauss-scanline" )
	config.systemfiles_in_content_dir := nvl( option.systemfiles_in_content_dir, "false" )

  config.input_enable_hotkey       := "menu"
  config.input_reset               := "h"
  config.input_disk_eject_toggle   := "slash"
  config.input_disk_next           := "period"
  config.input_disk_prev           := "comma"
  config.input_toggle_fast_forward := "space"
  config.input_toggle_fullscreen   := "f"

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
	config.video_shader := FileUtil.normalizePath(config.video_shader)
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