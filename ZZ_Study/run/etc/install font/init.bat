rem ��������

chcp 949

setlocal enabledelayedexpansion
setlocal enableextensions

if not exist primhearts.exe (
powershell ^(New-Object -ComObject Wscript.Shell^).Popup^("""�����̸�x���� ������ �߰ߵ��� �ʾҽ��ϴ�.""",0,"""����""",0x10^)
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

powershell ^(New-Object -ComObject Wscript.Shell^).Popup^("""������7�� ���� �Ǿ����ϴ�."`n"���� ���� �� ��Ʈ�� �������� ���� ��� ������� ���ּ���""",0,"""���""",0x30^)

) else (

xcopy /s /Y patch_KR\NOTO220BD_BGI.ttf %systemroot%\fonts

reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts" /v "NOTO220BD_BGI (TrueType)" /t REG_SZ /d NOTO220BD_BGI.ttf /f

)

)

if not exist %systemroot%\fonts\NOTO220BD_BGI.ttf (
powershell ^(New-Object -ComObject Wscript.Shell^).Popup^("""��Ʈ ������ ����� ��ġ���� �ʾҽ��ϴ�."`n"���� patch_KR ���� �ȿ� �ִ� NOTO220BD_BGI.ttf��"`n"��Ŭ�� ��� ����ڿ����� ��ġ�Ͻ��Ŀ� �ٽ� �������ּ���""",0,"""����""",0x10^)
taskkill /f /im primhearts_KR.exe
)
