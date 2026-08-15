#Requires AutoHotkey >=2.0
#Include %A_ScriptDir%\script\AbstractFunction.ahk

imageDir := A_Args.Length ? A_Args[1] : ""
; imageDir := "\\NAS2\emul\image\PcEngineCd\Might and Magic (nec)(T-en 2023-07-18 by TiCo.KH)"

option    := getOption( imageDir )
config    := setConfig( "mednafen_supergrafx_libretro", option )
imageFile := getRomPath( imageDir, option, "zip|7z|pce" )

applyCustomFont(imageDir, "gexpress.pce")
applyCustomFont(imageDir, "syscard3.pce")

writeConfig( config, imageFile )
runEmulator( imageFile, config )

ExitApp

applyCustomFont(imageDir, cardName) {
  customPath := FileUtil.findFile(imageDir "\_EL_CONFIG\font\" cardName)
  originPath := EMUL_ROOT "\system\" cardName ".src"
  trgPath    := EMUL_ROOT "\system\" cardName
  if( customPath != "" ) {
    FileUtil.makeLink(customPath, trgPath, true)
  } else {
    FileUtil.makeLink(originPath, trgPath, true)
  }
}

#Include %A_ScriptDir%\script\AbstractHotkey.ahk