#Requires AutoHotkey >=2.0
#Include %A_ScriptDir%\script\AbstractFunction.ahk

imageDir := A_Args.Length ? A_Args[1] : ""
;imageDir := "\\NAS2\emul\image\3DS\Dragon Quest VIII - Journey of the Cursed King (square enix)(T-ko 1.2)"

option    := getOption(imageDir)
config    := setConfig("citra_libretro", option)
imageFile := getRomPath( imageDir, option, "3ds|3dsx|elf|axf|cci|zcci|cxi|cia|app" )

;config.core := "citra2018_libretro"
config.video_driver := "glcore"
config.driver_switch_enable := "false"
config.input_auto_mouse_grab := "true"
; config.video_shader := "none"

writeConfig(config, imageFile)
prepareFont(imageFile)

runEmulator(imageFile, config)

ExitApp

prepareFont(imageFile) {
	if (imageFile == "")
		return
	gameDir := FileUtil.getDir(imageFile)
  src     := EMUL_ROOT "\saves\citra\sysdata\shared_font.bin"
	trg     := gameDir "\_EL_CONFIG\save\ra\save\Citra\Citra\sysdata\shared_font.bin"

  ; copy shared font
  if(! FileUtil.exist(trg)) {
    destDir := FileUtil.getParentDir(trg)
    FileUtil.makeDir(destDir)
    FileCopy(src, trg, true)
  }

}

#Include %A_ScriptDir%\script\AbstractHotkey.ahk
