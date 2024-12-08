class ResolutionChanger {

  static void    := ResolutionChanger._init()
  static changed := false

  _init() {
    this.srcWidth  := A_ScreenWidth
    this.srcHeight := A_ScreenHeight
  }

  change( width, height, colorDepth := 32, refreshRate := 60 ) {

    If ( RegExMatch(width, "^\d+$") == false || RegExMatch(height, "^\d+$") == false ) {
      MsgBox Resolution must be consisted with digit values ( input values : [%width%]x[%height%])
      return
    }

    debug("change resolution : " width "x" height )

  	VarSetCapacity( deviceMode, 156, 0 )
  	NumPut( 156, &deviceMode, 36 )
  	DllCall( "EnumDisplaySettingsA", UInt, 0, UInt, -1, UInt, &deviceMode )
  	NumPut( 0x5c0000,    deviceMode,  40 )
  	NumPut( colorDepth,  deviceMode, 104 )
  	NumPut( width,       deviceMode, 108 )
  	NumPut( height,      deviceMode, 112 )
  	NumPut( refreshRate, deviceMode, 120 )
  	DllCall( "ChangeDisplaySettingsA", UInt, &deviceMode, UInt, 0 )

  	ResolutionChanger.changed := true

  }

  restore() {
    ;MsgBox, % A_ScreenWidth "x" A_ScreenHeight " -> " this.srcWidth "x" this.srcHeight
    if ( ResolutionChanger.changed == true && (A_ScreenWidth != this.srcWidth || A_ScreenHeight != this.srcHeight) ) {
      this.change( this.srcWidth, this.srcHeight )
      ResolutionChanger.changed := false
      debug("restore resolution : " this.srcWidth "x" this.srcHeight )
    }

  }

}