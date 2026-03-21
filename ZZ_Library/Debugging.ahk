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
  try ExitApp(1)
  return 1
}

_AhkStdWrite(msg) {
  log := EnvGet("AHK_STDOUT_LOG")
  if (log != "") {
    try FileAppend(msg "`n", log)
    return
  }
  try FileAppend(msg "`n", "**")
}

_AhkStdEnsureLog() {
  log := EnvGet("AHK_STDOUT_LOG")
  if (log != "")
    try FileAppend("", log)
}

; debug( "merong" )
; debug( "jake" )
; ExitApp

Assert(cond, msg) {
  if !cond
    throw Error("Assert failed: " msg)
}

debug(params*) {
  if (A_IsCompiled)
    return
  message := ""
  for _, p in params {
    o := ""
    switch Type(p) {
      case "JSON.Obj", "Map", "Array", "Object":
        try o := JSON.stringify(p)
        catch
          try o := String(p)
      default:
        try o := String(p)
    }
    message .= o
  }
  message .= "`r`n"
  log := EnvGet("AHK_STDOUT_LOG")
  if (log != "") {
    try FileAppend(message, log)
  } else {
    try FileAppend(message, "*")
    if (EnvGet("AHK_DEBUG_STDERR") != "")
      try FileAppend(message, "**")
  }
}
