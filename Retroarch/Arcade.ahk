#NoEnv
#include %A_ScriptDir%\script\AbstractFunction.ahk

imageDir := %0%
; imageDir := "\\NAS2\emul\image\Neogeo\King of Fighters '98 - Dream match never ends (snk)(T-ko 1.0 by dsno)"
; imageDir := "\\NAS2\emul\image\ArcadeMame\Outlaws of the Lost Dynasty (en)"

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

isMame := RegExMatch(config.core, "i)^mame.*")

if(isMame) {
	config.mame_boot_from_cli := "enabled"
}

setBezel(config,imageDir)
writeConfig(config, imageFile)

if( isMame ) {
	imageFile := toCliArgument(imageFile)
}

runEmulator(imageFile, config, appendConfig)
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
	if(bezel != "") {
		config.input_overlay := bezel
	}
}

toCliArgument(imageFile) {

	dirRom     := FileUtil.getDir(imageFile)
	dirArtwork := dirRom "\artwork"
	dirSample  := dirRom "\samples"
	pathCmd    := A_ScriptDir "\Arcade.cmd"

	args := " -rp " wrap(dirRom)
	if( FileUtil.exist(dirArtwork) )
		args .= " -artpath " wrap(dirArtwork)
	if( FileUtil.exist(dirSample) )
		args .= " -samplepath " wrap(dirSample)
	args .= wrap(imageFile)

	FileUtil.write(pathCmd, args)
	return pathCmd

}

; linkResource(config, imageFile) {
; 	pathSystem := EMUL_ROOT "\system\mame"
; 	FileUtil.makeDir( pathSystem )
; 	imageDir := FileUtil.getDir(imageFile)
; 	for i,v in ["samples","artwork"] {
; 		FileUtil.makeLink( imageDir "\" v,  pathSystem "\" v, true )
; 	}
; }

#include %A_ScriptDir%\script\AbstractHotkey.ahk