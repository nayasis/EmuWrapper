#NoEnv
#include %A_ScriptDir%\script\AbstractFunction.ahk

imageDir := %0%
; imageDir := "\\NAS2\emul\image\x68000\Ys 3 - Wanderers From Ys (ja)\"
; imageDir := "\\NAS2\emul\image\x68000\Ys 2 - Ancient Ys Vanished (ja)\"
; imageDir := "\\NAS2\emul\image\x68000\Akumajou Dracula (ja)\"
; imageDir := "\\NAS2\emul\image\x68000\Final Fight (ja)\"
; imageDir := "\\NAS2\emul\image\x68000\Sangokushi (ja)\"
; imageDir := "\\NAS2\emul\image\x68000\Sangokushi III (ja)\"

option    := getOption( imageDir )
config    := setConfig( "px68k_libretro", option )
imageFile := getRomPath( imageDir, option, "cmd|m3u|zip|dim|img|d88|88d|hdm|dup|2hd|xdf|hdf" )

setStartDir(imageDir)
writeConfig(config, imageFile)
runEmulator(imageFile, config)

ExitApp

setStartDir(imageDir) {
	conf := "[WinX68k]`n"
	conf .= "StartDir=%imageDir%`n"
	dirConf := EMUL_ROOT "\system\keropi"
	FileUtil.makeDir(dirConf)
	FileUtil.write(dirConf "\config", conf)
}

#include %A_ScriptDir%\script\AbstractHotkey.ahk