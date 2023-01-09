rem 수정금지

chcp 949

setlocal enabledelayedexpansion
setlocal enableextensions

if not exist primhearts.exe (
powershell ^(New-Object -ComObject Wscript.Shell^).Popup^("""프라이멀x하츠 게임이 발견되지 않았습니다.""",0,"""오류""",0x10^)
taskkill /f /im primhearts_KR.exe
exit
)

if not exist save_KR (
mkdir save_KR
)

if not exist %systemroot%\fonts\NOTO220BD_BGI.ttf (

for /f "tokens=4-5 delims=. " %%i in ('ver') do set VERSION=%%i.%%j
if "%version%" == "6.1" (
cscript patch_KR\font.vbs

powershell ^(New-Object -ComObject Wscript.Shell^).Popup^("""윈도우7이 감지 되었습니다."`n"게임 실행 후 폰트가 굴림으로 나올 경우 재부팅을 해주세요""",0,"""경고""",0x30^)

) else (

xcopy /s /Y patch_KR\NOTO220BD_BGI.ttf %systemroot%\fonts

reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts" /v "NOTO220BD_BGI (TrueType)" /t REG_SZ /d NOTO220BD_BGI.ttf /f

)

)

if not exist %systemroot%\fonts\NOTO220BD_BGI.ttf (
powershell ^(New-Object -ComObject Wscript.Shell^).Popup^("""폰트 파일이 제대로 설치되지 않았습니다."`n"지금 patch_KR 폴더 안에 있는 NOTO220BD_BGI.ttf를"`n"우클릭 모든 사용자용으로 설치하신후에 다시 실행해주세요""",0,"""오류""",0x10^)
taskkill /f /im primhearts_KR.exe
)
