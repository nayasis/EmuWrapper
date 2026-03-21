#Requires AutoHotkey >=2.0

outputPath := A_ScriptDir "\utf8_output.ini"
content := "[init]`nexecutor = 테스트.exe"

writeUtf8(outputPath, content)
ExitApp

writeUtf8(path, content := "") {
	SplitPath(path, , &parentDir)
	DirCreate(parentDir)
	try FileDelete(path)
	FileAppend(content, path, "UTF-8")
}
