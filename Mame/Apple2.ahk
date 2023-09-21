#InstallKeybdHook
#NoEnv
#include c:\app\emulator\ZZ_Library\Include.ahk
#include c:\app\emulator\ZZ_Library\EmulCommon.ahk

;https://wiki.mamedev.org/index.php/Driver:Apple_II

global EMUL_ROOT := A_ScriptDir "\0.251"
global BIOS_ROOT := "\\NAS2\emul\image\Mame"
global emulPid   := ""

imageDir := %0%
; imageDir := "\\NAS2\emul\image\Apple2\Action\Karateka"
; imageDir := "\\NAS2\emul\image\Apple2\RPG-Times of Lore (en)"
; imageDir := "\\NAS2\emul\image\Apple2\Wings of Fury (en)"
; imageDir := "\\NAS2\emul\image\Apple2\Bard's Tale III - The Thief of Fate (interplay)(en)\"
; imageDir := "\\NAS2\emul\image\Apple2\Ultima V - Warriors of Destiny"
imageDir := "\\NAS2\emul\image\Apple2\King Quest II - Romancing The Throne (en)"

fddContainer := new DiskContainer( imageDir, "i).*\.(dsk)$" )
fddContainer.initSlot(2)

romPath .= BIOS_ROOT "\chd;"
romPath .= BIOS_ROOT "\bios;"
romPath .= BIOS_ROOT "\rom;"

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
debug( command )
Run, % command, % EMUL_ROOT, hide, emulPid

waitEmulator()
IfWinExist
{
	waitCloseEmulator(emulPid)
}

debug( "end !")

ExitApp

waitEmulator(activate=true) {
	WinWait, ahk_class MAME ahk_exe mame.exe,, 10
	if(activate == true) {
		IfWinExist
		{
		  activateEmulator()
		}
	}
}

activateEmulator() {
	WinActivate, ahk_class MAME ahk_exe mame.exe,, 10
}

waitCloseEmulator( emulPid:="" ) {
	WinWaitClose, ahk_class MAME ahk_exe mame.exe,,
	if( emulPid != "" )
	  Process, WaitClose, emulPid
}

sendHotKey( key ) {
	Send {%key% down}
	Sleep 20
	Send {%key% up}
	Sleep 20
}

^+PGUP:: ; Insert Disk in Drive#1
  If GetKeyState( "z", "P" ) ; Ctrl + Shift + Z + PgUp :: Remove Disk in Drive#1
    fddContainer.removeDisk( "1", "removeDisk" )
  else ; Ctrl + Shift + PgUp :: Insert Disk in Drive#1
    fddContainer.insertDisk( "1", "insertDisk" )
  return

^+PGDN:: ; Insert Disk in Drive#2
  if( option.core.fdd != "2" )
    return
  If GetKeyState( "z", "P" ) ; Ctrl + Shift + Z + PgDn :: Remove Disk in Drive#2
    fddContainer.removeDisk( "2", "removeDisk" )
  else ; Ctrl + Shift + PgDn :: Insert Disk in Drive#2
    fddContainer.insertDisk( "2", "insertDisk" )
  
  return

^+Del:: ; Reset
	activateEmulator()
	Send {H Down} {H Up}
	return

^+Insert:: ; Toggle Speed
  SendMode, Input
  SendMode, Play ; Input
  SetKeyDelay, 50
	Tray.showMessage( "Toggle speed" )
	activateEmulator()
  Send {Blind}{ScrollLock down}
  Send {Blind}{ScrollLock up}
	Send {Blind}{Space down}
  Send {Blind}{Space up}
  debug("end insert")
	return

!Enter:: ;Toggle FullScreen
	activateEmulator()
	Send {f Down} {f Up}
	return

!F4:: ;Close
  debug( "Close !!" )
  ; SetKeyDelay, -1, 110
  activateEmulator()
  ; PostMessage,0x100, 80, , , ahk_class MAME
  SendRaw, {P down}
  Sleep, 500
  SendRaw, {P up}
  Sleep, 500
	return 

getConfig(imageDir, fddContainer) {

  dirBase := imageDir "\_EL_CONFIG"
  option  := getOption(imageDir)

  if(option.core == "")
  	option.core := {}
  if(option.core.fdd == "")
  	option.core.fdd := "2"
  if(option.core.model == "")
  	option.core.model := "apple2ee"
  if(option.core.video == "")
    option.core.video := "4"
  if(option.core.cpuType == "")
    option.core.cpuType := "0"
  if(option.core.bootupSpeed == "")
    option.core.bootupSpeed := "0"

  debug( ">> option`n" JSON.dump(option) )

  ; fullscreen
  if(option.core.full_screen != "true") {
    ; config .= " -no-full-screen"
  }

  if(option.core.card_vidHD == "true") {
    ; IniWrite, 21, % fileIni, Configuration\Slot 3, Card type
  }

  ; model
  config .= " " option.core.model

  ; video
  ; IniWrite, % option.core.video_mode, % fileIni, Configuration, Video Emulation

  ; sound
  if(option.core.sound_card == "mocking_board" || option.core.sound_card == "") {
  	; config .= " -sl4 mockingboard"
  	; config .= " -sl5 mockingboard"
  } else if(option.core.sound_card == "phasor") {
  	config .= " -sl4 phasor"
  } else if(option.core.sound_card == "sam_dac") {
  	config .= " -sl5 sam"
  }

  ; fdd
  diskCnt := fddContainer.size()
  fddCnt  := Min(option.core.fdd * 1,diskCnt)
  for i in range(1, Min(fddCnt,diskCnt) + 1) {
    ; debug("fdd index:" i)
    config .= " -flop"i " " wrap(fddContainer.getFile(i))
  }
  if(fddCnt >= 3) {
  	config .= " -sl5 diskiing"
  }

  ; hdd
  hdds  := FileUtil.getFiles(imageDir, "i).*\.(po)$")
  if(hdds.MaxIndex() >= 1)
    config .= " -sl7 cffa2"
  for i, disk in hdds {
    config .= " -hard" i " " wrap(disk)
    if(i >= 2)
      break
  }  

  if(option.core.joystick == "") {
    config .= " -gameio joy"
    ; paddles
    ; joyport
    ; gizmo
    ; https://wiki.mamedev.org/index.php/Driver:Apple_II
  }

  ; config .= " -sl3 midi ""Microsoft MIDI Mapper"""
  config .= " -sl3 midi"
  ; config .= " -sl3:midi:out ""Microsoft MIDI Mapper"""
  ; config .= " -sl3:midi:midiout mpu401"
  config .= " -midiout default"
  ; config .= " -midiout mpu401"
  ; config .= " -mdout mpu401"

  setMameConfig(option,fddContainer)
  
  return config

}

setMameConfig(option, fddContainer) {

  cfgFile := EMUL_ROOT "\cfg\apple2ee.cfg"

  if( ! FileUtil.exist(cfgFile) ) {
    cfgText =
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
)
    FileUtil.write(cfgFile,cfgText)
  }

  cfgXml    := FileUtil.readXml(cfgFile)
  nodeInput := cfgXml.selectSingleNode("/mameconfig/system/input")
  nodeImage := cfgXml.selectSingleNode("/mameconfig/system/image_directories")

  ; >> Video
  ; Color : 0
  ; Black & White : 1
  ; Green : 2
  ; Amber : 3
  ; Video-7 RGB : 4
  node := nodeInput.selectSingleNode("/mameconfig/system/input/port[contains(@tag,':a2_config') and contains(@mask,'7')]")
  if(node == "") {
    node := cfgXml.addChild("/mameconfig/system/input","e", "port")
    cfgXml.setAtt(node,{tag:":a2_config",type:"CONFIG",mask:"7",defvalue:"0"})
  }
  node.setAttribute("value", option.core.video)

  ; >> Cpu Type
  ; Standard      : 0
  ; 4 Mhz Zip-Chip: 16
  node := nodeInput.selectSingleNode("/mameconfig/system/input/port[contains(@tag,':a2_config') and contains(@mask,'16')]")
  if(node == "") {
    node := cfgXml.addChild("/mameconfig/system/input","e", "port")
    cfgXml.setAtt(node,{tag:":a2_config",type:"CONFIG",mask:"16",defvalue:"0"})
  }
  node.setAttribute("value", option.core.cpuType)

  ; >> Bootup Speed
  ; Standard : 0
  ; 4 Mhz    : 32
  node := nodeInput.selectSingleNode("/mameconfig/system/input/port[contains(@tag,':a2_config') and contains(@mask,'32')]")
  if(node == "") {
    node := cfgXml.addChild("/mameconfig/system/input","e", "port")
    cfgXml.setAtt(node,{tag:":a2_config",type:"CONFIG",mask:"32",defvalue:"0"})
  }
  node.setAttribute("value", option.core.bootupSpeed)

  ; >> set disk directory
  ; diskCnt := fddContainer.size()
  ; fddCnt  := Min(option.core.fdd * 1,diskCnt)
  ; for i in range(1, Min(fddCnt,diskCnt) + 1) {
  ;   instanceName := "floopydisk" i
  ;   node := nodeImage.selectSingleNode("/mameconfig/system/image_directories/device[contains(@tag,'" instanceName "')]")
  ;   if(node == "") {
  ;     node := cfgXml.addChild("/mameconfig/system/image_directories","e", "device")
  ;     cfgXml.setAtt(node,{instance:instanceName})
  ;   }
  ;   node.setAttribute("directory", FileUtil.getDir(fddContainer.getFile(i)))
  ; }

  cfgXml.save(cfgFile)

  ; debug(cfgXml.xml)
  
}