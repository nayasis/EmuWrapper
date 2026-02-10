#Requires AutoHotkey >=2.0
#Include "%A_ScriptDir%\..\..\ZZ_Library\Include.ahk"

; Tests for wrap(command, quote)

quoteD := Chr(34)
quoteS := "'"

msg1 := wrap("hello", quoteD)
msg2 := wrap("he said " . Chr(34) . "hi" . Chr(34), quoteD)
msg3 := wrap("it's ok", quoteS)
msg4 := wrap("a'b'c", quoteS)

; Expect:
; msg1 => "hello"
; msg2 => "he said `"hi`""
; msg3 => 'it``'s ok'
; msg4 => 'a``'b``'c'

exp1 := Chr(34) . "hello" . Chr(34)
exp2 := Chr(34) . "he said " . "``" . "`"" . "hi" . "``" . "`"" . Chr(34)
exp3 := "'it``'s ok'"
exp4 := "'a``'b``'c'"

if (msg1 != exp1)
  debug("FAIL msg1 => ", msg1)
if (msg2 != exp2)
  debug("FAIL msg2 => ", msg2)
if (msg3 != exp3)
  debug("FAIL msg3 => ", msg3)
if (msg4 != exp4)
  debug("FAIL msg4 => ", msg4)

if (msg1 = exp1 && msg2 = exp2 && msg3 = exp3 && msg4 = exp4)
  debug("PASS all")

ExitApp
