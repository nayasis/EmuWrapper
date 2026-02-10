#Requires AutoHotkey >=2.0

class ResolutionChanger {

  static _init() {
    ResolutionChanger.srcWidth := A_ScreenWidth
    ResolutionChanger.srcHeight := A_ScreenHeight
  }
  static void := ResolutionChanger._init()
  static changed := false

  static change(width, height, colorDepth := 32, refreshRate := 60) {
    if (RegExMatch(width, "^\d+$") == false || RegExMatch(height, "^\d+$") == false) {
      MsgBox("Resolution must be consisted with digit values ( input values : [" width "]x[" height "])")
      return
    }

    debug("change resolution : " width "x" height)

    deviceMode := Buffer(156, 0)
    NumPut("UInt", 156, deviceMode, 36)
    DllCall("EnumDisplaySettingsA", "UInt", 0, "UInt", -1, "Ptr", deviceMode)
    NumPut("UInt", 0x5c0000, deviceMode, 40)
    NumPut("UInt", colorDepth, deviceMode, 104)
    NumPut("UInt", width, deviceMode, 108)
    NumPut("UInt", height, deviceMode, 112)
    NumPut("UInt", refreshRate, deviceMode, 120)
    DllCall("ChangeDisplaySettingsA", "Ptr", deviceMode, "UInt", 0)

    ResolutionChanger.changed := true
  }

  static restore() {
    if (ResolutionChanger.changed == true && (A_ScreenWidth != ResolutionChanger.srcWidth || A_ScreenHeight != ResolutionChanger.srcHeight)) {
      ResolutionChanger.change(ResolutionChanger.srcWidth, ResolutionChanger.srcHeight)
      ResolutionChanger.changed := false
      debug("restore resolution : " ResolutionChanger.srcWidth "x" ResolutionChanger.srcHeight)
    }
  }
}
