#NoEnv
#include %A_ScriptDir%\script\AbstractFunction.ahk

; https://wiki.mamedev.org/index.php/Driver:Apple_II

imageDir := %0%
; imageDir := "\\NAS2\emul\image\Apple2\Action\Karateka"
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

option  := getOption(imageDir)
config  := setConfig("mame_libretro",option,false)
fileCmd := makeCmd(imageDir, config)

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

	fileCmd := A_ScriptDir "\Apple.cmd"

	cmd .= nvl(config.machine, "apple2ee")

	cmd .= " -waitvsync"
	cmd .= " -rewind"
	cmd .= " -skip_gameinfo"

  cmd .= bindOption("samplepath", wrap(EMUL_ROOT "\system\mame\console\common\samples") )
  cmd .= bindOption("cfg_directory", wrap(EMUL_ROOT "\system\mame\console\common\cfg") )

  cmd .= bindOption("ramsize", config.ramsize)
  cmd .= bindOption("gameio",  config.gameio)
  cmd .= bindOption("aux",     config.aux)
  cmd .= bindOption("sl0",     config.sl0)
  cmd .= bindOption("sl1",     config.sl1)
  cmd .= bindOption("sl2",     config.sl2)
  cmd .= bindOption("sl3",     config.sl3)
  cmd .= bindOption("sl4",     config.sl4)
  cmd .= bindOption("sl5",     config.sl5)
  cmd .= bindOption("sl6",     config.sl6)
  cmd .= bindOption("sl7",     config.sl7)

  cmd .= bindOption("rp", wrap( EMUL_ROOT "\system\mame\console\apple\bios"))

  disks := FileUtil.getFiles(imageDir, "i).*\.(dsk|woz|nib)$")
  if(config.single_fdd == "Y") {
  	diskCnt := 1
  } else {
  	diskCnt := min(2, disks.maxIndex())
  }

  for i, disk in disks {
  	cmd .= bindOption("flop" i, wrap(disk))
    if(i >= diskCnt)
    	break
  }

  hdds  := FileUtil.getFiles(imageDir, "i).*\.(po|2mg)$")
  for i, disk in hdds {
  	cmd .= bindOption("hard" i, wrap(disk))
    if(i >= 2)
    	break
  }

  debug(">> cmd : " cmd)
  FileUtil.write(fileCmd, cmd)
  return fileCmd

}

bindOption(key,value) {
	if(value == "")
		return ""
	else
		return " -" key " " value
}

#include %A_ScriptDir%\script\AbstractHotkey.ahk