#NoEnv
#include %A_ScriptDir%\..\..\ZZ_Library\Include.ahk

emulatorPid := ""

imageDir := %0%
;imageDir := "\\NAS2\emul\image\WiiU\Star Fox Zero (nintendo)(en)"

config := getConfig( imageDir )

command := "cemu.exe " config
debug(command)
RunWait, % command,,,emulatorPid

ExitApp	

waitEmulator() {
	WinWait, ahk_exe Cemu.exe,, 10
	IfWinExist
	  activateEmulator()
}

activateEmulator() {
	WinActivate, ahk_exe Cemu.exe,, 10
}


; ^+Del:: ; Reset
	; activateEmulator()
	; Send !{R}{R}
	; return

; ^+Insert:: ; Toggle Speed
	; Tray.showMessage( "Toggle speed" )
	; activateEmulator()
	; sendKey( "F4" )
	; return

getConfig(imageDir) {

	dirBase := FileUtil.getDir(imageDir) "\_EL_CONFIG"
	option  := getOption(imageDir)

	; create link
	; FileUtil.makeDir( A_ScriptDir "\shaderCache" )
	for i,e in ["hfiomlc01","mlc01","shaderCache"] {
		FileUtil.makeDir(imageDir "\emul\" e)
		FileUtil.makeLink(imageDir "\emul\" e, A_ScriptDir "\" e, true)
	}

  for i,e in ["screenshots","sharedFonts","controllerProfiles","gameProfiles","graphicPacks"] {
  	FileUtil.makeLink(A_ScriptDir "\..\share\" e, A_ScriptDir "\" e, true)
  }

	for i,e in ["CafeCn.ttf","CafeKr.ttf","CafeStd.ttf","CafeTw.ttf"] {
		setFontLink(imageDir,e)
	}

 
  disk := FileUtil.getFile(imageDir "\disk\code", "rpx")
  debug(">> disk: " disk)

  if( disk != "" ) {
		config .= " -g " wrap(disk)
		config .= " -f"
  } else {
  	config := ""
  }

	return config
	
}

setFontLink( imageDir, fontFile ) {
	if( FileUtil.exist(imageDir "\emul\sharedFonts\" fontFile) ) {
		FileUtil.makeLink( imageDir "\emul\sharedFonts\" fontFile, A_ScriptDir "\sharedFonts\" fontFile, true )
	} else {
		FileUtil.makeLink( A_ScriptDir "\sharedFonts\src\" fontFile, A_ScriptDir "\sharedFonts\" fontFile, true )
	}
}

getOption( imageDir ) {
	dirConf := imageDir "\_EL_CONFIG"
	IfExist %dirConf%\option\option.json
	{
		FileRead, jsonText, %dirConf%\option\option.json
		option := JSON.load( jsonText )
	} else {
		option := {}
	}
	return option
}