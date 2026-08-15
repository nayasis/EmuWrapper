#Requires AutoHotkey >=2.0
#Include %A_ScriptDir%\script\AbstractFunction.ahk

imageDir := A_Args.Length ? A_Args[1] : ""
;imageDir := "\\NAS2\emul\image\PcEngineCd\Ys IV - The Dawn of Ys (hudson)(T-ko 0.9.4 by jiseo79)"

option    := getOption( imageDir )
config    := setConfig( "mednafen_supergrafx_libretro", option )
imageFile := getRomPath( imageDir, option, "chd|cue" )

applyCustomFont(imageDir, "gexpress.pce")
applyCustomFont(imageDir, "syscard3.pce")

writeConfig(config, imageFile)
runEmulator(imageFile, config)
; runEmulator( imageFile, config, "", "pressStart" )

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

; pressStart( processId, core, imageFilePath, option ) {
; 	WinWait, RetroArch Beetle PCE Fast,, 10
; 	activateEmulator()
; 	Send {Enter Down}
; 	Sleep 20
; 	Send {Enter Up}
; }