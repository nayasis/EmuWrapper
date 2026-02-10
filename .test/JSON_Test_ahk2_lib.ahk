#Requires AutoHotkey >=2.0
#ErrorStdOut
#Include "D:\project\ahk2_lib\JSON.ahk"
#Include "D:\app\emulator\ZZ_Library\Common.ahk"

print(msg) {
	FileAppend(msg "`n", "**")
}

jsonStrA := '{"key":"key-1","val":"val-1"}'

jsonStrB := '{"val":"val-2","inner":{"key":"key-inner-1","val":"val-inner-1"}}'

objA := JSON.parse(jsonStrA)        ; Map
objB := JSON.parse(jsonStrB)        ; Map
objC := JSON.parse(jsonStrB, false, false)  ; Object

print("stringify !!")
print(JSON.stringify(objA))
print(JSON.stringify(objB))

print(objA.key)
print(objB["inner"]["key"])
print(objC.inner.key)
print("------------")

t := ""
for key, val in objB
	t .= key ":" (IsObject(val) ? JSON.stringify(val) : val) "`n"
print(t)

ExitApp
