#NoEnv
#include %A_ScriptDir%\script\AbstractFunction.ahk

; https://wiki.mamedev.org/index.php/Driver:Apple_II

imageDir := %0%
; imageDir := "\\NAS2\emul\image\Apple2gs\Police Quest - In Pursuit of the Death Angel (sierra)(en)"

option  := getOption(imageDir)
config  := setConfig("mame_libretro",option,true)

; set mouse enable in game
config.input_auto_mouse_grab := "true"
config.mame_mouse_enable := "enabled"

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

  config.machine := nvl(config.machine, "apple2gs")

  makeMachineConfig(imageDir, config)

	fileCmd := A_ScriptDir "\Apple2gs.cmd"

	cmd .= config.machine
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

  fdd_3_5 := FileUtil.getFiles(imageDir, "i).*\.(2mg|woz)$")
  fddIdx  := [3,4]
  for i, disk in fdd_3_5 {
    cmd .= addOption("-flop" fddIdx[i], wrap(disk))
    if(i >= 2)
      break
  }

  fdd_5_25 := FileUtil.getFiles(imageDir, "i).*\.(dsk)$")
  fddIdx  := [1,2]
  for i, disk in fdd_5_25 {
    cmd .= addOption("-flop" fddIdx[i], wrap(disk))
    if(i >= 2)
      break
  }  

  hdd := FileUtil.getFiles(imageDir, "i).*\.(po)$")
  for i, disk in hdd {
  	cmd .= addOption("-hard" i, wrap(disk))
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

  ; CPU
  if(config.cpu_type == "7 MHz ZipGS")
    conf .= "<port tag="":a2_config"" type=""CONFIG"" mask=""7"" defvalue=""0"" value=""1"" />`n"
  if(config.cpu_type == "8 MHz ZipGS")
    conf .= "<port tag="":a2_config"" type=""CONFIG"" mask=""7"" defvalue=""0"" value=""3"" />`n"
  if(config.cpu_type == "12 MHz ZipGS")
    conf .= "<port tag="":a2_config"" type=""CONFIG"" mask=""7"" defvalue=""0"" value=""5"" />`n"
  if(config.cpu_type == "16 MHz ZipGS")
    conf .= "<port tag="":a2_config"" type=""CONFIG"" mask=""7"" defvalue=""0"" value=""7"" />`n"

  conf .= "  </input>`n"
  conf .= "</system>"
  conf .= "</mameconfig>"

  debug(conf)

	confFile := imageDir "\_EL_CONFIG\save\ra\save\mame\cfg\" config.machine ".cfg"
	FileUtil.write(confFile, conf)

}

addOption(key,value) {
	if(value == "" || value == "none") {
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