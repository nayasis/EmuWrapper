#Requires AutoHotkey >=2.0
#Include d:\app\emulator\ZZ_Library\Include.ahk

FileEncoding("UTF-8")

; Keep cleanupOnSuccess := true for normal runs.
; Set cleanupOnFailure := true if you also want failed test keys/files removed.
cleanupOnSuccess := true
cleanupOnFailure := false

testId := FormatTime(, "yyyyMMddHHmmss")
baseKey := "HKEY_CURRENT_USER\Software\ZZ_Library\RegistryTest\" testId
regFile := A_Temp "\\Registry_test_" testId ".reg"
pathValue := "C:\Temp\레지스트리\Game.exe"
nameValue := "UTF-8 한글 값"
expandValue := "%USERPROFILE%\RegistryExpandTest"
keyProp := "Software\ZZ_Library\RegistryTest\" testId
binaryValueText := "DEADBEEF"
multiValueText := "alpha`nbeta`n"

multiHex := "61,00,6c,00,70,00,68,00,61,00,00,00,62,00,65,00,74,00,61,00,00,00,00,00"
expandHex := "25,00,55,00,53,00,45,00,52,00,50,00,52,00,4f,00,46,00,49,00,4c,00,45,00,25,00,5c,00,52,00,65,00,67,00,69,00,73,00,74,00,72,00,79,00,45,00,78,00,70,00,61,00,6e,00,64,00,54,00,65,00,73,00,74,00,00,00"

testReg := "Windows Registry Editor Version 5.00`r`n`r`n"
testReg .= "[HKEY_CURRENT_USER\${keyPath}]`r`n"
testReg .= '"InstallPath"="${installPath}"' "`r`n"
testReg .= '"DisplayName"="${displayName}"' "`r`n"
testReg .= '"TestDword"=dword:0000002a' "`r`n"
testReg .= '"TestBinary"=hex:de,ad,be,ef' "`r`n"
testReg .= '"TestMultiSz"=hex(7):' multiHex "`r`n"
testReg .= '"TestExpandSz"=hex(2):' expandHex "`r`n"

try FileDelete(regFile)
FileAppend(testReg, regFile, "UTF-8")

Registry.clearProps()
Registry.setProps(Map(
	"keyPath", keyProp,
	"installPath", pathValue,
	"displayName", nameValue
))
Registry.write(regFile)

actualPath := ""
actualName := ""
actualDword := ""
actualBinary := ""
actualMulti := ""
actualExpand := ""
try actualPath := RegRead(baseKey, "InstallPath")
catch
	actualPath := "__read_error__"
try actualName := RegRead(baseKey, "DisplayName")
catch
	actualName := "__read_error__"
try actualDword := RegRead(baseKey, "TestDword")
catch
	actualDword := "__read_error__"
try actualBinary := RegRead(baseKey, "TestBinary")
catch
	actualBinary := "__read_error__"
try actualMulti := RegRead(baseKey, "TestMultiSz")
catch
	actualMulti := "__read_error__"
try actualExpand := RegRead(baseKey, "TestExpandSz")
catch
	actualExpand := "__read_error__"

pathOk := (actualPath == pathValue)
nameOk := (actualName == nameValue)
dwordOk := (actualDword == 42 || actualDword == "42")
binaryOk := (actualBinary == binaryValueText)
multiOk := (actualMulti == multiValueText)
expandOk := (actualExpand == expandValue)
allOk := pathOk && nameOk && dwordOk && binaryOk && multiOk && expandOk

summary := "overall : " (allOk ? "PASS" : "FAIL") "`n"
summary .= "reg file : " regFile "`n"
summary .= "base key : " baseKey "`n`n"
summary .= formatCheck("InstallPath", pathOk, pathValue, actualPath)
summary .= formatCheck("DisplayName", nameOk, nameValue, actualName)
summary .= formatCheck("TestDword", dwordOk, "42", actualDword)
summary .= formatCheck("TestBinary", binaryOk, binaryValueText, actualBinary)
summary .= formatCheck("TestMultiSz", multiOk, multiValueText, formatMultiString(actualMulti))
summary .= formatCheck("TestExpandSz", expandOk, expandValue, actualExpand)
summary .= "`nreg source`n----------`n" testReg

cleanupNow := allOk ? cleanupOnSuccess : cleanupOnFailure
if (cleanupNow)
	cleanupArtifacts(baseKey, regFile)

if (!allOk)
	debug(summary)

cleanupArtifacts(baseKey, regFile) {
	try RunWait(A_ComSpec ' /c reg delete "' baseKey '" /f', , "Hide")
	try FileDelete(regFile)
}

formatMultiString(value) {
	return StrReplace(value, "`n", " / ")
}

formatCheck(name, ok, expected, actual) {
	line := name ": " (ok ? "PASS" : "FAIL") "`n"
	line .= "  expected: " expected "`n"
	line .= "  actual  : " actual "`n`n"
	return line
}
