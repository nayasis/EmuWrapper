#NoEnv
#include %A_ScriptDir%\script\AbstractFunction.ahk

imageDir := %0%
; imageDir := "\\NAS\emul\image\PC88\Ys 2 (T-ko)"
; imageDir := "\\NAS\emul\image\PC88\Ys 1 (ja)"
; imageDir := "\\NAS\emul\image\PC88\Lupin the 3rd - Babylon no Ougon Densetsu (ja)"
; imageDir := "\\NAS\emul\image\PC88\Motoko Hime Adventure (ja)"

option    := getOption( imageDir )
config    := setConfig( "quasi88_libretro", option )
imageFile := getRomPath( imageDir, option, "m3u|d88|fdd|fdi" )

applyCustomFont( imageDir, config )

writeConfig( config, imageFile )
runEmulator( imageFile, config )

ExitApp

applyCustomFont( imageDir, config ) {

  fontSrc := nvl( FileUtil.getFile(imageDir "\_EL_CONFIG\font\"), EMUL_ROOT "\system\quasi88\n88knj1.rom.src" )
  fontTrg := EMUL_ROOT "\system\quasi88\n88knj1.rom"

  FileUtil.makeLink( fontSrc, fontTrg )

}

#include %A_ScriptDir%\script\AbstractHotkey.ahk