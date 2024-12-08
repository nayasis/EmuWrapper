#NoEnv
#include %A_ScriptDir%\script\AbstractFunction.ahk

imageDir := %0%
;imageDir := "\\NAS2\emul\image\x68000\Ys 3 - Wanderers From Ys (falcom)(ja)"

option    := getOption( imageDir )
config    := setConfig( "px68k_libretro", option )
imageFile := getRomPath( imageDir, option, "cmd|m3u|zip|dim|img|d88|88d|hdm|dup|2hd|xdf|hdf" )

setStartDir(imageDir)
applyCustomFont(imageDir)
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

applyCustomFont(imageDir) {
  fontPath := FileUtil.getFile(imageDir "\_EL_CONFIG\font\")
  if( ! FileUtil.exist(fontPath) ) {
  	fontPath := EMUL_ROOT "\system\keropi\cgrom.dat.origin"
  }
  debug(fontPath "->" trgPath)
  FileUtil.makeLink(fontPath, EMUL_ROOT "\system\keropi\cgrom.dat", true)
}


#include %A_ScriptDir%\script\AbstractHotkey.ahk