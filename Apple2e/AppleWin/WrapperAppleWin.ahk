#Requires AutoHotkey >=2.0
#Include "%A_ScriptDir%\..\..\ZZ_Library\Include.ahk"

global option

imageDir  := A_Args.Length > 0 ? A_Args[1] : ""
;imageDir  := "\\NAS2\emul\image\Apple2\Threshold (on-line)(en)"
;imageDir  := "\\NAS\emul\image\Apple2\RPG\Times of Lore (en)"
;imageDir  := "\\NAS\emul\image\Apple2\Shooting\Wings of Fury (en)"
;imageDir  := "\\NAS2\emul\image\Apple2\Neuromancer"
;imageDir  := "\\NAS2\emul\image\Apple2\Star Rank Boxing II (gamestar)(en)"

fddContainer := DiskContainer(imageDir, "i).*\.(dsk|woz|nib)$")
fddContainer.initSlot( 2 )

appendConfig := setConfig(imageDir, fddContainer)

;cmd := "AppleWin.exe -conf apple.ini -fs-height=best " configStr
cmd := "AppleWin.exe -conf apple.ini " appendConfig
debug("cmd: " cmd)

; ExitApp

Run(cmd, , , &emulatorPid)
waitEmulator()
if WinExist("ahk_class APPLE2FRAME") {
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
  if (option["core"].Get("fdd", "") != "2")
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
  core    := option["core"]

  config := " "
  config .= " --portable"
  config .= " --fullscreen"

  if (diskContainer.hasDisk()) {
    if (diskContainer.size() == 1) {
      ; config .= " --nogui"
    }
  }

  if (core.Get("renderer", "") == "software") {
    config .= " --cfgpath=" . Chr(34) . ".\inis-software" . Chr(34)
  }

  return config
}

getOption(imageDir) {
  dirConf := imageDir "\_EL_CONFIG"
  filePath := dirConf "\option\option.json"
  if FileExist(filePath) {
    jsonText := FileRead(filePath)
    option := JSON.parse(jsonText)
    if !option.Has("core")
      option["core"] := JSON.Obj()
  } else {
    option := JSON.Obj()
    option.core := JSON.Obj()
  }
  return option
}


setConfig(imageDir, fddContainer) {
  global option
  dirBase := imageDir "\_EL_CONFIG"
  option  := getOption(imageDir)
  core    := option["core"]
  fileIni := A_ScriptDir "\apple.ini"

  debug(">> option`n" . JSON.stringify(option))

  config := " -no-printscreen-dlg"

  ; Default
  IniWrite("0", fileIni, "Configuration", "Custom Speed")
  IniWrite("0", fileIni, "Configuration", "Confirm Reboot")
  IniWrite(core.Get("clock_multiplier", "1"), fileIni, "Configuration", "Emulation Speed")

  ; Starting Directory
  IniWrite(imageDir, fileIni, "Preferences", "HDV Starting Directory")
  IniWrite(imageDir, fileIni, "Preferences", "Starting Directory")

  ; fullscreen
  if (core.Get("full_screen", "") != "true") {
    config .= " -no-full-screen"
  }

  if (core.Get("card_vidHD", "") == "true") {
    IniWrite("21", fileIni, "Configuration\Slot 3", "Card type")
  } else {
    IniWrite("0", fileIni, "Configuration\Slot 3", "Card type")
  }

  ; model
  config .= " -model " nvl(core.Get("model", ""), "apple2ee")

  ; video
  IniWrite(core.Get("video_mode", ""), fileIni, "Configuration", "Video Emulation")

  ; video refresh
  config .= " -" nvl(core.Get("video_refresh", ""), "60hz")

  ; sound
  if (core.Get("sound_card", "") == "mocking_board" || core.Get("sound_card", "") == "") {
    IniWrite("3", fileIni, "Configuration\Slot 4", "Card type")
    IniWrite("3", fileIni, "Configuration\Slot 5", "Card type")
  } else if (core.Get("sound_card", "") == "phasor") {
    IniWrite("9", fileIni, "Configuration\Slot 4", "Card type")
  } else if (core.Get("sound_card", "") == "sam_dac") {
    IniWrite("11", fileIni, "Configuration\Slot 5", "Card type")
  } else if (core.Get("sound_card", "") == "no_sound") {
    IniWrite("0", fileIni, "Configuration\Slot 4", "Card type")
    IniWrite("0", fileIni, "Configuration\Slot 5", "Card type")
  }

  ; Enhance disk access speed
  IniWrite(nvl(core.Get("enhance_disk_access", ""), 1), fileIni, "Configuration", "Enhance Disk Speed")

  ; fdd
  IniDelete(fileIni, "Configuration\Slot 6", "Last Disk Image 1")
  IniDelete(fileIni, "Configuration\Slot 6", "Last Disk Image 2")
  IniDelete(fileIni, "Configuration\Slot 5", "Last Disk Image 1")
  IniDelete(fileIni, "Configuration\Slot 5", "Last Disk Image 2")

  fdCnt := fddContainer.size()

  if (core.Get("fdd", "") == "0") {
    config .= " -d1-disconnected"
    config .= " -d2-disconnected"
  } else if (core.Get("fdd", "") == "1") {
    config .= " -d2-disconnected"
    loop Min(1, fdCnt) {
      i := A_Index
      config .= " -s6d" i " " wrap(fddContainer.getFile(i))
    }
  } else if (core.Get("fdd", "") == "2") {
    loop Min(2, fdCnt) {
      i := A_Index
      config .= " -s6d" i " " wrap(fddContainer.getFile(i))
    }
  } else if (core.Get("fdd", "") == "4") {
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
  hdd := FileUtil.findFiles(imageDir, "i).*\.(po|2mg)$")
  loop hdd.Length {
    if (A_Index > 2)
      break
    config .= " -h" A_Index " " wrap(hdd[A_Index])
  }

  ; joystick
  IniWrite(core.Get("joystick1", ""), fileIni, "Configuration", "Joystick0 Emu Type v3")
  IniWrite(core.Get("joystick2", ""), fileIni, "Configuration", "Joystick1 Emu Type v3")

  IniWrite(nvl(core.Get("xtrim", ""), 0), fileIni, "Configuration", "PDL X-Trim")
  IniWrite(nvl(core.Get("ytrim", ""), 0), fileIni, "Configuration", "PDL Y-Trim")

  IniWrite(core.Get("auto_fire", ""), fileIni, "Configuration", "Autofire")
  IniWrite(core.Get("auto_center", ""), fileIni, "Configuration", "Joystick Centering Control")
  IniWrite(core.Get("input_swap", ""), fileIni, "Configuration", "Swap buttons 0 and 1")

  return config

}
