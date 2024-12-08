#NoEnv
#include %A_ScriptDir%\..\..\ZZ_Library\Include.ahk

global option

imageDir  := %0%
; imageDir  := "\\NAS2\emul\image\Apple2\Threshold (on-line)(en)"
; imageDir  := "\\NAS\emul\image\Apple2\RPG\Times of Lore (en)"
; imageDir  := "\\NAS\emul\image\Apple2\Shooting\Wings of Fury (en)"
 ;imageDir  := "\\NAS2\emul\image\Apple2\Questron II (ssi)(en)"

fddContainer := new DiskContainer( imageDir, "i).*\.(dsk|woz|nib)$" )
fddContainer.initSlot( 2 )

option := setConfig( imageDir, fddContainer )

; cmd := "AppleWin.exe -no-full-screen -fs-width=1600 -fs-height=1200 -no-printscreen-dlg"
; cmd := "AppleWin.exe -no-full-screen -conf apple.ini -fs-height=best -no-printscreen-dlg"
cmd := "AppleWin.exe -conf apple.ini -fs-height=best " option
; cmd := "AppleWin.exe -no-full-screen -conf apple.ini -fs-height=best "
debug("cmd : " cmd)

; ExitApp

Run, % cmd,,,emulatorPid
waitEmulator()
IfWinExist
{
  debug("Found window !!")
  activateEmulator()
  reset()
  waitCloseEmulator()
}

ExitApp

waitEmulator() {
  WinWait, ahk_class APPLE2FRAME,, 20
}

activateEmulator() {
  WinActivate, ahk_class APPLE2FRAME,, 20
}

waitCloseEmulator() {
  WinWaitClose, ahk_class APPLE2FRAME
}

^+PGUP:: ; Insert Disk in Drive#1

  If GetKeyState( "z", "P" ) ; Ctrl + Shift + Z + PgUp :: Remove Disk in Drive#1
    fddContainer.removeDisk( "1", "removeDisk" )
  else ; Ctrl + Shift + PgUp :: Insert Disk in Drive#1
    fddContainer.insertDisk( "1", "insertDisk" )
  
  return

^+PGDN:: ; Insert Disk in Drive#2

  if( option.core.fdd != "2" )
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
  activateEmulator()
  Send {ScrollLock}
  return

!Enter:: ; Toggle fullscreen
  toggleFullscreen()
  return

reset() {
  activateEmulator()
  Send {F2}
}

toggleFullscreen() {
  activateEmulator()
  Send {ALT Down}{Enter}{Alt Up}  
}

insertDisk( slotNo, file ) {
  activateEmulator()
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

getConfig( imageDir, diskContainer ) {

  dirBase := FileUtil.getDir(imageDir) "\_EL_CONFIG"
  option  := getOption(imageDir)

  config := " "
  config .= " --portable"
  config .= " --fullscreen"

  if( diskContainer.hasDisk() ) {
    if( diskContainer.size() == 1 ) {
      ; config .= " --nogui"
    }
  }

  if( option.core.renderer == "software" ) {
    config .= " --cfgpath="".\inis-software"""
  }

  return config
  
}

getOption(imageDir) {
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


setConfig(imageDir, fddContainer) {

  dirBase := imageDir "\_EL_CONFIG"
  option  := getOption(imageDir)
  fileIni := A_ScriptDir "\apple.ini"

  debug( ">> option`n" JSON.dump(option) )

  config := " -no-printscreen-dlg"

  ; Default
  IniWrite, 1, % fileIni, Configuration, Custom Speed
  IniWrite, 1, % fileIni, Configuration, ScrollLock Toggle
  IniWrite, % option.core.clock_multiplier, % fileIni, Configuration, Emulation Speed

  ; fullscreen
  if(option.core.full_screen != "true") {
    config .= " -no-full-screen"
  }

  if(option.core.card_vidHD == "true") {
    IniWrite, 21, % fileIni, Configuration\Slot 3, Card type
  } else {
    IniWrite, 0, % fileIni, Configuration\Slot 3, Card type
  }

  ; model
  config .= " -model " nvl(option.core.model,"apple2ee")

  ; video
  IniWrite, % option.core.video_mode, % fileIni, Configuration, Video Emulation

  ; video refresh
  config .= " -" nvl( option.core.video_refresh, "60hz" )

  ; sound
  if(option.core.sound_card == "mocking_board" || option.core.sound_card == "") {
    IniWrite, 3, % fileIni, Configuration\Slot 4, Card type
    IniWrite, 3, % fileIni, Configuration\Slot 5, Card type
  } else if(option.core.sound_card == "phasor") {
    IniWrite, 9, % fileIni, Configuration\Slot 4, Card type
  } else if(option.core.sound_card == "sam_dac") {
    IniWrite, 11, % fileIni, Configuration\Slot 5, Card type
  } else if(option.core.sound_card == "no_sound") {
    IniWrite, 0, % fileIni, Configuration\Slot 4, Card type
    IniWrite, 0, % fileIni, Configuration\Slot 5, Card type
  }

  ; Enhance disk access speed
  IniWrite, % nvl(option.core.enhance_disk_access,1), % fileIni, Configuration, Enhance Disk Speed

  ; fdd
  IniDelete, % fileIni, Configuration\Slot 6, Last Disk Image 1
  IniDelete, % fileIni, Configuration\Slot 6, Last Disk Image 2
  IniDelete, % fileIni, Configuration\Slot 5, Last Disk Image 1
  IniDelete, % fileIni, Configuration\Slot 5, Last Disk Image 2
  fdCnt := fddContainer.size()
  if( option.core.fdd == "0" ) {
    config .= " -d1-disconnected"
    config .= " -d2-disconnected"
  } else if( option.core.fdd == "1" ) {
    config .= " -d2-disconnected"
    for i in range(1, Min(1,fdCnt) + 1) {
      config .= " -s6d" i " " wrap(fddContainer.getFile(i))
    }
  } else if( option.core.fdd == "2" ) {
    for i in range(1, Min(2,fdCnt) + 1) {
      config .= " -s6d" i " " wrap(fddContainer.getFile(i))
    }
  } else if( option.core.fdd == "4" ) {
    for i in range(1, Min(2,fdCnt) + 1) {
      config .= " -s6d" i " " wrap(fddContainer.getFile(i))
    }
    if(fdCnt > 2) {
      config .= " -s5 diskii"
      for i in range(3, Min(4,fdCnt) + 1) {
        config .= " -s5d" (i-2) " " wrap(fddContainer.getFile(i))
      }
    }
  }

  ; hdd
  hdd := FileUtil.getFiles( currDir, "i).*\.(po|2mg)$" )
  Loop, % hdd.MaxIndex()
  {
    if( a_index > 2 )
      break
    config .= " -h%a_index% " wrap(hdd[a_index])
  }

  ; joystick
  IniWrite, % option.core.joystick1, % fileIni, Configuration, Joystick0 Emu Type v3
  IniWrite, % option.core.joystick2, % fileIni, Configuration, Joystick1 Emu Type v3

  IniWrite, % nvl(option.core.xtrim,0), % fileIni, Configuration, PDL X-Trim
  IniWrite, % nvl(option.core.ytrim,0), % fileIni, Configuration, PDL Y-Trim

  IniWrite, % option.core.auto_fire, % fileIni, Configuration, Autofire
  IniWrite, % option.core.auto_center, % fileIni, Configuration, Joystick Centering Control
  IniWrite, % option.core.input_swap, % fileIni, Configuration, Swap buttons 0 and 1

  return config

}
