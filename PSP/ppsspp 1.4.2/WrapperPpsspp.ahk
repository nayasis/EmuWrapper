#NoEnv
#include %A_ScriptDir%\..\..\ZZ_Library\Include.ahk

global emulatorPid  := ""
global isFullScreen := true

imageFilePath := %0%
; imageFilePath := "\\NAS\emul\image\PSP\Toukiden (en)"
; imageFilePath := "\\NAS\emul\image\PSP\ToraDora Portable (ko)"
; imageFilePath := "\\NAS\emul\image\PSP\Katekyoo Hitman Reborn - Battle Arena 2 - Spirits Burst (ja)"

cdContainer := new DiskContainer( imageFilePath, "i).*\.(iso|cso)$" )
if ( cdContainer.size() == 0 ) {
	ExitApp
}
cdContainer.initSlot( 1 )

if ( cdContainer.size() >= 1 ) {

	setConfig( imageFilepath )

	Run, % "PPSSPPWindows64.exe " """" cdContainer.getFileInSlot(1) """",,,emulatorPid
	waitEmulator()
	IfWinExist
		Process, WaitClose, %emulatorPid%

} else {
	RunWait, % "PPSSPPWindows64.exe",,,emulatorPid	
}

ExitApp

^+PGUP:: ; Change CD rom
	if( cdContainer.size() > 1 )
		cdContainer.insertDisk( "1", "changeCdRom" )
	return

^+End:: ; Cancel Disk Change
	if( cdContainer.size() > 1 )
		cdContainer.cancel()
	return

!Enter:: ; Toggle Fullscreen
  isFullScreen := ! isFullScreen
  activateEmulator()
  Send !{Enter}
  return

^+Del:: ; Reset
	activateEmulator()
	Send ^b
	return

^+Insert:: ; Toggle Speed
	Tray.showMessage( "Toggle speed" )
	activateEmulator()
	Send {``}
	return

waitEmulator() {
	WinWait, ahk_class PPSSPPWnd,, 10
	IfWinExist
	  activateEmulator()
}

activateEmulator() {
	WinActivate, ahk_class PPSSPPWnd	
}

changeCdRom( slotNo, file ) {
	Tray.showMessage( "Change UMD" file )
  activateEmulator()
  if( isFullScreen == true )
  {
    	Send !{Enter}
    	Sleep, 500
  }
  Send {Alt}{E}{Down}{Down}{Down}{Enter}
  Clipboard := file
  Sleep, 500
  Send ^v
  Send {Enter}
  Sleep, 500
  if ( isFullScreen == true ) {
    	Send !{Enter}
    	Sleep, 500
  }
	return
}

setConfig( imageFilePath ) {

	dirConf   := FileUtil.getDir( imageFilepath ) . "\_EL_CONFIG"
	FileUtil.makeDir( dirConf )

	; set custom font
  fontCustom   := dirConf "\font\jpn0.pgf"
	fontCurr     := A_ScriptDir "\assets\flash0\font\jpn0.pgf"
	fontOriginal := A_ScriptDir "\assets\flash0\font\jpn0.pgf.src"

	if ( FileUtil.exist(fontCustom) ) {
		if ( ! isEqualAttr(fontCustom,fontCurr) )
			FileUtil.copyFile( fontCustom, fontCurr )
	} else {
		if ( ! isEqualAttr(fontOriginal,fontCurr) )
			FileUtil.copyFile( fontOriginal, fontCurr )
	}

  ; copy custom save data
  dirCustomSave := dirConf "\save"
  dirEmulSave   := A_ScriptDir "\memstick\PSP\SAVEDATA"
  if ( FileUtil.exist(dirCustomSave) ) {
  	zipFiles := FileUtil.getFiles(dirCustomSave,"i).*\.(zip|7z)$")
  	Loop, % zipFiles.MaxIndex()
  	{
  		zipFile := zipFiles[ A_Index ]
  		pureName := FileUtil.getFileName( zipFile, false )
  		if( FileUtil.exist(dirEmulSave "\" pureName) )
  			continue

  		zipHandler := new 7Zip( zipFile )
  		zipHandler.extract( dirEmulSave )
  		zipHandler.close()

  		debug( zipFile " -> " dirEmulSave )
  	}

  	; FileUtil.copyDir( dirCustomSave "\*", )
  }

	; set full screen
	iniFile := A_ScriptDir "\memstick\PSP\System\ppsspp.ini"
	IniWrite, True, % iniFile, Graphics, FullScreen

}

isEqualAttr( src, trg ) {
	if( FileUtil.getSize(src) != FileUtil.getSize(trg) )
	 return false
	if( FileUtil.getTime(src) != FileUtil.getTime(trg) )
	 return false
	return true
}