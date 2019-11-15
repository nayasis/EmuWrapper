#NoEnv
#include %A_ScriptDir%\script\AbstractFunction.ahk

imageDir := %0%
imageDir := "\\NAS\emul\image\PC98\XZR II (ja)"
imageDir := "\\NAS\emul\image\PC98\Toushin Toshi 2 (ja)"
imageDir := "\\NAS\emul\image\PC98\Ys 2 (T-ko)\"
imageDir := "\\NAS\emul\image\PC98\Dragon Knight 4 (T-ko by Edenlock)\"
imageDir := "\\NAS\emul\image\PC98\Kakyusei (T-ko)\"
imageDir := "\\NAS\emul\image\PC98\Thunder Force (en)\"

option := getOption( imageDir )
config := setConfig( "np2kai_libretro", option )
; config := setConfig( "nekop2_libretro", option )

applyCustomFont( imageDir, config )

imageFile := getRomPath( imageDir, option, "hdi|m3u|d88|fdd" )
runEmulator( imageFile, config )

ExitApp

applyCustomFont( imageDir, config ) {

  fontPath := FileUtil.getFile( imageDir "\_EL_CONFIG\font\" )

  if( config.core == "np2kai_libretro" ) {
  	cfgPath := EMUL_ROOT "\system\np2kai\np2kai.cfg"
  	section := "NekoProjectIIkai"
  	fontPath := nvl( fontPath, EMUL_ROOT "\system\np2kai\font.rom" )
  } else if( config.core == "nekop2_libretro" ) {
  	cfgPath := EMUL_ROOT "\system\np2\np2.cfg"
  	section := "NekoProjectII"
  	fontPath := nvl( fontPath, EMUL_ROOT "\system\np2\font.rom" )
  } else {
  	return
  }

  if( ! FileUtil.exist(cfgPath) )
 	  FileAppend, % "[" section "]", cfgPath  

  IniWrite, % fontPath, % cfgPath, % section, fontfile

  debug( "fontPath  : " fontPath )

}

#include %A_ScriptDir%\script\AbstractHotkey.ahk