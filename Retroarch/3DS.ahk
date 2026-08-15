#Requires AutoHotkey >=2.0
#Include %A_ScriptDir%\script\AbstractFunction.ahk

imageDir := A_Args.Length ? A_Args[1] : ""
;imageDir := "\\NAS2\emul\image\3DS\Meitantei Conan - Phantom Rhapsody (spike chunsoft)(T-ko 0.0.4 by mark83)"
;imageDir := "\\NAS2\emul\image\3DS\Dragon Quest XI (square enix)(T-ko 1.5 by view5199)"
imageDir := "\\NAS2\emul\image\3DS\Dragon Quest VII - Fragments of the Forgotten Past (square enix)(T-ko 260815 by honguh)"

option    := getOption(imageDir)
config    := setConfig("citra_libretro", option)
imageFile := getRomPath( imageDir, option, "3ds|3dsx|elf|axf|cci|zcci|cxi|cia|app" )

;config.core := "citra2018_libretro"
config.video_driver := "glcore"
config.driver_switch_enable := "false"
config.input_auto_mouse_grab := "true"
; config.video_shader := "none"

writeConfig(config, imageFile)

prepareFont(imageDir)
applyLumaPatch(imageDir)
applyNandPatch(imageDir)

runEmulator(imageFile, config)

ExitApp

prepareFont(imageDir) {
  srcFont := imageDir "\_EL_CONFIG\font\shared_font.bin"
	if(! FileUtil.exist(srcFont))
		srcFont := DIR_SAVE "\sysdata\shared_font.bin.src"
	trgFont := DIR_SAVE "\sysdata\shared_font.bin"
  FileUtil.makeLink(srcFont, trgFont, true)
}

applyLumaPatch(imageDir) {
  src := FileUtil.findDir(imageDir "\_EL_CONFIG\luma\titles", ".*")
  if(FileUtil.exist(src)) {
    trg := DIR_SAVE "\load\mods\" . FileUtil.getName(src)
    FileUtil.makeLink(src, trg, true)
  }
}

applyNandPatch(imageDir) {
  for _, src in FileUtil.findDirs(imageDir "\_EL_CONFIG\nand\title", ".*", 1) {
    trg := DIR_SAVE "\nand\00000000000000000000000000000000\title\" . FileUtil.getName(src)
    FileUtil.makeLink(src, trg, true)
  }
}

#Include %A_ScriptDir%\script\AbstractHotkey.ahk
