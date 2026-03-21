#Requires AutoHotkey >=2.0
#Include "D:\app\emulator\ZZ_Library\Include.ahk"
jsonText := '{  "system" : {`n    "fullscreen" : "true",`n    "language" : "Japanese",`n    "region" : "Korea"`n  }`n}'
option := JSON.parse(jsonText)
FileDelete("D:\\app\\emulator\\.test\\tools\\json_stringify_check.out.txt")
FileAppend(JSON.stringify(option, 10000000, "    "), "D:\\app\\emulator\\.test\\tools\\json_stringify_check.out.txt")
