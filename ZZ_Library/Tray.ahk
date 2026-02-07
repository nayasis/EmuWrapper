#Requires AutoHotkey >=2.0

/**
 * Tray
 */
class Tray {

  static _init() {
  }
  static void := Tray._init()
  static _notifGui := ""

	__New() {
	    throw Error("Tray is a static class, don't instantiate it!", -1)
	}

  /**
   * show tray notification
   */
	showMessage(title, message := "", duration := 2000) {
		this.hideMessage()
		debug(message)

		notifGui := Gui("-Caption +ToolWindow +AlwaysOnTop")
		notifGui.BackColor := "ffffff"
		notifGui.SetFont("s10 bold")
		notifGui.Add("Text", "cBlue w200", title)
		notifGui.SetFont("s8 Normal")
		notifGui.Add("Text", "w200", message)
		notifGui.Show("NoActivate y9999")
		WinGetPos(,, &vWidth, &vHeight, notifGui)
		WinMove(notifGui.Hwnd,, A_ScreenWidth - vWidth, A_ScreenHeight - vHeight)

		Tray._notifGui := notifGui
		SetTimer(() => Tray.hideMessage(), -duration)
	}

	/**
	 * Hide tray notification
	 */
	hideMessage() {
		SetTimer(() => Tray.hideMessage(), 0)
		if (Tray._notifGui != "") {
			try Tray._notifGui.Destroy()
			Tray._notifGui := ""
		}
	}

  /**
   * Print tray icon information
   */
	printIcons(execNameOrPid := "") {
		icons := this.getIcons(execNameOrPid)
		infoText := ""
		for index, element in icons {
			element["tooltip"] := RegExReplace(element["tooltip"], "\n", "`n`t")
			infoText .= "idx: " . element["idx"]
			infoText .= " | cmdID: " . element["cmdID"]
			infoText .= " | pId: " . element["pId"]
			infoText .= " | uId: " . element["uId"]
			infoText .= " | msgId : " . element["msgId"]
			infoText .= " | hIcon : " . element["hIcon"]
			infoText .= " | hWnd: " . element["hWnd"]
			infoText .= " | class: " . element["class"]
			infoText .= " | tray: " . element["tray"]
			infoText .= " | process: " . element["process"] . "`n"
			infoText .= "tooltip: `t" . element["tooltip"] . "`n`n"
		}
		MsgBox(infoText)
	}

  /**
   * Get tray icon information
   */
	getIcons(execNameOrPid := "") {
		Setting_A_DetectHiddenWindows := A_DetectHiddenWindows
		DetectHiddenWindows(true)

		trayIcons := []

		for trayClass in ["Shell_TrayWnd", "NotifyIconOverflowWindow"] {
			pidTaskbar := WinGetPID("ahk_class " trayClass)
			if (!pidTaskbar)
				continue

			hProc := DllCall("OpenProcess", "UInt", 0x38, "Int", 0, "UInt", pidTaskbar, "Ptr")
			pRB := DllCall("VirtualAllocEx", "Ptr", hProc, "Ptr", 0, "UInt", 20, "UInt", 0x1000, "UInt", 0x4, "Ptr")
			if (!pRB) {
				DllCall("CloseHandle", "Ptr", hProc)
				continue
			}

			btnCount := SendMessage(0x418, 0, 0, "ToolbarWindow321", "ahk_class " trayClass)
			szBtn := (A_PtrSize = 8) ? 32 : 24
			szNfo := (A_PtrSize = 8) ? 32 : 24
			szTip := 128 * 2
			btn := Buffer(szBtn)
			nfo := Buffer(szNfo)
			tip := Buffer(szTip)

			loop btnCount {
				SendMessage(0x417, A_Index - 1, pRB, "ToolbarWindow321", "ahk_class " trayClass)
				DllCall("ReadProcessMemory", "Ptr", hProc, "Ptr", pRB, "Ptr", btn, "UInt", szBtn, "UInt*", 0)

				dwData := NumGet(btn, (A_PtrSize = 8) ? 16 : 12, "Ptr")
				iString := NumGet(btn, (A_PtrSize = 8) ? 24 : 16, "Ptr")

				DllCall("ReadProcessMemory", "Ptr", hProc, "Ptr", dwData, "Ptr", nfo, "UInt", szNfo, "UInt*", 0)

				hWnd := NumGet(nfo, 0, "Ptr")
				uID := NumGet(nfo, (A_PtrSize = 8) ? 8 : 4, "UInt")
				msgID := NumGet(nfo, (A_PtrSize = 8) ? 12 : 8, "UInt")
				hIcon := NumGet(nfo, (A_PtrSize = 8) ? 24 : 20, "Ptr")

				pID := WinGetPID("ahk_id " hWnd)
				sProcess := WinGetProcessName("ahk_id " hWnd)
				sClass := WinGetClass("ahk_id " hWnd)

				if (!execNameOrPid || (execNameOrPid = sProcess) || (execNameOrPid = pID)) {
					DllCall("ReadProcessMemory", "Ptr", hProc, "Ptr", iString, "Ptr", tip, "UInt", szTip, "UInt*", 0)
					tooltipText := StrGet(tip, "UTF-16")
					trayIcons.Push(Map(
						"idx", A_Index - 1,
						"cmdID", NumGet(btn, 4, "UInt"),
						"pId", pID,
						"uId", uID,
						"msgId", msgID,
						"hIcon", hIcon,
						"hWnd", hWnd,
						"class", sClass,
						"process", sProcess,
						"tooltip", tooltipText,
						"tray", trayClass
					))
				}
			}

			DllCall("VirtualFreeEx", "Ptr", hProc, "Ptr", pRB, "UInt", 0, "UInt", 0x8000)
			DllCall("CloseHandle", "Ptr", hProc)
		}

		DetectHiddenWindows(Setting_A_DetectHiddenWindows)
		return trayIcons
	}

  /**
   * Click tray icon
   */
	clickIcon(execNameOrPid := "", buttonName := "L", isDoubleClick := false, iconIndex := 1) {
		Setting_A_DetectHiddenWindows := A_DetectHiddenWindows
		DetectHiddenWindows(true)

		icons := this.getIcons(execNameOrPid)
		if (icons.Length < 1)
			return

		msgID := icons[iconIndex]["msgId"]
		uID := icons[iconIndex]["uId"]
		hWnd := icons[iconIndex]["hWnd"]

		msgDown := (buttonName = "L") ? 0x0201 : (buttonName = "R") ? 0x0204 : 0x0207
		msgUp := (buttonName = "L") ? 0x0202 : (buttonName = "R") ? 0x0205 : 0x0208
		msgDbl := (buttonName = "L") ? 0x0203 : (buttonName = "R") ? 0x0206 : 0x0209

		if (isDoubleClick)
			PostMessage(msgID, uID, msgDbl, "ahk_id " hWnd)
		else {
			PostMessage(msgID, uID, msgDown, "ahk_id " hWnd)
			PostMessage(msgID, uID, msgUp, "ahk_id " hWnd)
		}

		DetectHiddenWindows(Setting_A_DetectHiddenWindows)
	}
}
