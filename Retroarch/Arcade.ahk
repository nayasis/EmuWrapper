#Requires AutoHotkey >=2.0
#Include %A_ScriptDir%\script\AbstractFunction.ahk

imageDir := A_Args.Length ? A_Args[1] : ""
; imageDir := "\\NAS2\emul\image\FBA\Zip & Zap"

; EMUL_ROOT := A_ScriptDir "\1.9.0"

option    := getOption(imageDir)

;option.video_driver := "glcore"

config    := setConfig("mame_libretro",option,true)
imageFile := getRomPath(imageDir,option,"zip|7z",true)

; config.core := "kronos_libretro"
; config.core := "fbalpha2012_libretro"
; config.core := "fbalpha2012_cps1_libretro"
; config.core := "fbalpha2012_cps2_libretro"
; config.core := "fbalpha2012_neogeo_libretro"
 ;config.core := "mame_libretro"
; config.core := "mame2016_libretro"
; config.core := "mame2003_plus_libretro"

;isMame := RegExMatch(config.core, "i)^mame.*")
;if(isMame) {
;	linkResource(config, imageFile)
;}

prepareFbneoPatchedRom(config, imageFile)
setBezel(config,imageDir)
writeConfig(config, imageFile)
runEmulator(imageFile, config)
waitCloseEmulator()

Loop option.core.wait_subprocess
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
	if(config.input_overlay == "" || config.input_overlay == "none")
		return
	if(config.input_overlay == "default") {
		bezel := FileUtil.getFile( imageDir "\_EL_CONFIG\bezel", "i).*\.(cfg)$" )
		if(bezel != "") {
			config.input_overlay := bezel
		}		
	}
}

prepareFbneoPatchedRom(config, imageFile) {
	if(config.core != "fbneo_libretro")
		return

	dirPatched := A_ScriptDir "\share\system\fbneo\patched"
	
	initFbneoPatchedDir(dirPatched)
	FileUtil.makeLink(imageFile, dirPatched "\" FileUtil.getName(imageFile), true)
}

initFbneoPatchedDir(dirPatched) {
	FileUtil.makeDir(dirPatched)
	for _, file in FileUtil.getFiles(dirPatched, ".*", true) {
		FileUtil.delete(file, false)
	}	
}

;linkResource(config, imageFile) {
;	pathSystem := EMUL_ROOT "\system\mame"
;	FileUtil.makeDir( pathSystem )
;	imageDir := FileUtil.getDir(imageFile)
;	for i,v in ["samples","artwork"] {
;		FileUtil.makeLink( imageDir "\" v,  pathSystem "\" v, true )
;	}
;}

#Include %A_ScriptDir%\script\AbstractHotkey.ahk
