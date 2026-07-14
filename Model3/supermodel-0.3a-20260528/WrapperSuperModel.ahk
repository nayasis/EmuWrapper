#Include "d:\app\emulator\ZZ_Library\Include.ahk"

emulatorPid := ""
imageDir := A_Args.Length > 0 ? A_Args[1] : ""
;imageDir := "\\NAS2\emul\image\Model3\Daytona 2"
;imageDir := "\\NAS2\emul\image\Model3\dayto2pe"
;imageDir := "\\NAS2\emul\image\Model3\Scud"

; option.json example: imageDir "\_EL_CONFIG\option\option.json"
; {
;   "run": {
;     "rom": "daytona2",
;     "configInputs": false,
;     "printInputs": false
;   },
;   "system": {
;     "fullscreen": true,
;     "showFps": false,
;     "throttle": true,
;     "multiThreaded": true,
;     "ppcFrequency": 50
;   },
;   "video": {
;     "width": 1920,
;     "height": 1080,
;     "wideScreen": false,
;     "stretch": false,
;     "new3dEngine": true,
;     "quadRendering": false,
;     "wideBackground": false,
;     "supersampling": 1,
;     "crtColors": 0,
;     "upscaleMode": 2
;   },
;   "audio": {
;     "soundVolume": 100,
;     "musicVolume": 100,
;     "emulateSound": true,
;     "emulateDsb": true,
;     "flipStereo": false,
;     "legacySoundDsp": false
;   },
;   "input": {
;     "system": "xinput",
;     "forceFeedback": true,
;     "mapping": {
;       "Steering": "JOY1_XAXIS",
;       "Accelerator": "JOY1_RZAXIS",
;       "Brake": "JOY1_ZAXIS",
;       "Start1": "KEY_1,JOY1_BUTTON9"
;     }
;   },
;   "network": {
;     "enabled": false,
;     "simulate": true,
;     "portIn": 1970,
;     "portOut": 1971,
;     "addressOut": "127.0.0.1"
;   },
;   "supermodel": {
;     "InputCoin1": "KEY_3,JOY1_BUTTON10"
;   }
; }

option := getOption(imageDir)
debug(">> option`n" . JSON.stringify(option))
setConfig(option)

romPath := getExecutableRom( imageDir )
debug("romPath : " romPath)

if ( romPath != "" ) {
	cmd := "Supermodel.exe " wrap(romPath) getCommandOption(option)
	debug( cmd )
	RunWait(cmd, , , &emulatorPid)
} else {
	Run("Supermodel.exe", , , &emulatorPid)
}

ExitApp()


getExecutableRom(imageDir) {
	romName := ""
	option := getOption(imageDir)
	if (option.has("run") && option.run.has("rom"))
		romName := FileUtil.getFile(imageDir, option.run.rom ".*")
	if(romName != "")
		return romName
	else
		return FileUtil.getFile(imageDir, ".*\.(zip|7z)$")
}

getOption(imageDir) {
	optionFile := imageDir "\_EL_CONFIG\option\option.json"
	if FileExist(optionFile) {
		jsonText := FileRead(optionFile)
		return JSON.parse(jsonText)
	}
	return JSON.Obj()
}

getCommandOption(option) {
	command := ""
	if (option.has("input") && option.input.has("system") && option.input.system != "")
		command .= " -input-system=" option.input.system
	if (option.has("run")) {
		if (option.run.has("configInputs") && JSON.toBoolean(option.run.configInputs))
			command .= " -config-inputs"
		if (option.run.has("printInputs") && JSON.toBoolean(option.run.printInputs))
			command .= " -print-inputs"
	}
	return command
}

setConfig(option) {
	file := A_ScriptDir "\Config\Supermodel.ini"
	ensureDefaultConfig(file)

	; Preserve previous wrapper defaults unless option.json overrides them.
	writeIniDefault(file, "Global", "FullScreen", 1)
	writeIniDefault(file, "Global", "XResolution", 1920)
	writeIniDefault(file, "Global", "YResolution", 1080)

	writeOptionGroup(file, "Global", option, "system", Map(
		"fullscreen", "FullScreen",
		"showFps", "ShowFrameRate",
		"throttle", "Throttle",
		"multiThreaded", "MultiThreaded",
		"ppcFrequency", "PowerPCFrequency",
	))
	writeOptionGroup(file, "Global", option, "video", Map(
		"width", "XResolution",
		"height", "YResolution",
		"xResolution", "XResolution",
		"yResolution", "YResolution",
		"wideScreen", "WideScreen",
		"stretch", "Stretch",
		"new3dEngine", "New3DEngine",
		"quadRendering", "QuadRendering",
		"wideBackground", "WideBackground",
		"supersampling", "Supersampling",
		"crtColors", "CRTcolors",
		"upscaleMode", "UpscaleMode",
	))
	writeOptionGroup(file, "Global", option, "audio", Map(
		"soundVolume", "SoundVolume",
		"musicVolume", "MusicVolume",
		"emulateSound", "EmulateSound",
		"emulateDsb", "EmulateDSB",
		"flipStereo", "FlipStereo",
		"legacySoundDsp", "LegacySoundDSP",
	))
	writeOptionGroup(file, "Global", option, "input", Map(
		"forceFeedback", "ForceFeedback",
		"autoTrigger", "InputAutoTrigger",
		"autoTrigger2", "InputAutoTrigger2",
		"directInputConstForceMax", "DirectInputConstForceMax",
		"directInputSelfCenterMax", "DirectInputSelfCenterMax",
		"directInputFrictionMax", "DirectInputFrictionMax",
		"directInputVibrateMax", "DirectInputVibrateMax",
		"xInputConstForceThreshold", "XInputConstForceThreshold",
		"xInputConstForceMax", "XInputConstForceMax",
		"xInputVibrateMax", "XInputVibrateMax",
	))
	writeOptionGroup(file, "Global", option, "network", Map(
		"enabled", "Network",
		"simulate", "SimulateNet",
		"portIn", "PortIn",
		"portOut", "PortOut",
		"addressOut", "AddressOut",
	))

	if (option.has("input") && option.input.has("mapping"))
		writeInputMappings(file, option.input.mapping)
	if (option.has("supermodel"))
		writeRawSettings(file, "Global", option.supermodel)

	debug(">> Supermodel.ini`n" . JSON.stringify(FileUtil.readIni(file, "Global")))
}

ensureDefaultConfig(file) {
	if FileExist(file)
		return
	defaultFile := A_ScriptDir "\Config_\Supermodel.ini"
	if FileExist(defaultFile)
		FileCopy(defaultFile, file, true)
}

writeIniDefault(file, section, key, value) {
	if (FileUtil.readIni(file, section, key, "") == "")
		FileUtil.writeIni(file, section, key, value)
}

writeOptionGroup(file, section, option, groupName, mapping) {
	if !option.has(groupName)
		return
	group := option.%groupName%
	for sourceKey, targetKey in mapping {
		if group.has(sourceKey)
			writeSetting(file, section, targetKey, group.%sourceKey%)
	}
}

writeInputMappings(file, mapping) {
	for key, value in mapping {
		if (SubStr(key, 1, 5) == "Input")
			writeSetting(file, "Global", key, value)
		else
			writeSetting(file, "Global", "Input" key, value)
	}
}

writeRawSettings(file, section, settings) {
	for key, value in settings {
		writeSetting(file, section, key, value)
	}
}

writeSetting(file, section, key, value) {
	if (value == "")
		return
	FileUtil.writeIni(file, section, key, toIniValue(value))
}

toIniValue(value) {
	valueType := Type(value)
	if (valueType == "Integer" || valueType == "Float")
		return value
	if (valueType == "String") {
		if (value == "true" || value == "false")
			return JSON.toBoolean(value) ? 1 : 0
		return wrap(value)
	}
	return JSON.toBoolean(value) ? 1 : 0
}
