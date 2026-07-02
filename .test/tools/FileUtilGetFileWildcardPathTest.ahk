#Requires AutoHotkey >=2.0
#Include d:\app\emulator\ZZ_Library\Include.ahk

testRoot := A_Temp "\FileUtil_getFileWildcardPath_test"
usrDir   := testRoot "\hdd\NPJB00521\USRDIR"
eboot    := usrDir "\EBOOT.BIN"

try DirDelete(testRoot, true)
DirCreate(usrDir)
FileAppend("test", eboot)

actual := FileUtil.getFile(testRoot "\hdd\.*\USRDIR", "i).*\.(bin)$")
ok := (actual == eboot)

writeOut("getFile wildcard path: " (ok ? "PASS" : "FAIL"))
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
