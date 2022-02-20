#NoEnv
#include %A_ScriptDir%\..\..\ZZ_Library\Include.ahk

global singleFddMode  := false
global fullscreenMode := false

imageDir  := %0%
; imageDir  := "\\NAS2\emul\image\Apple2\Threshold (on-line)(en)"
; imageDir  := "\\NAS\emul\image\Apple2\RPG\Times of Lore (en)"
; imageDir  := "\\NAS\emul\image\Apple2\Shooting\Wings of Fury (en)"
; imageDir  := "\\NAS\emul\image\Apple2\Silvern Castle v9.5.1"

fddContainer := new DiskContainer( imageDir, "i).*\.zip" )
fddContainer.initSlot( 2 )

setConfig( imageDir )

if( setConfig( imageDir ) == true )
{
  Run, % "AppleWin.exe -no-printscreen-dlg ",,,emulatorPid
  WinWait, ahk_class APPLE2FRAME,, 5
  IfWinExist
  {

    ;WinSet, Style, -0xC40000, ahk_class APPLE2FRAME   ; remove the titlebar and border(s) 
    ;WinMove, ahk_class APPLE2FRAME,, 0, 0, 1366, 778  ; move the window to 64,0 and reize it to 1152x720 (640x400)

    ; Taskbar.hide()
    ; ResolutionChanger.change( 1440, 900 )
    ResolutionChanger.change( 1152, 864 )
    reset()

    if ( fullscreenMode == true ) {
      toggleFullscreen()
    }

    WinWaitClose, ahk_class APPLE2FRAME

  }
  
  ; Taskbar.show()
  ResolutionChanger.restore()
  
} else {
  Run, % "AppleWin.exe",,,emulatorPid
}

ExitApp

^+PGUP:: ; Insert Disk in Drive#1

  If GetKeyState( "z", "P" ) ; Ctrl + Shift + Z + PgUp :: Remove Disk in Drive#1
    fddContainer.removeDisk( "1", "removeDisk" )
  else ; Ctrl + Shift + PgUp :: Insert Disk in Drive#1
    fddContainer.insertDisk( "1", "insertDisk" )
  
  return

^+PGDN:: ; Insert Disk in Drive#2

  if( singleFddMode == true )
    return

  If GetKeyState( "z", "P" ) ; Ctrl + Shift + Z + PgDn :: Remove Disk in Drive#2
    fddContainer.removeDisk( "2", "removeDisk" )
  else ; Ctrl + Shift + PgDn :: Insert Disk in Drive#2
    fddContainer.insertDisk( "2", "insertDisk" )
  
  return

^+End:: ; Cancel Disk Change
  fddContainer.cancel()
  return
  
^+Del:: ; Reset
  reset()
  return

^+Insert:: ; Toggle Speed
  Tray.showMessage( "Toggle speed" )
  WinActivate, ahk_class APPLE2FRAME
  Send {ScrollLock}
  return

!Enter:: ; Toggle fullscreen
  toggleFullscreen()
  return

reset() {
  WinActivate, ahk_class APPLE2FRAME
  Send {F2}
}

toggleFullscreen() {
  WinActivate, ahk_class APPLE2FRAME
  Send {ALT Down}{Enter}{Alt Up}  
}

insertDisk( slotNo, file ) {

  WinActivate, ahk_class APPLE2FRAME
  
  if( slotNo == "1" ) {
    Send {F3}  ;FDD1
  } else if( slotNo == "2" ) {
    Send {F4}  ;FDD2
  } else {
    return
  }
  
  WinWait, Select Disk Image For Drive
  IfWinExist
  {
    Send !{N}
    Clipboard = %file%
    Send ^v
    Send {Enter}
  }
    
}

removeDisk( slotNo ) {
  WinActivate, ahk_class AfxFrameOrView90s
  if ( slotNo == "1" ) {
    Click 1150, 150, right
  } else if( slotNo == "2" ) {
    Click 1150, 200, right
  } else {
    return
  }
  Send {Down}{Enter}
}


setConfig( imageDir ) {

  registryPath := "Software\AppleWin\CurrentVersion"

  currDir := FileUtil.getDir( imageDir )
  confDir := currDir . "\_EL_CONFIG"

  if( currDir == "" )
    return false

  IfExist %confDir%\option\option.json
  {
    FileRead, jsonText, %confDir%\option\option.json
    jsonObj := JSON.load( jsonText )    
  }

  if ( jsonObj.run.singleFdd == "true" )
    singleFddMode := true
  
  if ( jsonObj.run.fullscreen == "true" )
    fullscreenMode := true

  ; Init
  ;RegWrite REG_SZ, HKCU, %registryPath%\Configuration, Printer Filename, %currDir%\Printer.txt
  RegWrite REG_SZ, HKCU, %registryPath%\Configuration, ScrollLock Toggle, 1
  RegWrite REG_SZ, HKCU, %registryPath%\Configuration, Window Scale, 2
  RegWrite REG_SZ, HKCU, %registryPath%\Configuration, Confirm Reboot, 0
  RegWrite REG_SZ, HKCU, %registryPath%\Preferences, Window X-Position, 0
  RegWrite REG_SZ, HKCU, %registryPath%\Preferences, Window Y-Position, 0

  ; Set Hdd
  RegWrite REG_SZ, HKCU, %registryPath%\Preferences, Starting Directory,
  RegWrite REG_SZ, HKCU, %registryPath%\Configuration, Harddisk Enable, 0
  RegWrite REG_SZ, HKCU, %registryPath%\Preferences, Last Harddisk Image 1,
  RegWrite REG_SZ, HKCU, %registryPath%\Preferences, Last Harddisk Image 2,

  files := FileUtil.getFiles( currDir, "i).*\.(po|hdd)\.zip$" )
  Loop, % files.MaxIndex()
  {
    if( a_index > 2 )
      break
    
    RegWrite REG_SZ, HKCU, %registryPath%\Configuration, Harddisk Enable, 1
    RegWrite REG_SZ, HKCU, %registryPath%\Preferences, Last Harddisk Image %a_index%, % files[a_index]
  }
  
  ; Set Fdd
  RegWrite REG_SZ, HKCU, %registryPath%\Preferences, Last Disk Image 1,
  RegWrite REG_SZ, HKCU, %registryPath%\Preferences, Last Disk Image 2,

  files := FileUtil.getFiles( currDir, "i).*\.dsk\.zip$" )
  Loop, % files.MaxIndex()
  {
    if( a_index > 2 )
      break
    
    if( singleFddMode == true && a_index > 1 )
      break

    RegWrite REG_SZ, HKCU, %registryPath%\Preferences, % "Last Disk Image " a_index, % files[a_index]
  }
  
  return true

}