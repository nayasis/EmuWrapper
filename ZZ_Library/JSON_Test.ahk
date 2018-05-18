#NoEnv
#include %A_ScriptDir%\Include.ahk

jsonStrA =
(
{
	"key" : "key-1",
	"val" : "val-1"
}
)

jsonStrB =
(
{
	"val" : "val-2",
	"inner" : {
		"key" : "key-inner-1",
		"val" : "val-inner-1"
	}
}
)

objA := JSON.load( jsonStrA )
objB := JSON.load( jsonStrB )

debug( "dump !!")
debug( JSON.dump(objA) )
debug( JSON.dump(objB) )

debug( objA.key )

debug( objB[ "inner", "key" ] )
debug( "------------")

enum := objB._NewEnum()

While enum[key, val]
    t .= key ":" val "`n"

debug( t )

ExitApp
