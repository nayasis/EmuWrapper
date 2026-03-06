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

	static setAllTray(yn) {
		this.allTray := (yn == true)
	}

	static toggle() {
		if (this.isHidden())
			this.show()
		else
			this.hide()
	}

	static show(forcibly := false) {
		if (!WinExist("ahk_class Shell_TrayWnd")) {
			if (forcibly == false)
				return
		}
		APPBARDATA := Buffer(48, 0)
		NumPut("UInt", 48, APPBARDATA, 0)
		NumPut("UInt", 0x2, APPBARDATA, 32)
		DllCall("Shell32.dll\SHAppBarMessage", "UInt", 0xA, "Ptr", APPBARDATA)
		if WinExist("ahk_class Shell_TrayWnd")
			WinShow("ahk_class Shell_TrayWnd")
		if (this.allTray == true && WinExist("ahk_class Shell_SecondaryTrayWnd"))
			WinHide("ahk_class Shell_SecondaryTrayWnd")
		if WinExist("Start ahk_class Button")
			WinShow("Start ahk_class Button")
	}

	static hide(forcibly := false) {
		if (!WinExist("ahk_class Shell_TrayWnd")) {
			if (forcibly == false)
				return
		}
		APPBARDATA := Buffer(48, 0)
		NumPut("UInt", 48, APPBARDATA, 0)
		NumPut("UInt", 0x1, APPBARDATA, 32)
		DllCall("Shell32.dll\SHAppBarMessage", "UInt", 0xA, "Ptr", APPBARDATA)
		if WinExist("ahk_class Shell_TrayWnd")
			WinHide("ahk_class Shell_TrayWnd")
		if (this.allTray == true && WinExist("ahk_class Shell_SecondaryTrayWnd"))
			WinShow("ahk_class Shell_SecondaryTrayWnd")
		if WinExist("Start ahk_class Button")
			WinHide("Start ahk_class Button")
	}

	static isHidden() {
		return !WinExist("ahk_class Shell_TrayWnd")
	}
}
