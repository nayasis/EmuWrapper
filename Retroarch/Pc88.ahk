#Requires AutoHotkey >=2.0
#Include %A_ScriptDir%\script\AbstractFunction.ahk

imageDir := A_Args.Length ? A_Args[1] : ""
; imageDir := "\\NAS\emul\image\PC88\Ys 2 (T-ko)"
; imageDir := "\\NAS\emul\image\PC88\Ys 1 (ja)"
; imageDir := "\\NAS\emul\image\PC88\Lupin the 3rd - Babylon no Ougon Densetsu (ja)"
; imageDir := "\\NAS2\emul\image\PC88\Shenan Dragon (ja)"

option    := getOption( imageDir )
config    := setConfig( "quasi88_libretro", option )
imageFile := getRomPath( imageDir, option, "m3u|d88|fdd|fdi" )

applyCustomFont( imageDir, config )

writeConfig( config, imageFile )
runEmulator( imageFile, config )

ExitApp

applyCustomFont( imageDir, config ) {

  fontSrc := nvl( FileUtil.findFile(imageDir "\_EL_CONFIG\font\"), EMUL_ROOT "\system\quasi88\n88knj1.rom.src" )
  fontTrg := EMUL_ROOT "\system\quasi88\n88knj1.rom"

  ; FileUtil.makeLink( fontSrc, fontTrg )
  FileUtil.copy(fontSrc,fontTrg)

}

#Include %A_ScriptDir%\script\AbstractHotkey.ahk