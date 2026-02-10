#Requires AutoHotkey >=2.0
#Include "..\..\ZZ_Library\Include.ahk"

TEST(dm) {
	debug("Type: " Type(dm))
	debug("Has __Enum: " HasMethod(dm, "__Enum"))
	debug("StoreHas: " DotMap._store.Has(dm))
	debug("OwnProps: " ObjOwnPropCount(dm))
	for k, v in dm
		debug("ENUM " k "=" v)

	enum := dm.__Enum()
	debug("EnumType: " Type(enum) " HasCall: " (IsObject(enum) && HasMethod(enum, "Call")))
	if (IsObject(enum) && HasMethod(enum, "Call")) {
		while enum(&k, &v)
			debug("CALLENUM " k "=" v)
	}

	raw := DotMap._store[dm]
	debug("RawType: " Type(raw) " RawOwnProps: " ObjOwnPropCount(raw))
	for k, v in raw.OwnProps()
		debug("RAWENUM " k "=" v)

	op := raw.OwnProps()
	for k, v in op
		debug("OWNENUM " k "=" v)
}

dm := DotMap()
dm["a"] := 1
dm["b"] := "x"

TEST(dm)

ExitApp
