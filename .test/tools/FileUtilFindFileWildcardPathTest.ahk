#Requires AutoHotkey >=2.0
#Include d:\app\emulator\ZZ_Library\Include.ahk

testRoot := A_Temp "\FileUtil_getFileWildcardPath_test"
usrDir   := testRoot "\hdd\NPJB00521\USRDIR"
eboot    := usrDir "\EBOOT.BIN"
readme   := testRoot "\hdd\NPJB00521\README.txt"

try DirDelete(testRoot, true)
DirCreate(usrDir)
FileAppend("test", eboot)
FileAppend("ignored", readme)

actual := FileUtil.findFile(testRoot "\hdd\.*\USRDIR", "i).*\.(bin)$")
dirs := FileUtil.findDirs(testRoot "\hdd\NPJB00521")
firstDir := FileUtil.findDir(testRoot "\hdd\NPJB00521", "i).*\\USRDIR$")
ok := (actual == eboot && dirs.Length == 1 && dirs[1] == usrDir && firstDir == usrDir)

writeOut("findFile/findDir: " (ok ? "PASS" : "FAIL"))
writeOut("expected: " eboot)
writeOut("actual  : " actual)

try DirDelete(testRoot, true)

if (!ok)
	ExitApp(1)

writeOut(message) {
	logFile := EnvGet("AHK_STDOUT_LOG")
	if (logFile != "") {
		FileAppend(message "`n", logFile)
	} else {
		FileAppend(message "`n", "*")
	}
}
