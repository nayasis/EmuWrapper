#NoEnv
#include %A_ScriptDir%\script\AbstractFunction.ahk

; https://wiki.mamedev.org/index.php/Driver:Apple_II

imageDir := %0%
; imageDir := "\\NAS2\emul\image\Apple2\Action\Karateka"
; imageDir := "\\NAS2\emul\image\Apple2\RPG-Times of Lore (en)"
; imageDir := "\\NAS2\emul\image\Apple2\RPG\Ultima V - Warriors of Destiny"
; imageDir := "\\NAS2\emul\image\Apple2\Action\Black Magic"
; imageDir := "\\NAS2\emul\image\Apple2\Space Rogue (en)"
; imageDir := "\\NAS2\emul\image\Apple2\Wings of Fury (en)"
; imageDir := "\\NAS2\emul\image\Apple2\G.I. Joe"
; imageDir := "\\NAS2\emul\image\Apple2\Action-Aliens (en)"
; imageDir := "\\NAS2\emul\image\Apple2\2400 A.D"
; imageDir := "\\NAS2\emul\image\Apple2\One on One (ea)(en)"
imageDir := "\\NAS2\emul\image\Apple2\Pitfall 2 - Lost Caverns (activision)(en)"
; imageDir := "\\NAS2\emul\image\Apple2\Bard's Tale III - The Thief of Fate (interplay)(en)\"

; EMUL_ROOT := A_ScriptDir "\1.9.0"

option    := getOption(imageDir)
config    := setConfig("mame_libretro",option,false)

imageFile := A_ScriptDir "\Apple.cmd"

makeCmd(imageDir, imageFile)
config.input_overlay := "c:\app\emulator\Retroarch\share\overlays\apple_iie.cfg"


linkResource()

setBezel(config,imageDir)
writeConfig(config, imageFile)
runEmulator(imageFile, config)
waitCloseEmulator()

loop, % option.core.wait_subprocess
{
	debug( "wait sub process : " A_Index )
	waitEmulator(1)
	IfWinExist
	{
		waitCloseEmulator()
	}
}

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

makeCmd(imageDir, imageFile) {

	cmd .= " apple2ee"
	; cmd .= " apple2e"
	; cmd .= " apple2c"
	cmd .= " -waitvsync"
	cmd .= " -rewind"
	cmd .= " -skip_gameinfo"

	cmd .= " -sl4 mockingboard"
	; cmd .= " -sl5 mockingboard"
  cmd .= " -gameio joy"
  cmd .= " -rp"
	cmd .= " " wrap( A_ScriptDir "\share\system\mame\bios\apple")

  disks := FileUtil.getFiles(imageDir, "i).*\.(dsk)$")
  for i, disk in disks {
    cmd .= " -flop" i " " wrap(disk)
    if(i >= 2)
    	break
  }

  ; hdds  := FileUtil.getFiles(imageDir, "i).*\.(hdd|po)\.zip$")
  hdds  := FileUtil.getFiles(imageDir, "i).*\.(po)$")
  if(hdds.MaxIndex() >= 1)
  	cmd .= " -sl7 cffa2"
  for i, disk in hdds {
    cmd .= " -hard" i " " wrap(disk)
    if(i >= 2)
    	break
  }

  debug(">> cmd : " cmd)
  FileUtil.write(imageFile, cmd)

}

linkResource() {
	pathSystem := EMUL_ROOT "\system\mame"
	FileUtil.makeLink( pathSystem "\samples-origin",  pathSystem "\samples", true )
}


#include %A_ScriptDir%\script\AbstractHotkey.ahk