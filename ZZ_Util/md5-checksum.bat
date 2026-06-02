@echo off
setlocal

set "AHK=%ProgramFiles%\AutoHotkey\v2\AutoHotkey64.exe"
if not exist "%AHK%" set "AHK=%ProgramFiles%\AutoHotkey\AutoHotkey64.exe"

if not exist "%AHK%" (
  echo AutoHotkey not found.
  exit /b 1
)

"%AHK%" /ErrorStdOut /CP65001 "%~dp0..\tools\Compile.ahk" "%~dp0md5-checksum.ahk"
exit /b %errorlevel%
