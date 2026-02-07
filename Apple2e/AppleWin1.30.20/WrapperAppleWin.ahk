#Requires AutoHotkey >=2.0
#Include "%A_ScriptDir%\..\..\ZZ_Library\IncludeAppleWin.ahk"

global option

imageDir  := A_Args.Length > 0 ? A_Args[1] : ""
; imageDir  := "\\NAS2\emul\image\Apple2\Threshold (on-line)(en)"
; imageDir  := "\\NAS\emul\image\Apple2\RPG\Times of Lore (en)"
; imageDir  := "\\NAS\emul\image\Apple2\Shooting\Wings of Fury (en)"
 ;imageDir  := "\\NAS2\emul\image\Apple2\Questron II (ssi)(en)"

fddContainer := DiskContainer(imageDir, "i).*\.(dsk|woz|nib)$")
fddContainer.initSlot( 2 )

configStr := setConfig( imageDir, fddContainer )

; cmd := "AppleWin.exe -no-full-screen -fs-width=1600 -fs-height=1200 -no-printscreen-dlg"
; cmd := "AppleWin.exe -no-full-screen -conf apple.ini -fs-height=best -no-printscreen-dlg"
cmd := "AppleWin.exe -conf apple.ini -fs-height=best " configStr
; cmd := "AppleWin.exe -no-full-screen -conf apple.ini -fs-height=best "
debug("cmd : " cmd)

; ExitApp

Run(cmd, , , &emulatorPid)
waitEmulator()
if WinExist("ahk_class APPLE2FRAME")
{
  debug("Found window !!")
  activateEmulator()
  reset()
  waitCloseEmulator()
}

ExitApp

waitEmulator() {
  WinWait("ahk_class APPLE2FRAME", , 20)
}

activateEmulator() {
  WinActivate("ahk_class APPLE2FRAME")
}

waitCloseEmulator() {
  WinWaitClose("ahk_class APPLE2FRAME")
}

^+PGUP:: { ; Insert Disk in Drive#1
  if GetKeyState("z", "P") { ; Ctrl + Shift + Z + PgUp :: Remove Disk in Drive#1
    fddContainer.removeDisk("1", "removeDisk")
  } else { ; Ctrl + Shift + PgUp :: Insert Disk in Drive#1
    fddContainer.insertDisk("1", "insertDisk")
  }
}

^+PGDN:: { ; Insert Disk in Drive#2
  if (option.core.fdd != "2")
    return

  if GetKeyState("z", "P") { ; Ctrl + Shift + Z + PgDn :: Remove Disk in Drive#2
    fddContainer.removeDisk("2", "removeDisk")
  } else { ; Ctrl + Shift + PgDn :: Insert Disk in Drive#2
    fddContainer.insertDisk("2", "insertDisk")
  }
}

^+End:: { ; Cancel Disk Change
  fddContainer.cancel()
}

^+Del:: { ; Reset
  reset()
}

^+Insert:: { ; Toggle Speed
  Tray.showMessage("Toggle speed")
  activateEmulator()
  Send("{ScrollLock}")
}

!Enter:: { ; Toggle fullscreen
  toggleFullscreen()
}

reset() {
  activateEmulator()
  Send("{F2}")
}

toggleFullscreen() {
  activateEmulator()
  Send("{Alt Down}{Enter}{Alt Up}")
}

insertDisk(slotNo, file) {
  activateEmulator()
  if (slotNo == "1") {
    Send("{F3}")  ;FDD1
  } else if (slotNo == "2") {
    Send("{F4}")  ;FDD2
  } else {
    return
  }
  WinWait("Select Disk Image For Drive")
  if WinExist("Select Disk Image For Drive") {
    Send("!{N}")
    A_Clipboard := file
    Send("^v")
    Send("{Enter}")
  }
}

removeDisk(slotNo) {
  WinActivate("ahk_class AfxFrameOrView90s")
  if (slotNo == "1") {
    Click(1150, 150, "Right")
  } else if (slotNo == "2") {
    Click(1150, 200, "Right")
  } else {
    return
  }
  Send("{Down}{Enter}")
}

getConfig(imageDir, diskContainer) {
  dirBase := FileUtil.getDir(imageDir) "\_EL_CONFIG"
  option  := getOption(imageDir)

  config := " "
  config .= " --portable"
  config .= " --fullscreen"

  if (diskContainer.hasDisk()) {
    if (diskContainer.size() == 1) {
      ; config .= " --nogui"
    }
  }

  if (option.core.renderer == "software") {
    config .= " --cfgpath=" . Chr(34) . ".\inis-software" . Chr(34)
  }

  return config
}

getOption(imageDir) {
  dirConf := imageDir "\_EL_CONFIG"
  filePath := dirConf "\option\option.json"
  if FileExist(filePath) {
    jsonText := FileRead(filePath)
    option := JSON.load(jsonText)
    if !option.Has("core")
      option["core"] := Map()
  } else {
    option := Map("core", Map())
  }
  return option
}


setConfig(imageDir, fddContainer) {
  global option
  dirBase := imageDir "\_EL_CONFIG"
  option  := getOption(imageDir)
  fileIni := A_ScriptDir "\apple.ini"

  debug(">> option`n" . JSON.dump(option))

  config := " -no-printscreen-dlg"

  ; Default
  IniWrite("1", fileIni, "Configuration", "Custom Speed")
  IniWrite("1", fileIni, "Configuration", "ScrollLock Toggle")
  IniWrite(nvl(option.core["clock_multiplier"], "1"), fileIni, "Configuration", "Emulation Speed")

  ; fullscreen
  if (option.core.full_screen != "true") {
    config .= " -no-full-screen"
  }

  if (option.core.card_vidHD == "true") {
    IniWrite("21", fileIni, "Configuration\Slot 3", "Card type")
  } else {
    IniWrite("0", fileIni, "Configuration\Slot 3", "Card type")
  }

  ; model
  config .= " -model " nvl(option.core.model, "apple2ee")

  ; video
  IniWrite(nvl(option.core["video_mode"], ""), fileIni, "Configuration", "Video Emulation")

  ; video refresh
  config .= " -" nvl(option.core.video_refresh, "60hz")

  ; sound
  if (option.core.sound_card == "mocking_board" || option.core.sound_card == "") {
    IniWrite("3", fileIni, "Configuration\Slot 4", "Card type")
    IniWrite("3", fileIni, "Configuration\Slot 5", "Card type")
  } else if (option.core.sound_card == "phasor") {
    IniWrite("9", fileIni, "Configuration\Slot 4", "Card type")
  } else if (option.core.sound_card == "sam_dac") {
    IniWrite("11", fileIni, "Configuration\Slot 5", "Card type")
  } else if (option.core.sound_card == "no_sound") {
    IniWrite("0", fileIni, "Configuration\Slot 4", "Card type")
    IniWrite("0", fileIni, "Configuration\Slot 5", "Card type")
  }

  ; Enhance disk access speed
  IniWrite(nvl(option.core.enhance_disk_access, 1), fileIni, "Configuration", "Enhance Disk Speed")

  ; fdd
  IniDelete(fileIni, "Configuration\Slot 6", "Last Disk Image 1")
  IniDelete(fileIni, "Configuration\Slot 6", "Last Disk Image 2")
  IniDelete(fileIni, "Configuration\Slot 5", "Last Disk Image 1")
  IniDelete(fileIni, "Configuration\Slot 5", "Last Disk Image 2")
  fdCnt := fddContainer.size()
  if (option.core.fdd == "0") {
    config .= " -d1-disconnected"
    config .= " -d2-disconnected"
  } else if (option.core.fdd == "1") {
    config .= " -d2-disconnected"
    loop Min(1, fdCnt) {
      i := A_Index
      config .= " -s6d" i " " wrap(fddContainer.getFile(i))
    }
  } else if (option.core.fdd == "2") {
    loop Min(2, fdCnt) {
      i := A_Index
      config .= " -s6d" i " " wrap(fddContainer.getFile(i))
    }
  } else if (option.core.fdd == "4") {
    loop Min(2, fdCnt) {
      i := A_Index
      config .= " -s6d" i " " wrap(fddContainer.getFile(i))
    }
    if (fdCnt > 2) {
      config .= " -s5 diskii"
      loop Min(4, fdCnt) - 2 {
        i := A_Index + 2
        config .= " -s5d" (i-2) " " wrap(fddContainer.getFile(i))
      }
    }
  }

  ; hdd
  hdd := FileUtil.getFiles(imageDir, "i).*\.(po|2mg)$")
  loop hdd.Length {
    if (A_Index > 2)
      break
    config .= " -h" A_Index " " wrap(hdd[A_Index])
  }

  ; joystick
  IniWrite(nvl(option.core["joystick1"], ""), fileIni, "Configuration", "Joystick0 Emu Type v3")
  IniWrite(nvl(option.core["joystick2"], ""), fileIni, "Configuration", "Joystick1 Emu Type v3")

  IniWrite(nvl(option.core["xtrim"], 0), fileIni, "Configuration", "PDL X-Trim")
  IniWrite(nvl(option.core["ytrim"], 0), fileIni, "Configuration", "PDL Y-Trim")

  IniWrite(nvl(option.core["auto_fire"], ""), fileIni, "Configuration", "Autofire")
  IniWrite(nvl(option.core["auto_center"], ""), fileIni, "Configuration", "Joystick Centering Control")
  IniWrite(nvl(option.core["input_swap"], ""), fileIni, "Configuration", "Swap buttons 0 and 1")

  return config

}
