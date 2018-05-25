#NoEnv
#include %A_ScriptDir%\..\..\ZZ_Library\Include.ahk

emulatorPid    := ""
imageFilePath  := %0%
; imageFilepath  := "f:\download\Pachy98 v0.16.0\Pachy98\Steam Heart's (T-en).hdi"

fddContainer := new DiskContainer( imageFilePath, "i).*\.(fdi)" )
fddContainer.initSlot( 2 )

if ( setConfig(imageFilePath) == true ) {
	
	Run, % "anex86.exe -cdefault",,,emulatorPid
	
	WinWait, ahk_exe anex86.exe,, 5
	IfWinExist
	{
		WinWaitActive, ahk_exe anex86.exe,, 5
		IfWinActive
		{
			Send !s

			if ( isNotFullScreen() ) {

				ResolutionChanger.change( 1280, 720 )
				;ResolutionChanger.change( 640, 480 )

				WinWaitActive, ahk_class zwxwnd,, 5

				WinSet, Style, -0xC40000, ahk_class zwxwnd   ; remove the titlebar and border(s) 
				WinMove, ahk_class zwxwnd,, 64, 0, 1152, 720  ; move the window to 64,0 and reize it to 1152x720 (640x400)
				;WinMove, ahk_class zwxwnd,, 64, 0, 640, 480  ; move the window to 64,0 and reize it to 1152x720 (640x400)
				
				Taskbar.hide()

				WinWaitClose, ahk_class zwxwnd
				WinClose ahk_exe anex86.exe

				Taskbar.show()
				ResolutionChanger.restore()
				
			} else {
				WinWaitActive, ahk_class zwxwnd,, 5
				WinWaitClose, ahk_class zwxwnd
				WinClose ahk_exe anex86.exe
			}

		}
	}
	
} else {
	Run, % "anex86.exe -cdefault",,,emulatorPid
}

ExitApp

setConfig( imageFilePath ) {

	if( Detector.version == "10" )
	{
		registryPath := "Software\A.N.\anex86\config\default"
		registryKey  := "HKCU"
	} else {
		registryPath := "S-1-5-21-108037658-2208837996-2228346073-500\Software\A.N.\anex86\config\default"
		registryKey  := "HKU"
	}

	currDir := FileUtil.getDir( imageFilepath )
	confDir := currDir . "\_EL_CONFIG"
	
	if( currDir == "" )
		return false
	
	IfExist %confDir%\font
	{
		Loop, %confDir%\font\*.*
		{
			RegWrite, REG_SZ, %registryKey%, %registryPath%, font, %A_LoopFileFullPath%
			break
		}
	} else {
		Loop, %A_ScriptDir%\font.*
		{
			RegWrite, REG_SZ, %registryKey%, %registryPath%, font, %A_LoopFileFullPath%
			break
		}
	}
	
	RegWrite,  REG_SZ, %registryKey%, %registryPath%, hdd1,
	RegWrite,  REG_SZ, %registryKey%, %registryPath%, hdd2,
	RegWrite,  REG_SZ, %registryKey%, %registryPath%, hddhist,
	RegWrite,  REG_SZ, %registryKey%, %registryPath%, fdd1,
	RegWrite,  REG_SZ, %registryKey%, %registryPath%, fdd2,
	RegWrite,  REG_SZ, %registryKey%, %registryPath%, fddhist,
	

	; Set Hdd & Fdd
	files := FileUtil.getFiles( currDir, "i).*\.(hdi)" )
	Loop, % files.MaxIndex()
	{
		if( a_index > 2 )
			break

		debug( "hdd1" files[a_index] )

		RegWrite REG_SZ, %registryKey%, %registryPath%, hdd%a_index%, % files[a_index]

		if( a_index == 1 )
		RegWrite REG_SZ, %registryKey%, %registryPath%, hddhist, % files[a_index]
	}

	files := FileUtil.getFiles( currDir, "i).*\.(fdi)" )
	Loop, % files.MaxIndex()
	{
		if( a_index > 2 )
			break

		debug( "fdd" files[a_index] )

		RegWrite REG_SZ, %registryKey%, %registryPath%, fdd%a_index%, % files[a_index]

		if( a_index == 1 )
		RegWrite REG_SZ, %registryKey%, %registryPath%, fddhist, % files[a_index]
	}
	
  return true

}

isNotFullScreen() {
	
	if( Detector.version == "10" )
	{
		registryPath := "Software\A.N.\anex86\config"
		registryKey  := "HKCU"
	} else {
		registryPath := "S-1-5-21-108037658-2208837996-2228346073-500\Software\A.N.\anex86\config\default"
		registryKey  := "HKU"
	}

	registryPath := "S-1-5-21-108037658-2208837996-2228346073-500\Software\A.N.\anex86\config\default"
	
	RegRead output, %registryKey%, %registryPath%, wmode
	
	wmode := SubStr( output, 3, 2 )
	
	return ( wmode != "19" ) ; 18 : window, 19 : fullScreen
	
}