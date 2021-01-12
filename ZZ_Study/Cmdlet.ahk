#NoEnv
#include %A_ScriptDir%\..\ZZ_Library\Include.ahk

; a := EucEncode("할아버지")
; debug( a )
; MsgBox, % a

; b := EucDecode( a )
; debug( b )
; MsgBox, % b

res := cmdlet( "dir e:\download")

debug( res )

; MsgBox, % ">> res :" res

ExitApp

debugA( message ) {

  message .= "`n" 
  FileAppend %message%, * ; send message to stdout
    
}