#Requires AutoHotkey v2.0

logFile := "D:\app\emulator\retroarch\share\logs\retroarch.log"

if !FileExist(logFile) {
	MsgBox "로그 파일이 없습니다.`n" logFile, "Tail Log", "Iconx"
	ExitApp
}

; 콘솔 창에서 최근 50줄과 이후 추가 로그를 실시간으로 출력
psCommand := "Get-Content -Path `"" logFile "`" -Tail 50 -Wait"
cmd := A_ComSpec " /k powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -Command `"" psCommand "`""
Run cmd
