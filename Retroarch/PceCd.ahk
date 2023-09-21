#NoEnv
#include %A_ScriptDir%\script\AbstractFunction.ahk

imageDir := %0%
imageDir := "\\NAS2\emul\image\PcEngineCd\Might and Magic (nec)(T-en 2023-07-18 by TiCo.KH)"

option    := getOption( imageDir )
config    := setConfig( "mednafen_supergrafx_libretro", option )
imageFile := getRomPath( imageDir, option, "chd|cue" )

applyCustomFont(imageDir)

writeConfig( config, imageFile )
runEmulator( imageFile, config )
; runEmulator( imageFile, config, "", "pressStart" )

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

; pressStart( processId, core, imageFilePath, option ) {
; 	WinWait, RetroArch Beetle PCE Fast,, 10
; 	activateEmulator()
; 	Send {Enter Down}
; 	Sleep 20
; 	Send {Enter Up}
; }