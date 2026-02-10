#Requires AutoHotkey >=2.0
#Include "%A_ScriptDir%\..\..\ZZ_Library\Include.ahk"

m := Map("a", 1, "b", Map("c", 2))
arr := [1, 2, "x", Map("k", "v")]
obj := Object()
obj.x := 10
obj.y := [1, 2]
dm := DotMap(Map("p", 1, "q", [2, 3]))

debug("Map: ", m)
debug("Array: ", arr)
debug("Object: ", obj)
debug("DotMap: ", dm)
debug("String: ", "hello", " Number: ", 42)

ExitApp
