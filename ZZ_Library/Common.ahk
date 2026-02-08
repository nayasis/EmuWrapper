#Requires AutoHotkey >=2.0

; Route runtime errors to stdout/log when available (for compiled executables too).
OnError(_AhkStdOnError)
try DllCall("AttachConsole", "UInt", -1)
_AhkStdEnsureLog()

_AhkStdOnError(err, mode) {
  msg := "Error: " err.Message "`n"
  if (err.What != "")
    msg .= "`n▶" err.Line ": " err.What "`n"
  if (err.Stack)
    msg .= "`nCall stack:`n" err.Stack "`n"
  msg .= "`n> " (A_IsCompiled ? A_ScriptFullPath : A_LineFile)
  _AhkStdWrite(msg)
  return 1
}

_AhkStdWrite(msg) {
  log := EnvGet("AHK_STDOUT_LOG")
  if (log != "") {
    FileAppend(msg "`n", log)
    return
  }
  FileAppend(msg "`n", "**")
}

_AhkStdEnsureLog() {
  log := EnvGet("AHK_STDOUT_LOG")
  if (log != "")
    try FileAppend("", log)
}

; debug( "merong" )
; debug( "jake" )
; ExitApp

debug(message := "") {
  if (A_IsCompiled)
    return
  message .= "`r`n"
  FileAppend(message, "*")
}

sendKey(key) {
  SendInput("{" key " down}")
  Sleep(50)
  SendInput("{" key " up}")
  Sleep(50)
}

wrap(command, escapeChar := "") {
  return escapeChar . "`"" . command . "`"" . escapeChar . "`""
}

nvl(val, defaultVal := "") {
  if (val != "")
    return val
  return defaultVal
}

min(a, b) {
  if (a > b) {
    return b
  } else {
    return a
  }
}

max(a, b) {
  if (a > b) {
    return a
  } else {
    return b
  }
}

sortArray(Array) {
  t := Map()
  for k, v in Array
    t[RegExReplace(v, "\s")] := v
  Array := []
  for k, v in t
    Array.Push(v)
  return Array
}

getArguments() {
  array := []
  for i, param in A_Args {
    array[i - 1] := param
  }
  return array
}

getRawArguments() {
  cli := DllCall("GetCommandLine", "Str")
  return Trim(SubStr(cli, (InStr(cli, A_ScriptName) + StrLen(A_ScriptName) + 2)))
}

/**
* Os Detector
*
* Detector.64 : true / false
*/
class Detector {

  static 64 := true
  static version := Trim( RegExReplace( A_OSVersion, "i)^(\d+?)\..*?$", "$1" ) )
  static _init() {
    ThisProcess := DllCall("GetCurrentProcess")
    IsWow64Process := 0
    if !DllCall("IsWow64Process", "Ptr", ThisProcess, "Int*", &IsWow64Process)
      Detector.64 := false
  }
  static _void := Detector._init()
    
  __New() {
    throw Error("Detector is static class, dont instantiate it!", -1)
  }

}

/**
* MouseCursor Controller
*/
class MouseCursor {

  static _setSystemCursor(OnOff := 1) {  ; INIT = "I","Init"; OFF = 0,"Off"; TOGGLE = -1,"T","Toggle"; ON = others
    static AndMask := 0, XorMask := 0, cursorMode := "", h_cursor := 0
    static c := [], h := [], b := []
    
    if (OnOff = "Init" || OnOff = "I" || cursorMode = "") {       ; init when requested or at first call
      cursorMode := "h"                                          ; active default cursors
      h_cursor := Buffer(4444, 1)
      AndMask := Buffer(32*4, 0xFF)
      XorMask := Buffer(32*4, 0)
      system_cursors := [32512,32513,32514,32515,32516,32642,32643,32644,32645,32646,32648,32649,32650]
      c := system_cursors
      h := []
      b := []
      
      loop c.Length {
        i := A_Index
        h_cursor := DllCall("LoadCursor", "Ptr", 0, "Ptr", c[i])
        h.Push(DllCall("CopyImage", "Ptr", h_cursor, "UInt", 2, "Int", 0, "Int", 0, "UInt", 0))
        b.Push(DllCall("CreateCursor", "Ptr", 0, "Int", 0, "Int", 0
            , "Int", 32, "Int", 32, "Ptr", AndMask.Ptr, "Ptr", XorMask.Ptr))
      }
    }
    if (OnOff = 0 || OnOff = "Off" || (cursorMode = "h" && (OnOff = "Toggle" || OnOff = "T" || (OnOff is Number && OnOff < 0))))
      cursorMode := "b"  ; use blank cursors
    else
      cursorMode := "h"  ; use the saved cursors

    loop c.Length {
      i := A_Index
      if (cursorMode = "b")
        h_cursor := DllCall("CopyImage", "Ptr", b[i], "UInt", 2, "Int", 0, "Int", 0, "UInt", 0)
      else
        h_cursor := DllCall("CopyImage", "Ptr", h[i], "UInt", 2, "Int", 0, "Int", 0, "UInt", 0)
      DllCall("SetSystemCursor", "Ptr", h_cursor, "UInt", c[i])
    }
  }

  static _init() {
    MouseCursor._setSystemCursor( "Init" )
  }
  static void := MouseCursor._init()

  show() {
    SetTimer(MouseCursor.no_move_check, 0)
    MouseCursor._setSystemCursor("On")
  }

  hide(duration := 500) {
    SetTimer(MouseCursor.no_move_check, duration)
    MouseCursor._setSystemCursor("Off")
  }
  
  static no_move_check() {
    MouseGetPos(&prevX, &prevY)
    Sleep(100)
    MouseGetPos(&x, &y)
    if (prevX != x || prevY != y) {
      MouseCursor._setSystemCursor("On")
    } else {
      MouseCursor._setSystemCursor("Off")
    }
  }

}



/**
* Environment
*/
class Environment {

  static _init() {
  }
  static _void := Environment._init()

  __New() {
    throw Error("Environment is static class", -1)
  }

  getEnv(environmentName) {
    env := EnvGet(environmentName)
    return env
  }

  getUserHome() {
    return this.getEnv("userprofile")
  }

  restartAsAdmin() {
    if (!A_IsAdmin) {
      try { ; leads to having the script re-launching itself as administrator
        if (A_IsCompiled)
          Run('*RunAs "' A_ScriptFullPath '" /restart')
        else
          Run('*RunAs "' A_AhkPath '" /restart "' A_ScriptFullPath '"')
      }
      ExitApp
    }
  }

}

/**
* Network
*/
class Network {

  static _init() {
  }
  static _void := Network._init()

  __New() {
    throw Error("Network is static class", -1)
  }

  block(ruleName, path) {
    Environment.restartAsAdmin()
    RunWait("netsh advfirewall firewall delete rule name=" wrap(ruleName), , "Hide")
    cmd := "netsh advfirewall firewall add rule name=" wrap(ruleName) " dir=out program=" wrap(path) " action=block"
    debug(cmd)
    RunWait(cmd, , "Hide")
  }

}


/**
* Range
*/
range(start := 0, stop := "", step := 1) {
  static rangeBase := { _NewEnum: _RangeNewEnum }
  if (!step)
    throw Error("range(): Parameter 'step' must not be 0 or blank")
  if (stop == "")
    stop := start
  ; Formula: r[i] := start + step*i ; r = range object, i = 0-based index
  ; For a postive 'step', the constraints are i >= 0 and r[i] < stop
  ; For a negative 'step', the constraints are i >= 0 and r[i] > stop
  ; No result is returned if r[0] does not meet the value constraint
  if (step > 0 ? start < stop : start > stop) ;// start == start + step*0
    return { base: rangeBase, start: start, stop: stop, step: step }
}

_RangeNewEnum(r) {
  static enum := { Next: _RangeEnumNext }
  return { base: enum, r: r, i: 0 }
}

_RangeEnumNext(enum, &k, &v := "") {
  stop := enum.r.stop
  step := enum.r.step
  k := enum.r.start + step*enum.i
  ret := step > 0 ? k < stop : k > stop
  if (ret)
    enum.i += 1
  return ret
}
