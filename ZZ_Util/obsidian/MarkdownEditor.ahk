#NoEnv
#include c:\app\emulator\ZZ_Library\Include.ahk

param := %0%
;param := "\\NAS2\emul\image\DOS\Worlds of Ultima - Savage Empire\_EL_CONFIG\description\game.md"

srcDir  := FileUtil.getDir(param)
srcFile := FileUtil.getName(param)
trgDir  := A_ScriptDir "\shell\description"

debug(srcDir)
debug(srcFile)

FileUtil.makeLink(srcDir, trgDir, true)

cmd := "obsidian://open?vault=shell&file=" srcFile
debug(cmd)

Run % cmd

ExitApp