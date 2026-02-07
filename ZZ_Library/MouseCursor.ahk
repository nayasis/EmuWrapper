#Requires AutoHotkey >=2.0

class MouseCursor {

  static _setSystemCursor(OnOff := 1) {
    static AndMask := 0, XorMask := 0, cursorMode := "", h_cursor := 0
    static c := [], h := [], b := []

    if (OnOff = "Init" || OnOff = "I" || cursorMode = "") {
      cursorMode := "h"
      h_cursor := Buffer(4444, 1)
      AndMask := Buffer(32*4, 0xFF)
      XorMask := Buffer(32*4, 0)
      c := [32512, 32513, 32514, 32515, 32516, 32642, 32643, 32644, 32645, 32646, 32648, 32649, 32650]
      h := [], b := []

      loop c.Length {
        i := A_Index
        h_cursor := DllCall("LoadCursor", "Ptr", 0, "Ptr", c[i], "Ptr")
        h[i] := DllCall("CopyImage", "Ptr", h_cursor, "UInt", 2, "Int", 0, "Int", 0, "UInt", 0, "Ptr")
        b[i] := DllCall("CreateCursor", "Ptr", 0, "Int", 0, "Int", 0, "Int", 32, "Int", 32, "Ptr", AndMask, "Ptr", XorMask, "Ptr")
      }
    }
    if (OnOff = 0 || OnOff = "Off" || (cursorMode = "h" && ((OnOff is Number && OnOff < 0) || OnOff = "Toggle" || OnOff = "T")))
      cursorMode := "b"
    else
      cursorMode := "h"

    loop c.Length {
      i := A_Index
      h_cursor := DllCall("CopyImage", "Ptr", (cursorMode = "b" ? b : h)[i], "UInt", 2, "Int", 0, "Int", 0, "UInt", 0, "Ptr")
      DllCall("SetSystemCursor", "Ptr", h_cursor, "UInt", c[i])
    }
  }

  static _init() {
    MouseCursor._setSystemCursor("Init")
  }
  static void := MouseCursor._init()

  show() {
    MouseCursor._setSystemCursor("On")
  }

  hide() {
    MouseCursor._setSystemCursor("Off")
  }
}
