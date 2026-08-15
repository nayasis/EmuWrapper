#Requires AutoHotkey >=2.0
#Include %A_ScriptDir%\..\..\ZZ_Library\FileUtil.ahk

imageDir := A_Args.Length ? A_Args[1] : ""

tempRoot := "f:\_temp"
tempIso := tempRoot "\iso"
tempPbp := tempRoot "\pbp"

FileUtil.delete(tempRoot)
FileUtil.makeDir(tempIso)
FileUtil.makeDir(tempPbp)

toIso(imageDir, tempIso)
toPbp(tempIso, tempPbp)
renamePbp(tempPbp, tempRoot, imageDir)

FileUtil.delete(tempIso)
FileUtil.delete(tempPbp)

ExitApp

debug(message) {
  if (A_IsCompiled == 1)
    return
  message .= "`n"
  FileAppend(message, "*")
}

toIso(dirChd, dirIso) {
  chdFiles := FileUtil.findFiles(dirChd, "(?i).*\.chd$", false, -1)
  for i, file in chdFiles {
    isoName := FileUtil.getName(file, false)
    target := dirIso "\" isoName
    RunWait('"' A_ScriptDir '\lib\chdman.exe" extractcd -i "' file '" -o "' target '.cue" -ob "' target '.bin"')
  }
}

toPbp(dirIso, dirPbp) {
  pidPsx2psp := Run('"' A_ScriptDir '\lib\PSX2PSP v1.4.2\PSX2PSP.exe" /batch')
  WinWait("ahk_exe PSX2PSP.exe")
  WinActivate()
  A_Clipboard := dirIso
  Sleep(1000)
  Send("^v")
  Sleep(1000)
  Send("{Tab}")
  Sleep(100)
  A_Clipboard := dirPbp
  Sleep(100)
  Send("^v")
  Sleep(100)
  Send("{Tab}{Tab}{Enter}")
  Sleep(1000)

  loop {
    message := ControlGetText("TStatusBar1", "ahk_exe PSX2PSP.exe")
    if (message == "Done.")
      break
    Sleep(300)
  }
  ProcessClose(pidPsx2psp)
}

renamePbp(dirPbp, targetDir, dirChd) {
  pbpFile := FileUtil.findFile(dirPbp, "(?i).*\.pbp$", false, -1)
  fileName := FileUtil.getName(dirChd)
  fileExt := FileUtil.getExt(pbpFile)
  renamedFile := targetDir "\" fileName "." fileExt
  debug(pbpFile " -> " renamedFile)
  FileUtil.move(pbpFile, renamedFile)
}
