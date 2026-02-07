#Requires AutoHotkey >=2.0
#Include %A_ScriptDir%\..\..\ZZ_Library\Include.ahk

pathRoot := "\\NAS\emul\image\PC98"

debug(">> start")

files := FileUtil.getFiles(pathRoot, "i).*\.(d88|fdd|fdi)$", false, -1)
srcDirs := Map()

debug(">> read files")
loop files.Length {
  fileSrc := files[A_Index]
  srcDir := FileUtil.getDir(fileSrc)

  if (!srcDirs.Has(srcDir)) {
    srcDirs[srcDir] := []
  }
  srcDirs[srcDir].Push(fileSrc)
  debug(srcDir " :: " fileSrc)
}

debug(">> write m3u")

for srcDir, dirFiles in srcDirs {
  debug(srcDir " has " dirFiles.Length)
  if (dirFiles.Length <= 1)
    continue
  fileM3u := srcDir "/multi-disk.m3u"
  m3uText := ""
  for idx, fileName in dirFiles {
    m3uText .= FileUtil.getName(fileName) "`n"
    debug("`t " FileUtil.getName(fileName))
  }
  FileUtil.delete(fileM3u)
  FileAppend(m3uText, fileM3u)
}

debug(">> end")

ExitApp
