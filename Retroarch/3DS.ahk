#NoEnv
#include %A_ScriptDir%\script\AbstractFunction.ahk

imageDir := %0%
;imageDir := "e:\download\Dai Gyakuten Saiban 1"
;imageDir := "\\NAS2\emul\image\3DS\Brain Age - Concentration Training (ko)"

option    := getOption(imageDir)
config    := setConfig("citra_libretro", option)
imageFile := getRomPath( imageDir, option, "3ds|3dsx|elf|axf|cci|cxi|cia|app" )

config.video_driver := "glcore"
config.driver_switch_enable := "false"
config.input_auto_mouse_grab := "true"
; config.video_shader := "none"

writeConfig(config, imageFile)
prepareFont(imageFile)

runEmulator(imageFile, config)

ExitApp

prepareFont(imageFile) {
	gameDir := FileUtil.getDir(imageFile)
  src     := EMUL_ROOT "\saves\citra\sysdata\shared_font.bin"
	trg     := gameDir "\_EL_CONFIG\save\ra\save\Citra\sysdata\shared_font.bin"

  ; copy shared font
  if(! FileUtil.exist(trg)) {
    FileUtil.copy(src,trg)
  }

}




#include %A_ScriptDir%\script\AbstractHotkey.ahk