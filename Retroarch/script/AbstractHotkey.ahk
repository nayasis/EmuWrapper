#Requires AutoHotkey >=2.0

global onChangeDisk := false

sendHotKey(key) {
	Send("{AppsKey down}")
	Sleep(20)
	Send("{" key " down}")
	Sleep(20)
	Send("{" key " up}")
	Sleep(20)
	Send("{AppsKey up}")
	Sleep(20)
}

^+Del:: {
	debug("Reset")
	Tray.showMessage("Reset")
	activateEmulator()
	sendHotKey("H")
}

^+Insert:: {
	Tray.showMessage("Toggle speed")
	activateEmulator()
	sendHotKey("space")
}

!Enter:: {
	debug("Toggle fullscreen")
	activateEmulator()
	sendHotKey("f")
}

^+PGUP:: {
	global diskContainer, onChangeDisk
	if (diskContainer.size() <= 1 || onChangeDisk)
		return
	if (diskContainer.slot[0] >= diskContainer.size()) {
		Tray.showMessage("It is last disc")
		return
	}
	diskContainer.slot[0] += 1
	Tray.showMessage("Next disk`n`n" diskContainer.container[diskContainer.slot[0]])
	onChangeDisk := true
	BlockInput(true)
	activateEmulator()
	sendHotKey("/")
	sendHotKey(".")
	sendHotKey("/")
	onChangeDisk := false
	BlockInput(false)
}

^+PGDN:: {
	global diskContainer, onChangeDisk
	if (diskContainer.size() <= 1 || onChangeDisk)
		return
	if (diskContainer.slot[0] <= 1) {
		Tray.showMessage("It is first disc")
		return
	}
	diskContainer.slot[0] -= 1
	Tray.showMessage("Previous disc`n`n" diskContainer.container[diskContainer.slot[0]])
	onChangeDisk := true
	BlockInput(true)
	activateEmulator()
	sendHotKey("/")
	sendHotKey(",")
	sendHotKey("/")
	onChangeDisk := false
	BlockInput(false)
}
