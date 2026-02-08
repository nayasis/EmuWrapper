#Requires AutoHotkey >=2.0
#Include ..\ZZ_Library\JSON.ahk

obj := DotMap()
FileAppend("dump=" JSON.dump(obj) "`n", "*")
obj.core := DotMap()
FileAppend("dump2=" JSON.dump(obj) "`n", "*")
ExitApp
