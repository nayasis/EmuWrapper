; ------------------------------------------------------------
; ������ ��� Ȱ��ȭ (No GUI) - AutoHotkey v1
; ------------------------------------------------------------
; ��� ���:
; 1) ������ ���� �ڵ� ���
; 2) Windows ���� Ȯ�� (15063 �̻� �ʿ�)
; 3) ������ ��� ���� ������Ʈ�� ����
;    HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock
;      - AllowDevelopmentWithoutDevLicense = 1
;      - AllowAllTrustedApps = 1
; 4) ���� ��� MsgBox �� ��� (����)
; ------------------------------------------------------------

#Requires AutoHotkey >=2.0
#SingleInstance Force

APP := "Enable Developer Mode"

; --- 1) ������ ���� Ȯ�� & �ڵ� ��� ---
if !A_IsAdmin {
    try {
        Run, *RunAs "%A_AhkPath%" "%A_ScriptFullPath%"
    } catch e {
        MsgBox, 48, %APP%, Failed to elevate privileges.`nPlease run as Administrator.
    }
    ExitApp
}

; --- 2) Windows ���� Ȯ�� ---
RegRead, build, HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion, CurrentBuildNumber
if (ErrorLevel) {
    MsgBox, 48, %APP%, Failed to read Windows build information.`nCheck registry permission or security settings.
    ExitApp
}
if (build+0 < 15063) {
    MsgBox, 48, %APP%, Current build: %build%`nDeveloper Mode is supported from Windows 10 build 15063 or higher.
}

; --- 3) ������Ʈ�� ���� ---
rootKey := "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock"

RegWrite, REG_DWORD, %rootKey%, AllowDevelopmentWithoutDevLicense, 1
if (ErrorLevel) {
    MsgBox, 48, %APP%, Failed to set "AllowDevelopmentWithoutDevLicense".`nPlease check group policy or security software.
    ExitApp
}

RegWrite, REG_DWORD, %rootKey%, AllowAllTrustedApps, 1
if (ErrorLevel) {
    MsgBox, 48, %APP%, Failed to set "AllowAllTrustedApps".`nPlease check group policy or security software.
    ExitApp
}

; --- 4) ���� ���� ---
RegRead, v1, %rootKey%, AllowDevelopmentWithoutDevLicense
RegRead, v2, %rootKey%, AllowAllTrustedApps

if (ErrorLevel) {
    MsgBox, 48, %APP%, Failed to verify registry values.`nPlease check permission.
    ExitApp
}

if (v1+0 = 1 && v2+0 = 1) {
    MsgBox, 64, %APP%, Developer Mode has been successfully enabled.`n(AllowDevelopmentWithoutDevLicense=1, AllowAllTrustedApps=1)
} else {
    MsgBox, 48, %APP%, Some values were not set correctly.`nAllowDevelopmentWithoutDevLicense=%v1%`nAllowAllTrustedApps=%v2%`nPlease check group policy or registry permission.
}

ExitApp
