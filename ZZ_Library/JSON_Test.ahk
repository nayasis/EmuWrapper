#Requires AutoHotkey >=2.0
#Include %A_ScriptDir%\Include.ahk

jsonStrA := "
(LTrim
{
	"key" : "key-1",
	"val" : "val-1"
}
)"

jsonStrB := "
(LTrim
{
	"val" : "val-2",
	"inner" : {
		"key" : "key-inner-1",
		"val" : "val-inner-1"
	}
}
)"

debug("jsonStrA=" jsonStrA)
debug("jsonStrB=" jsonStrB)
objA := JSON.parse(jsonStrA)
objB := JSON.parse(jsonStrB)

debug("dump !!")
debug(JSON.stringify(objA))
debug(JSON.stringify(objB))

debug(objA.key)
debug(objB["inner"]["key"])
debug(objB.inner.key)
debug("------------")

t := ""
for key, val in objB
	t .= key ":" (IsObject(val) ? JSON.stringify(val) : val) "`n"

debug(t)

ExitApp
