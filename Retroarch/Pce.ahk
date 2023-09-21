#NoEnv
#include %A_ScriptDir%\script\AbstractFunction.ahk

imageDir := %0%
; imageDir := "\\NAS2\emul\image\PcEngineCd\Might and Magic (nec)(T-en 2023-07-18 by TiCo.KH)"

option    := getOption( imageDir )
config    := setConfig( "mednafen_supergrafx_libretro", option )
imageFile := getRomPath( imageDir, option, "zip|7z|pce" )

applyCustomFont(imageDir)

writeConfig( config, imageFile )
runEmulator( imageFile, config )

ExitApp

applyCustomFont(imageDir) {
  customPath := FileUtil.getFile( imageDir "\_EL_CONFIG\font\gexpress.pce" )
  originPath := EMUL_ROOT "\system\gexpress.pce.src"
  trgPath := EMUL_ROOT "\system\gexpress.pce"

  if( customPath != "" ) {
  	FileUtil.makeLink(customPath, trgPath)
  } else {
  	FileUtil.makeLink(originPath, trgPath)
  }
}


#include %A_ScriptDir%\script\AbstractHotkey.ahk