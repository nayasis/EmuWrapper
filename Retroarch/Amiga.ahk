#Requires AutoHotkey >=2.0
#Include %A_ScriptDir%\script\AbstractFunction.ahk

imageDir := A_Args.Length ? A_Args[1] : ""
; imageDir := "\\NAS2\emul\image\Amiga\Strip Poker 2"
;imageDir := "\\NAS2\emul\image\amiga\Neuromancer (interplay)(en)"

option    := getOption(imageDir)
config    := setConfig("puae_libretro", option)
imageFile := getRomPath( imageDir, option, "m3u|zip|adf|adz|hdf|hdz" )

writeConfig(config, imageFile)
;linkSaveDir(imageDir)

runEmulator( imageFile, config )

ExitApp

;linkSaveDir(imageDir) {
;	dirSave := imageDir . "\_EL_CONFIG\save\ra\save\PUAE"
;	FileUtil.makeDir(dirSave)
;	FileUtil.makeLink(dirSave, EMUL_ROOT . "\saves\PUAE", true)
;}

#Include %A_ScriptDir%\script\AbstractHotkey.ahk