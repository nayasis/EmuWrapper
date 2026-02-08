#Requires AutoHotkey >=2.0
#Include "%A_ScriptDir%\..\ZZ_Library\JSON.ahk"
try DllCall("AttachConsole", "UInt", -1)

s := '{"a":1}'
obj := JSON.load(s)
FileAppend("type=" Type(obj) "`n", "*")
FileAppend("hasA=" obj.Has("a") "`n", "*")
FileAppend("getA=" obj.Get("a", "<none>") "`n", "*")
