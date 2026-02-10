class DotMap {
	__New(args*) {
		if !DotMap._store.Has(this)
			DotMap._store[this] := {}
		if (args.Length == 0)
			return
		if (args.Length == 1 && (Type(args[1]) == "Object" || args[1] is Map)) {
			DotMap._store[this] := args[1]
			return
		}
		if (Mod(args.Length, 2) != 0)
			throw Error("DotMap() expects Map or key/value pairs", -1)
		m := DotMap._store[this]
		i := 1
		while (i <= args.Length) {
			m.%args[i]% := DotMap._unwrap(args[i + 1])
			i += 2
		}
	}

	__Get(name, params) {
		m := DotMap._store[this]
		if (Type(m) == "Map") {
			if (!m.Has(name))
				return ""
			val := m[name]
		} else {
			if (!ObjHasOwnProp(m, name))
				return ""
			val := m.%name%
		}
		return IsObject(val) ? (val is DotMap ? val : DotMap(val)) : val
	}

	__Set(name, params, value) {
		m := DotMap._store[this]
		if (Type(m) == "Map")
			m[name] := DotMap._unwrap(value)
		else
			m.%name% := DotMap._unwrap(value)
		return value
	}

	__Item[key] {
		get {
			m := DotMap._store[this]
			if (Type(m) == "Map") {
				if (m.Has(key)) {
					val := m[key]
					return IsObject(val) ? (val is DotMap ? val : DotMap(val)) : val
				}
			} else if (ObjHasOwnProp(m, key)) {
				val := m.%key%
				return IsObject(val) ? (val is DotMap ? val : DotMap(val)) : val
			}
			return ""
		}
		set {
			m := DotMap._store[this]
			if (Type(m) == "Map")
				m[key] := DotMap._unwrap(value)
			else
				m.%key% := DotMap._unwrap(value)
			return value
		}
	}

	__Enum(n := 1) {
		try {
			m := DotMap._store[this]
			return m.__Enum(n)
		} catch {
			m := Map()
			return m.__Enum(n)
		}
	}

	Has(key) {
		m := DotMap._store[this]
		return (Type(m) == "Map") ? m.Has(key) : ObjHasOwnProp(m, key)
	}

	Get(key, default := "") {
		m := DotMap._store[this]
		if (Type(m) == "Map")
			return m.Has(key) ? m[key] : default
		return ObjHasOwnProp(m, key) ? m.%key% : default
	}

	Delete(key) {
		return DotMap._store[this].Delete(key)
	}

	raw() {
		return DotMap._store[this]
	}

	static _unwrap(val) {
		return (val is DotMap) ? val.raw() : val
	}

	static _store := Map()
}

