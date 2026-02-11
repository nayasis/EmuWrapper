#Requires AutoHotkey >=2.0
#WinActivateForce
#Include "..\..\ZZ_Library\Include.ahk"

global EMUL_ROOT := A_ScriptDir "\1.22"
global diskContainer
global CFG_RA_APPEND := EMUL_ROOT "\retroarch.append.cfg"
DetectHiddenWindows(true)

if (!FileUtil.hasSymlinkAuth()) {
	MsgBox("You must be granted to use [mklink]")
	ExitApp
}
makeLink()

;---

makeLink() {
	global EMUL_ROOT
	for i, e in ["assets", "autoconfig", "bearer", "cheats", "config", "cores", "database", "filters", "iconengines", "imageformats", "info", "layouts", "overlays", "platforms", "recordings", "saves", "screenshots", "shaders", "states", "styles", "system", "thumbnails", "playlists", "downloads", "logs"] {
		src := A_ScriptDir "\share\" e
		trg := EMUL_ROOT "\" e
		if (FileUtil.isSymlink(trg))
			continue
		FileUtil.makeLink(src, trg, true)
	}
}

runEmulator(imageFile, config, appendCommand := "", callback := "", appendImageFile := "") {
	global EMUL_ROOT, CFG_RA_APPEND
	debug("imageFile : " imageFile)
	debug("core      : " config.core)
	debug("shader    : " config.video_shader)

	emulator := wrap(EMUL_ROOT "\retroarch.exe")
	if (config.custom_core != "") {
		core := config.custom_core
	} else {
		core := EMUL_ROOT "\cores\" config.core ".dll"
	}

	command := emulator " -L " wrap(core)
	command .= " --appendconfig " wrap(CFG_RA_APPEND)
	command .= " --set-shader " wrap(config.video_shader)
	if (appendCommand != "")
		command .= " " appendCommand
	if (imageFile != "")
		command .= " " wrap(imageFile)
	if (appendImageFile != "")
		command .= " " wrap(appendImageFile)

	debug("command   : " command)
	emulPid := Run(command, EMUL_ROOT, "Hide")

	waitEmulator()
	if (WinExist("ahk_class RetroArch ahk_exe retroarch.exe")) {
		if (imageFile != "" && Type(callback) = "Func")
			callback.Call(emulPid, core, imageFile, option)
	}
	waitCloseEmulator()
}

getOption(imageDir) {
	dirConf := imageDir "\_EL_CONFIG"
	if (FileExist(dirConf "\option\option.json")) {
		jsonText := FileRead(dirConf "\option\option.json")
		option := flattenJson(JSON.parse(jsonText))
	} else {
		option := JSON.Obj()
	}
	if (Type(option) != "JSON.Obj")
		option := JSON.fromMap(option)
	option.rgui_browser_directory := imageDir
	option.custom_core := FileUtil.getFile(dirConf "\core", "i).*_libretro\.dll$")

	setAppendConfig(imageDir, option)
	return option
}

flattenJson(jsonObj) {
	res := JSON.Obj()
	for i, obj in jsonObj {
		for key, val in obj {
			res[key] := val
		}
	}
	return res
}

setAppendConfig(imageDir, option) {
	global EMUL_ROOT, CFG_RA_APPEND
	dirRoot := imageDir "\_EL_CONFIG\save\ra"
	dirSave := dirRoot "\save"
	dirState := dirRoot "\states"
	dirCheat := dirRoot "\cheats"

	FileUtil.makeDir(dirSave)
	FileUtil.makeDir(dirState)
	FileUtil.makeDir(dirCheat)

	cfg := "savestate_directory = " wrap(dirState) "`n"
	cfg .= "cheat_database_path = " wrap(dirCheat) "`n"
	if (option.core != "dolphin_libretro") {
		cfg .= "savefile_directory = " wrap(dirSave) "`n"
	} else {
		saveSrc := FileUtil.getFile(dirSave "\User\Wii\title\00010000", ".*", true)
		if (saveSrc != "" && FileUtil.isDir(saveSrc)) {
			saveTrg := EMUL_ROOT "\saves\User\Wii\title\00010000\" FileUtil.getName(saveSrc)
			FileUtil.makeLink(saveSrc, saveTrg, true)
		}
	}

	FileUtil.write(CFG_RA_APPEND, cfg)
}

getGameMeta(imageDirPath) {
	dirConf := imageDirPath "\_EL_CONFIG"
	if (FileExist(dirConf "\option\gameMeta.json")) {
		jsonText := FileRead(dirConf "\option\gameMeta.json")
		return JSON.parse(jsonText)
	}
	return {}
}

getRomPath(imageDir, option, filter, excludeBios := false) {
	if (option.rom != "") {
		romPath := FileUtil.getFile(imageDir, "i)" option.rom "\.(" filter ")$")
		if (romPath != "")
			return romPath
	}
	filters := StrSplit(nvl(option.filter, filter), "|")
	for key, val in filters {
		romPath := extractRomPath(imageDir, filter, val)
		if (romPath != "") {
			if (excludeBios == false) {
				return romPath
			} else {
				if (InStr("neogeo|neocd", FileUtil.getName(romPath, false)))
					continue
				else
					return romPath
			}
		}
	}
}

extractRomPath(dir, filter, extension) {
	if (InStr(filter, extension)) {
		romPath := FileUtil.getFile(dir, "i).*\." extension "$")
		if (romPath != "") {
			if (extension == "m3u")
				readM3U(romPath)
			return romPath
		}
	}
}

readM3U(path) {
	if (!IsObject(diskContainer))
		diskContainer := DiskContainer("")
	loop read, path {
		disc := Trim(A_LoopReadLine)
		if (disc == "")
			continue
		diskContainer.addPath(disc)
		diskContainer.slot[0] := 1
	}
}

waitEmulator(delay := 95) {
	WinWait("ahk_class RetroArch ahk_exe retroarch.exe", , delay)
}

activateEmulator(delay := "") {
	loop 50 {
		WinActivate("ahk_class RetroArch ahk_exe retroarch.exe")
		Sleep(20)
	}
	if (delay != "" && delay > 0)
		Sleep(delay)
}

waitCloseEmulator(emulPid := "") {
	WinWaitClose("ahk_class RetroArch ahk_exe retroarch.exe")
	if (emulPid != "")
		ProcessWaitClose(emulPid)
	ResolutionChanger.restore()
}

setConfig(defaultCore, option, log := false) {
	config := JSON.Obj()
	if (!IsObject(option))
		option := Map()
	optEnum := option
	try {
		for key, val in optEnum
			config[key] := val
	}

	config.core := nvl(option.core, defaultCore)
	setDefaultConfig(config, option)

	try {
		fn := Func("setCoreConfig")
		if (fn)
			fn.Call(config, option)
	}

	if (option.option_overwrite != "") {
		overwrite := toMapFromProperties(option.option_overwrite)
		for key, val in overwrite
			config[key] := val
	}

	if (log) {
		debug(">> FROM option`n" . JSON.stringify(option))
		debug(">> TO config`n" . JSON.stringify(config))
	}
	return config
}

getCoreName(core) {
	coreMap := Map()
	coreMap["4do_libretro"] := "4DO"
	coreMap["bluemsx_libretro"] := "blueMSX"
	coreMap["fmsx_libretro"] := "FMSX"
	coreMap["nekop2_libretro"] := "Neko Project II"
	coreMap["np2kai_libretro"] := "Neko Project II kai"
	coreMap["genesis_plus_gx_libretro"] := "Genesis Plus GX"
	coreMap["picodrive_libretro"] := "PicoDrive"
	coreMap["fceumm_libretro"] := "FCEUmm"
	coreMap["mednafen_pce_fast_libretro"] := "Beetle PCE Fast"
	coreMap["mednafen_supergrafx_libretro"] := "Beetle SuperGrafx"
	coreMap["mednafen_pcfx_libretro"] := "Beetle PC-FX"
	coreMap["mednafen_psx_libretro"] := "Beetle PSX"
	coreMap["mednafen_psx_hw_libretro"] := "Beetle PSX HW"
	coreMap["pcsx_rearmed_libretro"] := "PCSX-ReARMed"
	coreMap["pcsx2_libretro"] := "LRPS2"
	coreMap["yabause_libretro"] := "Yabause"
	coreMap["yabasanshiro_libretro"] := "Yabasanshiro"
	coreMap["mesen_libretro"] := "Mesen"
	coreMap["mednafen_saturn_libretro"] := "Beetle Saturn"
	coreMap["mupen64plus_next_libretro"] := "Mupen64Plus-Next"
	coreMap["mupen64plus_next_gles3_libretro"] := "Mupen64Plus-Next GLES3"
	coreMap["parallel_n64_libretro"] := "Parallel N64"
	coreMap["flycast_libretro"] := "Flycast"
	coreMap["fbneo_libretro"] := "FinalBurn Neo"
	coreMap["fbalpha_libretro"] := "FB Alpha"
	coreMap["fbalpha2012_libretro"] := "FB Alpha 2012"
	coreMap["fbalpha2012_cps1_libretro"] := "FB Alpha 2012 CPS-1"
	coreMap["fbalpha2012_cps2_libretro"] := "FB Alpha 2012 CPS-2"
	coreMap["fbalpha2012_cps3_libretro"] := "FB Alpha 2012 CPS-2"
	coreMap["fbalpha2012_neogeo_libretro"] := "FB Alpha 2012 Neo Geo"
	coreMap["mednafen_ngp_libretro"] := "Beetle NeoPop"
	coreMap["mednafen_wswan_libretro"] := "Beetle WonderSwan"
	coreMap["dolphin_libretro"] := "dolphin-emu"
	coreMap["play_libretro"] := "Play!"
	coreMap["gambatte_libretro"] := "GAMBATTE"
	coreMap["mame_libretro"] := "MAME"
	coreMap["mame2000_libretro"] := "MAME 2000"
	coreMap["mame2003_plus_libretro"] := "MAME 2003-Plus"
	coreMap["mame2010_libretro"] := "MAME 2010"
	coreMap["mame2014_libretro"] := "MAME 2014"
	coreMap["mame2015_libretro"] := "MAME 2015"
	coreMap["mame2016_libretro"] := "MAME 2016"
	coreMap["dosbox_pure_libretro"] := "DOSBox-pure"
	coreMap["dosbox_svn_libretro"] := "DOSBox-SVN"
	coreMap["dosbox_core_libretro"] := "DOSBox-core"
	coreMap["vice_x64sc_libretro"] := "VICE x64sc"
	coreMap["vice_x64_libretro"] := "VICE x64"
	coreMap["vice_x128_libretro"] := "VICE x128"
	coreMap["vice_xplus4_libretro"] := "VICE xplus4"
	coreMap["vice_xscpu64_libretro"] := "VICE xscpu64"
	coreMap["vice_xvic_libretro"] := "VICE xvic"
	coreName := coreMap.Has(core) ? coreMap[core] : ""
	if (coreName == "") {
		coreName := RegExReplace(core, "i)_libretro", "")
		coreName := StrUpper(coreName)
	}
	return coreName
}

writeConfig(config, imageFile := "") {
	global EMUL_ROOT
	debug(">> config`n" JSON.stringify(config))
	romName := FileUtil.getName(imageFile, false)
	debug(">> romName : " romName)

	coreName := getCoreName(config.core)

	remap := ""
	opt := ""
	for key, val in config {
		if (RegExMatch(key, "i)^input_libretro_device_p(\d)$") || RegExMatch(key, "i)^input_player(\d)_analog_dpad_mode$")) {
			remap .= key " = " wrap(val) "`n"
		} else {
			opt .= RegExReplace(key, "#{romname}", romName) " = " wrap(val) "`n"
		}
	}

	configDir := EMUL_ROOT "\config\" coreName
	FileUtil.write(configDir "\" coreName ".cfg", opt)
	FileUtil.write(configDir "\" coreName ".opt", opt)

	remapDir := EMUL_ROOT "\config\remaps\" coreName
	FileUtil.write(EMUL_ROOT "\config\remaps\" coreName "\" coreName ".rmp", remap)
}

toMapFromProperties(properties) {
	map := {}
	loop parse, properties, "`n" {
		words := StrSplit(A_LoopField, "=")
		key := Trim(words[1])
		val := Trim(words[2])
		val := RegExReplace(val, '^"', "")
		val := RegExReplace(val, '"$', "")
		map[key] := val
	}
	return map
}

setDefaultConfig(config, option) {
	config.cache_directory := FileUtil.getHomeDir() "\retroarch"
	config.video_driver := nvl(option.video_driver, "vulkan")
	config.video_shader := nvl(option.video_shader, "\\ntsc\\ntsc-320px-svideo-gauss-scanline")
	config.systemfiles_in_content_dir := nvl(option.systemfiles_in_content_dir, "false")
	config.input_overlay := nvl(option.input_overlay, "none")
	config.input_overlay_show_mouse_cursor := "false"
	config.input_enable_hotkey := "menu"
	config.input_reset := "h"
	config.input_disk_eject_toggle := "slash"
	config.input_disk_next := "period"
	config.input_disk_prev := "comma"
	config.input_toggle_fast_forward := "space"
	config.input_toggle_fullscreen := "f"

	setVideoShader(config)
	setResolution(config)

	FileUtil.makeDir(config.cache_directory)
}

setVideoShader(config) {
	debug(">> shader : " config.video_shader)
	if (config.video_driver == "gl") {
		config.video_shader := "shaders_glsl\" config.video_shader ".glslp"
	} else {
		config.video_shader := "shaders_slang\" config.video_shader ".slangp"
	}
	config.video_shader := FileUtil.normalizePath(config.video_shader)
}

setResolution(config) {
	if (A_ScreenWidth > 1920 && A_ScreenHeight > 1080) {
		ResolutionChanger.change(1920, 1080)
	}

	if (config.fullscreen_resolution == "" || config.fullscreen_resolution == "none") {
		config.video_windowed_fullscreen := "true"
	} else {
		width := RegExReplace(config.fullscreen_resolution, "^(\d*?)x(\d*?)$", "$1")
		height := RegExReplace(config.fullscreen_resolution, "^(\d*?)x(\d*?)$", "$2")
		config.video_windowed_fullscreen := "false"
		config.video_fullscreen_x := width
		config.video_fullscreen_y := height
	}
}
