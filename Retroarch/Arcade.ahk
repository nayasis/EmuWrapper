#NoEnv
#include %A_ScriptDir%\script\AbstractFunction.ahk

imageDir := %0%
; imageDir := "\\NAS2\emul\image\Neogeo\King of Fighters '98 - Dream match never ends (snk)(T-ko 1.0 by dsno)"
; imageDir := "\\NAS2\emul\image\FBA\Gunbird (psikyo)(T-ko 1.0 by dsno)"

; EMUL_ROOT := A_ScriptDir "\1.9.0"

option    := getOption(imageDir)
config    := setConfig("mame_libretro",option,false)
imageFile := getRomPath(imageDir,option,"zip|7z",true)

; config.core := "kronos_libretro"
; config.core := "fbalpha2012_libretro"
; config.core := "fbalpha2012_cps1_libretro"
; config.core := "fbalpha2012_cps2_libretro"
; config.core := "fbalpha2012_neogeo_libretro"
; config.core := "mame_libretro"
; config.core := "mame2016_libretro"
; config.core := "mame2003_plus_libretro"

; modify command argument : imageFile
; if( config.core == "mame_libretro" ) {
; 	config.mame_boot_from_cli := "enabled"
; 	imageFile := toCliArgument( imageFile )
; } else
if( RegExMatch(config.core, "i)^mame.*") ) {
	linkResource( config, imageFile )
}

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
	bezel := FileUtil.getFile( imageDir "\_EL_CONFIG\bezel", "i).*\.(cfg)$" )
	debug("target : " imageDir "\_EL_CONFIG\bezel" )
	debug("bezel  : " bezel)
	if(bezel != "") {
	; config.input_overlay := "\\NAS2\emul\image\FBA\Gunbird (psikyo)(T-ko 1.0 by dsno)\_EL_CONFIG\bezel\gunbird.cfg"
		config.input_overlay := bezel
	}
}

toCliArgument(imageFile) {
	romName := FileUtil.getName(imageFile,false)
	dir     := FileUtil.getDir(imageFile)
	args    := romName " -rp \""" dir "\"""
	args    .= " -artpath \""" dir "\artwork\"""
	args    .= " -samplepath \""" dir "\samples\"""
	return args
}

linkResource(config, imageFile) {
	pathSystem := EMUL_ROOT "\system\mame"
	FileUtil.makeDir( pathSystem )
	imageDir := FileUtil.getDir(imageFile)
	for i,v in ["samples","artwork"] {
		FileUtil.makeLink( imageDir "\" v,  pathSystem "\" v, true )
	}
}

#include %A_ScriptDir%\script\AbstractHotkey.ahk