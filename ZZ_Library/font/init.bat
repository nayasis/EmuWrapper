rem 수정금지

chcp 949

setlocal enabledelayedexpansion
setlocal enableextensions

if not exist koiiro.exe (
powershell ^(New-Object -ComObject Wscript.Shell^).Popup^("""마시마로 게임이 발견되지 않았습니다.""",0,"""오류""",0x10^)
taskkill /f /im koiiro_KR.exe
exit
)


echo %CD%| findstr /R /C:"[^a-zA-Z0-9\(\)_:\\ ]"
if ErrorLevel 1 (
	goto :proceed1
) ELSE (
	powershell ^(New-Object -ComObject Wscript.Shell^).Popup^("""게임 설치 경로가 영문, 숫자로만 되게 해주세요""",0,"""오류""",0x10^)
	taskkill /f /im koiiro_KR.exe
	exit
)
:proceed1



if not exist save_KR (
mkdir save_KR
)

if not exist %systemroot%\fonts\NOTO220MD_ORG.ttf (

for /f "tokens=4-5 delims=. " %%i in ('ver') do set VERSION=%%i.%%j
if "!version!" == "6.1" (
cscript patch_KR\font.vbs

powershell ^(New-Object -ComObject Wscript.Shell^).Popup^("""윈도우7이 감지 되었습니다."`n"게임 실행 후 폰트가 굴림으로 나올 경우 재부팅을 해주세요""",0,"""경고""",0x30^)

) else (

xcopy /s /Y patch_KR\NOTO220MD_ORG.ttf %systemroot%\fonts

reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts" /v "NOTO220MD_ORG (TrueType)" /t REG_SZ /d NOTO220MD_ORG.ttf /f

)

)

if not exist %systemroot%\fonts\NOTO220MD_ORG.ttf (
powershell ^(New-Object -ComObject Wscript.Shell^).Popup^("""폰트 파일이 제대로 설치되지 않았습니다."`n"지금 patch_KR 폴더 안에 있는 NOTO220MD_ORG.ttf를"`n"우클릭 모든 사용자용으로 설치하신후에 다시 실행해주세요""",0,"""오류""",0x10^)
taskkill /f /im koiiro_KR.exe
)


if not exist save_KR\KRSAVE11.txt (

if exist save_KR (

powershell ^(New-Object -ComObject Wscript.Shell^).Popup^("""한글패치 패치 1.1용 이외의 세이브파일이 감지 되었습니다."`n"충돌 방지를 위해 기존 세이브파일을 save_BAK11으로 백업하고"`n"초기화 합니다.""",0,"""경고""",0x40^)

move save_KR save_BAK11

mkdir save_KR

)

mkdir save_KR

echo. 2> save_KR\KRSAVE11.txt

)

