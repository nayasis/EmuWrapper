rem ��������

chcp 949

setlocal enabledelayedexpansion
setlocal enableextensions

if not exist koiiro.exe (
powershell ^(New-Object -ComObject Wscript.Shell^).Popup^("""���ø��� ������ �߰ߵ��� �ʾҽ��ϴ�.""",0,"""����""",0x10^)
taskkill /f /im koiiro_KR.exe
exit
)


echo %CD%| findstr /R /C:"[^a-zA-Z0-9\(\)_:\\ ]"
if ErrorLevel 1 (
	goto :proceed1
) ELSE (
	powershell ^(New-Object -ComObject Wscript.Shell^).Popup^("""���� ��ġ ��ΰ� ����, ���ڷθ� �ǰ� ���ּ���""",0,"""����""",0x10^)
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

powershell ^(New-Object -ComObject Wscript.Shell^).Popup^("""������7�� ���� �Ǿ����ϴ�."`n"���� ���� �� ��Ʈ�� �������� ���� ��� ������� ���ּ���""",0,"""���""",0x30^)

) else (

xcopy /s /Y patch_KR\NOTO220MD_ORG.ttf %systemroot%\fonts

reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts" /v "NOTO220MD_ORG (TrueType)" /t REG_SZ /d NOTO220MD_ORG.ttf /f

)

)

if not exist %systemroot%\fonts\NOTO220MD_ORG.ttf (
powershell ^(New-Object -ComObject Wscript.Shell^).Popup^("""��Ʈ ������ ����� ��ġ���� �ʾҽ��ϴ�."`n"���� patch_KR ���� �ȿ� �ִ� NOTO220MD_ORG.ttf��"`n"��Ŭ�� ��� ����ڿ����� ��ġ�Ͻ��Ŀ� �ٽ� �������ּ���""",0,"""����""",0x10^)
taskkill /f /im koiiro_KR.exe
)


if not exist save_KR\KRSAVE11.txt (

if exist save_KR (

powershell ^(New-Object -ComObject Wscript.Shell^).Popup^("""�ѱ���ġ ��ġ 1.1�� �̿��� ���̺������� ���� �Ǿ����ϴ�."`n"�浹 ������ ���� ���� ���̺������� save_BAK11���� ����ϰ�"`n"�ʱ�ȭ �մϴ�.""",0,"""���""",0x40^)

move save_KR save_BAK11

mkdir save_KR

)

mkdir save_KR

echo. 2> save_KR\KRSAVE11.txt

)

