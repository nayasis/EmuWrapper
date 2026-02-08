#Requires AutoHotkey >=2.0
#Include "%A_ScriptDir%\..\ZZ_Library\Include.ahk"
#Include "%A_ScriptDir%\..\ZZ_Library\EmulCommon.ahk"

; https://wiki.mamedev.org/index.php/Driver:Apple_II

global EMUL_ROOT := A_ScriptDir "\0.276"
global BIOS_ROOT := "\\NAS2\emul\image\Mame"
global emulPid := ""
global option
global fddContainer

imageDir := A_Args.Length > 0 ? A_Args[1] : ""
debug("Apple2.ahk start")
; imageDir := "\\NAS2\emul\image\Apple2\Action\Karateka"
imageDir := "\\NAS2\emul\image\Apple2\Karateka (broderbund)(en)"
; imageDir := "\\NAS2\emul\image\Apple2\RPG-Times of Lore (en)"
; imageDir := "\\NAS2\emul\image\Apple2\Wings of Fury (en)"
; imageDir := "\\NAS2\emul\image\Apple2\Bard's Tale III - The Thief of Fate (interplay)(en)\"
; imageDir := "\\NAS2\emul\image\Apple2\Ultima V - Warriors of Destiny"
; imageDir := "\\NAS2\emul\image\Apple2\King Quest II - Romancing The Throne (en)"
; imageDir := "\\NAS2\emul\image\Apple2\Deathlord"
;imageDir := "\\NAS2\emul\image\Apple2\Star Rank Boxing II (gamestar)(en)"

fddContainer := DiskContainer(imageDir, "i).*\.(dsk|nib|wozs)$")
fddContainer.initSlot(2)

romPath := ""
romPath .= BIOS_ROOT "\chd;"
romPath .= BIOS_ROOT "\bios;"
romPath .= BIOS_ROOT "\rom;"

optionMame := ""
optionMame .= " -hlsl_enable"
optionMame .= " -waitvsync"
optionMame .= " -rewind"
optionMame .= " -skip_gameinfo"
; optionMame .= " -no_lag"
optionMame .= " -priority 1"
; optionMame .= " -midiout ""Microsoft MIDI Mapper (default)"""
; optionMame .= " -gamma 0.80"

; optionMame .= " -screen ""\\.\DISPLAY1"""

; optionMame .= " -video opengl"
; optionMame .= " -gl_glsl"
; optionMame .= " -gl_glsl_filter 1"
; optionMame .= " -glsl_shader_mame1"
; optionMame .= " -glsl_shader_screen1"

; optionMame .= " -video d3d"
; optionMame .= " -filter 0"
; optionMame .= " -hlsl_enable 0"

option := getConfig(imageDir, fddContainer)
debug(">> here ??")

command := wrap(EMUL_ROOT "\mame.exe") " " optionMame " -rompath " wrap(romPath)
command .= option
debug(command)
Run(command, EMUL_ROOT, "Hide", &emulPid)

if (EnvGet("AHK_NO_WAIT") != "")
	ExitApp

waitEmulator()
noWait := (EnvGet("AHK_NO_WAIT") != "")
if WinExist("ahk_class MAME ahk_exe mame.exe") {
	if (noWait)
		ExitApp
	waitCloseEmulator(emulPid)
}

debug("end !")
ExitApp

waitEmulator(activate := true) {
	WinWait("ahk_class MAME ahk_exe mame.exe", , 10)
	if (activate) {
		if WinExist("ahk_class MAME ahk_exe mame.exe") {
			activateEmulator()
		}
	}
}

activateEmulator() {
	WinActivate("ahk_class MAME ahk_exe mame.exe")
}

waitCloseEmulator(emulPid := "") {
	WinWaitClose("ahk_class MAME ahk_exe mame.exe")
	if (emulPid != "")
		ProcessWaitClose(emulPid)
}

sendHotKey(key) {
	Send("{" key " down}")
	Sleep(20)
	Send("{" key " up}")
	Sleep(20)
}

^+PGUP:: { ; Insert Disk in Drive#1
	if GetKeyState("z", "P") ; Ctrl + Shift + Z + PgUp :: Remove Disk in Drive#1
		fddContainer.removeDisk("1", "removeDisk")
	else ; Ctrl + Shift + PgUp :: Insert Disk in Drive#1
		fddContainer.insertDisk("1", "insertDisk")
}

^+PGDN:: { ; Insert Disk in Drive#2
	if (option.core.fdd != "2")
		return
	if GetKeyState("z", "P") ; Ctrl + Shift + Z + PgDn :: Remove Disk in Drive#2
		fddContainer.removeDisk("2", "removeDisk")
	else ; Ctrl + Shift + PgDn :: Insert Disk in Drive#2
		fddContainer.insertDisk("2", "insertDisk")
}

^+Del:: { ; Reset
	activateEmulator()
	Send("{H down}{H up}")
}

^+Insert:: { ; Toggle Speed
	SendMode("Input")
	SendMode("Play")
	SetKeyDelay(50)
	Tray.showMessage("Toggle speed")
	activateEmulator()
	Send("{Blind}{ScrollLock down}")
	Send("{Blind}{ScrollLock up}")
	Send("{Blind}{Space down}")
	Send("{Blind}{Space up}")
	debug("end insert")
}

!Enter:: { ; Toggle FullScreen
	activateEmulator()
	Send("{f down}{f up}")
}

!F4:: { ; Close
	debug("Close !!")
	activateEmulator()
	Send("{P down}")
	Sleep(500)
	Send("{P up}")
	Sleep(500)
}

getConfig(imageDir, fddContainer) {
	dirBase := imageDir "\_EL_CONFIG"
	option := getOption(imageDir)
	if !option.Has("core")
		option.core := DotMap()

	if (option.core.fdd == "")
		option.core.fdd := "2"
	if (option.core.model == "")
		option.core.model := "apple2ee"
	if (option.core.video == "")
		option.core.video := "4"
	if (option.core.cpuType == "")
		option.core.cpuType := "0"
	if (option.core.bootupSpeed == "")
		option.core.bootupSpeed := "0"

	debug(">> option`n" . JSON.dump(option))

	; fullscreen
	if (option.core.full_screen != "true") {
		; config .= " -no-full-screen"
	}

	if (option.core.card_vidHD == "true") {
		; IniWrite(21, fileIni, "Configuration\Slot 3", "Card type")
	}

	; model
	config := ""
	config .= " " option.core.model

	; sound
	if (option.core.sound_card == "mocking_board" || option.core.sound_card == "") {
		; config .= " -sl4 mockingboard"
		; config .= " -sl5 mockingboard"
	} else if (option.core.sound_card == "phasor") {
		config .= " -sl4 phasor"
	} else if (option.core.sound_card == "sam_dac") {
		config .= " -sl5 sam"
	}

	; fdd
	diskCnt := fddContainer.size()
	if (option.core.fdd_cnt == "")
		option.core.fdd_cnt := diskCnt
	fddCnt := Min(option.core.fdd_cnt * 1, diskCnt)
	debug(">> fddcnt  : " option.core.fdd_cnt)
	debug(">> diskCnt : " diskCnt)
	for i in range(1, Min(fddCnt, diskCnt) + 1) {
		config .= " -flop" i " " wrap(fddContainer.getFile(i))
	}
	if (fddCnt >= 3) {
		config .= " -sl5 diskiing"
	}

	; hdd
	hdds := FileUtil.getFiles(imageDir, "i).*\.(po)$")
	if (hdds.Length >= 1)
		config .= " -sl7 cffa2"
	for i, disk in hdds {
		config .= " -hard" i " " wrap(disk)
		if (i >= 2)
			break
	}

	if (option.core.joystick == "") {
		config .= " -gameio joy"
	}

	config .= " -sl3 midi"
	config .= " -midiout default"

	setMameConfig(option, fddContainer)
	return config
}

setMameConfig(option, fddContainer) {
	cfgFile := EMUL_ROOT "\cfg\apple2ee.cfg"
	if (!FileUtil.exist(cfgFile)) {
		cfgText := "
(
<?xml version="1.0"?>
<mameconfig version="10">
    <system name="apple2ee">
        <image_directories>
            <device instance="cassette" directory="" />
        </image_directories>
        <input>
            <keyboard tag=":" enabled="1" />
            <port tag=":a2_config" type="CONFIG" mask="7"  defvalue="0" value="4" />
            <port tag=":a2_config" type="CONFIG" mask="16" defvalue="0" value="0" />
            <port tag=":a2_config" type="CONFIG" mask="32" defvalue="0" value="0" />
        </input>
        <ui_warnings launched="1664897174" warned="1664896947">
            <feature device="votrax" type="sound" status="imperfect" />
        </ui_warnings>
    </system>
</mameconfig>
)"
		FileUtil.write(cfgFile, cfgText)
	}

	cfgXml := FileUtil.readXml(cfgFile)
	nodeInput := cfgXml.selectSingleNode("/mameconfig/system/input")
	nodeImage := cfgXml.selectSingleNode("/mameconfig/system/image_directories")

	; Video
	node := nodeInput.selectSingleNode("/mameconfig/system/input/port[contains(@tag,':a2_config') and contains(@mask,'7')]")
	if (node == "") {
		node := cfgXml.addChild("/mameconfig/system/input", "e", "port")
		cfgXml.setAtt(node, {tag:":a2_config", type:"CONFIG", mask:"7", defvalue:"0"})
	}
	node.setAttribute("value", option.core.video)

	; Cpu Type
	node := nodeInput.selectSingleNode("/mameconfig/system/input/port[contains(@tag,':a2_config') and contains(@mask,'16')]")
	if (node == "") {
		node := cfgXml.addChild("/mameconfig/system/input", "e", "port")
		cfgXml.setAtt(node, {tag:":a2_config", type:"CONFIG", mask:"16", defvalue:"0"})
	}
	node.setAttribute("value", option.core.cpuType)

	; Bootup Speed
	node := nodeInput.selectSingleNode("/mameconfig/system/input/port[contains(@tag,':a2_config') and contains(@mask,'32')]")
	if (node == "") {
		node := cfgXml.addChild("/mameconfig/system/input", "e", "port")
		cfgXml.setAtt(node, {tag:":a2_config", type:"CONFIG", mask:"32", defvalue:"0"})
	}
	node.setAttribute("value", option.core.bootupSpeed)

	cfgXml.save(cfgFile)
}
