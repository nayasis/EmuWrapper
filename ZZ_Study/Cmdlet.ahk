#NoEnv
#include %A_ScriptDir%\..\ZZ_Library\Include.ahk

; a := EucEncode("�Ҿƹ���")
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