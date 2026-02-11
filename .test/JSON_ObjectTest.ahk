#Requires AutoHotkey v2.0
#Include "..\ZZ_Library\Debugging.ahk"
#Include "..\ZZ_Library\JSON.ahk"

jsonText := '{"key": 1, "nested": {"a": 2}}'
obj := JSON.parse(jsonText)

Assert(obj is JSON.Obj, "parse returns JSON.Obj")
Assert(obj["key"] = 1, "obj[key] read")
Assert(obj.key = 1, "obj.key read")

obj.key := 2
Assert(obj["key"] = 2, "obj.key write")

Assert(obj.has("key"), "obj.has")
Assert(obj.get("key") = 2, "obj.get")
Assert(obj.get("missing", 99) = 99, "obj.get default")

Assert(obj.delete("key"), "obj.delete true")
Assert(!obj.has("key"), "obj.delete removes")

Assert(obj.nested is JSON.Obj, "nested object type")
Assert(obj.nested.a = 2, "nested access")

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

objA := JSON.parse(jsonStrA)
objB := JSON.parse(jsonStrB)

Assert(objA.key = "key-1", "objA.key")
Assert(objA.val = "val-1", "objA.val")
Assert(objB.val = "val-2", "objB.val")
Assert(objB.inner is JSON.Obj, "objB.inner type")
Assert(objB.inner.key = "key-inner-1", "objB.inner.key")
Assert(objB["inner"]["val"] = "val-inner-1", "objB[inner][val]")

; Ensure iteration works for JSON.Obj
keys := Map()
for key, val in objB
	keys[key] := IsObject(val) ? JSON.stringify(val) : val
Assert(keys.Has("val"), "iter includes val")
Assert(keys.Has("inner"), "iter includes inner")

; If no error, the test passes.
