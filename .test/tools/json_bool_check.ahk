#Requires AutoHotkey >=2.0
#Include "D:\app\emulator\ZZ_Library\Include.ahk"
jsonFile := "D:\app\emulator\.test\tools\json_bool_check.json"
FileDelete(jsonFile)
FileAppend('{"a":true,"b":false,"c":null}', jsonFile)
obj := FileUtil.readJson(jsonFile)
FileDelete("D:\app\emulator\.test\tools\json_bool_check.out.txt")
FileAppend(JSON.stringify(obj), "D:\app\emulator\.test\tools\json_bool_check.out.txt")
