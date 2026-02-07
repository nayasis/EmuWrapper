#Requires AutoHotkey >=2.0
; AHK v2 컴파일: 이 스크립트를 AHK v2로 실행하면 WrapperAppleWin.ahk 를 exe로 컴파일합니다.

scriptDir := A_ScriptDir
scriptIn  := scriptDir "\WrapperAppleWin.ahk"
scriptOut := scriptDir "\WrapperAppleWin.exe"

; Ahk2Exe는 AutoHotkey와 같은 폴더에 있음
ahkDir := A_AhkPath ? RegExReplace(A_AhkPath, "\\[^\\]+$", "") : ""
ahk2exe := ahkDir "\Ahk2Exe.exe"

if !FileExist(ahk2exe) {
  for path in [
    A_ProgramFiles "\AutoHotkey\v2\Ahk2Exe.exe",
    A_ProgramFiles "\AutoHotkey\Ahk2Exe.exe",
    A_ProgramFiles "\AutoHotkey\Compiler\Ahk2Exe.exe"
  ] {
    if FileExist(path) {
      ahk2exe := path
      break
    }
  }
}

if !FileExist(ahk2exe) {
  MsgBox("Ahk2Exe를 찾을 수 없습니다. AutoHotkey v2가 설치되어 있는지 확인하세요.`n" A_AhkPath, "Compile", "Icon!")
  ExitApp(1)
}

if !FileExist(scriptIn) {
  MsgBox("입력 스크립트가 없습니다: " scriptIn, "Compile", "Icon!")
  ExitApp(1)
}

try {
  RunWait('"' ahk2exe '" /in "' scriptIn '" /out "' scriptOut '"', scriptDir, "Hide")
  if FileExist(scriptOut)
    MsgBox("컴파일 완료: " scriptOut, "Compile", "Iconi")
  else
    MsgBox("컴파일 후 exe가 생성되지 않았습니다.", "Compile", "Icon!")
} catch as err {
  MsgBox("컴파일 실패: " err.Message, "Compile", "Icon!")
  ExitApp(1)
}
