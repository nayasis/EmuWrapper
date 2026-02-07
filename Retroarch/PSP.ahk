#Requires AutoHotkey >=2.0
#Include %A_ScriptDir%\script\AbstractFunction.ahk

imageDir := A_Args.Length ? A_Args[1] : ""
; imageDir := "\\NAS\emul\image\PSP\Densha de Go! Pocket - Yamanotesen Hen (ja)"
; imageDir := "\\NAS\emul\image\PSP\ToraDora Portable (T-ko)"
; imageDir := "\\NAS\emul\image\PSP\Phantasy Star Portable 2 (en)"
; imageDir := "\\NAS2\emul\image\PSP\God Eater 2 (T-en 1.3 by RedArtz)"
 ;imageDir := "\\NAS2\emul\image\PSP\Rockman Dash - Hagane no Boukenshin (capcom)(T-ko)"

setCustomFont( imageDir )

option    := getOption( imageDir )
config    := setConfig( "ppsspp_libretro", option )
imageFile := getRomPath( imageDir, option, "m3u|chd|cue|iso|cso|pbp|prx|elf" )

; config.ppsspp_language := "Korean"

writeConfig( config, imageFile )
runEmulator( imageFile, config )

ExitApp


setCustomFont( imageDir ) {

  fontCustom := imageDir "\_EL_CONFIG\font\jpn0.pgf"
  fontOrigin := EMUL_ROOT "\system\ppsspp\flash0\font\jpn0.pgf.src"
 
  fontSrc    := FileUtil.exist(fontCustom) ? fontCustom : fontOrigin
  fontTrg    := EMUL_ROOT "\system\ppsspp\flash0\font\jpn0.pgf"

  if( FileUtil.getSize(fontSrc) != FileUtil.getSize(fontTrg) ) {
  	debug( ">> File Copy !!")
  	FileUtil.copy( fontSrc, fontTrg )
  }
	
}

#Include %A_ScriptDir%\script\AbstractHotkey.ahk