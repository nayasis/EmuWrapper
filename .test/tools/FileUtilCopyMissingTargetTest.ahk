#Requires AutoHotkey >=2.0
#Include d:\app\emulator\ZZ_Library\Include.ahk

testRoot := A_Temp "\FileUtil_copyMissingTarget_test"
srcFile := testRoot "\source.bin"
trgFile := testRoot "\nested\target.bin"

try DirDelete(testRoot, true)
DirCreate(testRoot)
FileAppend("test", srcFile)

ok := false
errorMessage := ""
try {
	FileUtil.copy(srcFile, trgFile)
	ok := FileExist(trgFile) != "" && FileRead(trgFile) == "test"
} catch as e {
	errorMessage := e.Message
}

writeOut("copy to missing parent: " (ok ? "PASS" : "FAIL"))
if (errorMessage != "")
	writeOut("error: " errorMessage)

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
