#Requires AutoHotkey >=2.0
#Include "%A_ScriptDir%\..\ZZ_Library\Common.ahk"

; debug() 테스트.
; AHK++ Run으로 실행 시: 프로젝트 루트의 .ahk-debug.log 파일을 열면 출력 내용이 보임.
; 터미널에서 보려면: Ctrl+Shift+B → "AHK: Run in terminal (stdout visible)"
;
debug("TestDebug.ahk started")
debug("single arg")
debug("multi", " ", "args", " ", "ok")
debug("number: ", 42)

; OutputDebug(">> test OutputDebug")

; DllCall("AllocConsole")
; Stdout(s) => FileAppend(s, "*")
; Stderr(s) => FileAppend(s, "**")

; Stdout(">> Hello, world!`n")
; Stderr(">> Hello, error world!`n")

ExitApp(0)
