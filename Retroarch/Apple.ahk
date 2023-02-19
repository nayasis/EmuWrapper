#NoEnv
#include %A_ScriptDir%\script\AbstractFunction.ahk

; https://wiki.mamedev.org/index.php/Driver:Apple_II

imageDir := %0%
; imageDir := "\\NAS2\emul\image\Apple2\Karateka"
; imageDir := "\\NAS2\emul\image\Apple2\RPG-Times of Lore (en)"
; imageDir := "\\NAS2\emul\image\Apple2\Ultima V - Warriors of Destiny"
; imageDir := "\\NAS2\emul\image\Apple2\Ultima III - Exodus (en)"
; imageDir := "\\NAS2\emul\image\Apple2\Action\Black Magic"
; imageDir := "\\NAS2\emul\image\Apple2\Space Rogue (en)"
; imageDir := "\\NAS2\emul\image\Apple2\Wings of Fury (en)"
; imageDir := "\\NAS2\emul\image\Apple2\G.I. Joe"
; imageDir := "\\NAS2\emul\image\Apple2\Action-Aliens (en)"
; imageDir := "\\NAS2\emul\image\Apple2\2400 A.D"
; imageDir := "\\NAS2\emul\image\Apple2\One on One (ea)(en)"
; imageDir := "\\NAS2\emul\image\Apple2\Pitfall 2 - Lost Caverns (activision)(en)"
; imageDir := "\\NAS2\emul\image\Apple2\Bard's Tale III - The Thief of Fate (interplay)(en)\"
; imageDir := "\\NAS2\emul\image\Apple2\Wings of Fury (en)"
; imageDir := "\\NAS2\emul\image\Apple2\King Quest II - Romancing The Throne (en)"
; imageDir := "\\NAS2\emul\image\Apple2\Deathlord"

option  := getOption(imageDir)
config  := setConfig("mame_libretro",option,true)
fileCmd := makeCmd(imageDir, config)

linkResource()
setBezel(config,imageDir)
writeConfig(config, imageFile)
runEmulator(fileCmd, config)
waitCloseEmulator()

ExitApp

setBezel(config, imageDir) {
	if(config.input_overlay == "")
		return
	bezel := FileUtil.getFile( imageDir "\_EL_CONFIG\bezel", "i).*\.(cfg)$" )
	debug("target : " imageDir "\_EL_CONFIG\bezel" )
	debug("bezel  : " bezel)
	if(bezel != "") {
		config.input_overlay := bezel
	}
}

makeCmd(imageDir, config) {

  makeMachineConfig(imageDir, config)

	fileCmd := A_ScriptDir "\Apple.cmd"

	cmd .= nvl(config.machine, "apple2ee")

	cmd .= " -waitvsync"
	cmd .= " -rewind"
	cmd .= " -skip_gameinfo"

  cmd .= addOption("-ramsize", config.ramsize)
  cmd .= addOption("-gameio",  config.gameio)
  cmd .= addOption("-aux",     config.aux)
  cmd .= addOption("-sl0",     config.sl0)
  cmd .= addOption("-sl1",     config.sl1)
  cmd .= addOption("-sl2",     config.sl2)
  cmd .= addOption("-sl3",     config.sl3)
  cmd .= addOption("-sl4",     config.sl4)
  cmd .= addOption("-sl5",     config.sl5)
  cmd .= addOption("-sl6",     config.sl6)
  cmd .= addOption("-sl7",     config.sl7)

  cmd .= addOption("-rp", wrap( EMUL_ROOT "\system\mame\console\apple"))

  disks  := FileUtil.getFiles(imageDir, "i).*\.(dsk|woz|nib)$")
  fddCnt := min(config.fdd_cnt, disks.maxIndex())
  fddIdx := [1,2,3,4]
  if(fddCnt >= 3) {
    fddIdx := [3,4,1,2]
  }
  for i, disk in disks {
    cmd .= addOption("-flop" fddIdx[i], wrap(disk))
    if(i >= fddCnt)
    	break
  }

  hdds  := FileUtil.getFiles(imageDir, "i).*\.(po|2mg)$")
  for i, hdd in hdds {
  	cmd .= addOption("-hard" i, wrap(hdd))
    if(i >= 2)
    	break
  }

  debug(">> cmd : " cmd)
  FileUtil.write(fileCmd, cmd)
  return fileCmd

}

makeMachineConfig(imageDir, config) {

  if(config.machine == "")
    return

  conf := "<?xml version=""1.0""?>`n"
  conf .= "<mameconfig version=""10"">"
  conf .= "<system name=" wrap(config.machine) ">`n"
  conf .= "  <image_directories>`n"
  for i in [1,2,3,4] {
    conf .= "    <device instance=" wrap("floppydisk" i) " directory=" wrap(imageDir) " />`n"
  }
  for i in [1,2] {
    conf .= "    <device instance=" wrap("harddisk" i) " directory=" wrap(imageDir) " />`n"
  }
  conf .= "    <device instance=" wrap("cassette") " directory=" wrap(imageDir) " />`n"
  conf .= "  </image_directories>`n"
  conf .= "  <input>`n"

  ; Monitor
  if(config.composite_monitor_type == "B&W")
    conf .= "<port tag="":a2_config"" type=""CONFIG"" mask=""7"" defvalue=""0"" value=""1"" />`n"
  if(config.composite_monitor_type == "Green")
    conf .= "<port tag="":a2_config"" type=""CONFIG"" mask=""7"" defvalue=""0"" value=""2"" />`n"
  if(config.composite_monitor_type == "Amber")
    conf .= "<port tag="":a2_config"" type=""CONFIG"" mask=""7"" defvalue=""0"" value=""3"" />`n"
  if(config.composite_monitor_type == "Video-7 RGB")
    conf .= "<port tag="":a2_config"" type=""CONFIG"" mask=""7"" defvalue=""0"" value=""4"" />`n"

  ; CPU
  if(config.cpu_type == "4 MHz Zip Chip")
    conf .= "<port tag="":a2_config"" type=""CONFIG"" mask=""16"" defvalue=""0"" value=""16"" />`n"

  ; Bootup speed
  if(config.bootup_speed == "4 MHz")
    conf .= "<port tag="":a2_config"" type=""CONFIG"" mask=""32"" defvalue=""0"" value=""32"" />`n"

  conf .= "  </input>`n"
  conf .= "</system>"
  conf .= "</mameconfig>"

  debug(conf)

	confFile := imageDir "\_EL_CONFIG\save\ra\save\mame\cfg\" config.machine ".cfg"
	FileUtil.write(confFile, conf)

}

addOption(key,value) {
	if(value == "") {
		return ""
	} else {
		return " " key " " value
	}
}

linkResource() {
  dirSystem := EMUL_ROOT "\system\mame"
  FileUtil.makeDir( dirSystem )
  FileUtil.makeLink( EMUL_ROOT "\system\mame\console\common\samples",  dirSystem "\samples", true )
}

#include %A_ScriptDir%\script\AbstractHotkey.ahk