#Requires AutoHotkey >=2.0
#Include Common.ahk

class Taskbar {
	static _init() {
		Taskbar.allTray := false
	}
	static void := Taskbar._init()

	__New() {
		throw Error("Taskbar is a static class, dont instantiate it!", -1)
	}

	setAllTray(yn) {
		this.allTray := (yn == true)
	}

	toggle() {
		if (this.isHidden())
			this.show()
		else
			this.hide()
	}

	show(forcibly := false) {
		if (!WinExist("ahk_class Shell_TrayWnd")) {
			if (forcibly == false)
				return
		}
		APPBARDATA := Buffer(48, 0)
		NumPut("UInt", 48, APPBARDATA, 0)
		NumPut("UInt", 0x2, APPBARDATA, 32)
		DllCall("Shell32.dll\SHAppBarMessage", "UInt", 0xA, "Ptr", APPBARDATA)
		WinShow("ahk_class Shell_TrayWnd")
		if (this.allTray == true)
			WinHide("ahk_class Shell_SecondaryTrayWnd")
		WinShow("Start ahk_class Button")
	}

	hide(forcibly := false) {
		if (!WinExist("ahk_class Shell_TrayWnd")) {
			if (forcibly == false)
				return
		}
		APPBARDATA := Buffer(48, 0)
		NumPut("UInt", 48, APPBARDATA, 0)
		NumPut("UInt", 0x1, APPBARDATA, 32)
		DllCall("Shell32.dll\SHAppBarMessage", "UInt", 0xA, "Ptr", APPBARDATA)
		WinHide("ahk_class Shell_TrayWnd")
		if (this.allTray == true)
			WinShow("ahk_class Shell_SecondaryTrayWnd")
		WinHide("Start ahk_class Button")
	}

	isHidden() {
		return !WinExist("ahk_class Shell_TrayWnd")
	}
}
