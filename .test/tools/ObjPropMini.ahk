#Requires AutoHotkey >=2.0
try DllCall("AttachConsole", "UInt", -1)
obj := {}
key := "a"
obj.%key% := 1
FileAppend("has=" ObjHasOwnProp(obj, "a") " val=" obj.a "`n", "*")
