#Requires AutoHotkey >=2.0
#Include d:\app\emulator\ZZ_Library\Include.ahk

FileEncoding("UTF-8")

testIni := A_Temp "\FileUtil_test.ini"
section1 := "init"
section2 := "window"
key1 := "executor"
key2 := "commentedKey"
key3 := "searchDelay"
value1 := "G:\\game\\game.exe"
value2 := "UTF-8 한글 경로 확인"
value3 := "1500"
missingValue := "__missing__"

sample := "[init]`r`n"
sample .= "executor = old.exe`r`n"
sample .= "commentedKey = old value ; keep comment`r`n"
sample .= "`r`n"
sample .= "[window]`r`n"
sample .= "searchDelay = 500`r`n"

try FileDelete(testIni)
FileAppend(sample, testIni, "UTF-8")

FileUtil.writeIni(testIni, section1, key1, value1)
FileUtil.writeIni(testIni, section1, key2, value2)
afterWriteKey1 := FileUtil.readIni(testIni, section1, key1, missingValue)
afterWriteKey2 := FileUtil.readIni(testIni, section1, key2, missingValue)
sectionAfterWrite := FileUtil.readIni(testIni, section1)

FileUtil.writeIni(testIni, section2, key3, value3)
afterSectionWrite := FileUtil.readIni(testIni, section2, key3, missingValue)
sectionAfterSectionWrite := FileUtil.readIni(testIni, section2)

FileUtil.deleteIni(testIni, section1, key1)
afterDeleteKey1 := FileUtil.readIni(testIni, section1, key1, missingValue)
sectionAfterKeyDelete := FileUtil.readIni(testIni, section1)

FileUtil.deleteIni(testIni, section2)
afterDeleteSection := FileUtil.readIni(testIni, section2, "", "")

finalText := FileRead(testIni, "UTF-8")
commentLine := "commentedKey = UTF-8 한글 경로 확인 ; keep comment"
commentOk := InStr(finalText, commentLine) > 0

writeKey1Ok := (afterWriteKey1 == value1)
writeKey2Ok := (afterWriteKey2 == value2) && sectionAfterWrite.Has(key2)
sectionWriteOk := (afterSectionWrite == value3) && sectionAfterSectionWrite.Has(key3)
keyDeleteOk := (afterDeleteKey1 == missingValue) && !sectionAfterKeyDelete.Has(key1)
sectionDeleteOk := (Type(afterDeleteSection) != "Map")

allOk := writeKey1Ok && writeKey2Ok && sectionWriteOk && keyDeleteOk && sectionDeleteOk && commentOk
summary := "overall : " (allOk ? "PASS" : "FAIL") "`n"
summary .= "test ini : " testIni "`n`n"
summary .= formatCheck("write key1", writeKey1Ok, value1, afterWriteKey1)
summary .= formatCheck("write key2", writeKey2Ok, value2, afterWriteKey2)
summary .= formatCheck("write section key", sectionWriteOk, value3, afterSectionWrite)
summary .= formatCheck("delete key1", keyDeleteOk, missingValue, afterDeleteKey1)
summary .= formatCheck("delete section", sectionDeleteOk, "non-Map / missing section", Type(afterDeleteSection))
summary .= formatCheck("keep trailing comment", commentOk, commentLine, finalText)
summary .= "`nfinal ini text`n----------------`n" finalText

if (!allOk) {
	debug(summary)
}

formatCheck(name, ok, expected, actual) {
	line := name ": " (ok ? "PASS" : "FAIL") "`n"
	line .= "  expected: " expected "`n"
	line .= "  actual  : " actual "`n`n"
	return line
}
