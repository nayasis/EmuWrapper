@echo off
REM Citron Auto-Updater Helper Script
REM This script applies staged updates after the main application exits

echo Waiting for Citron to close...
timeout /t 3 /nobreak >nul

echo Applying update...
xcopy /E /Y /I "D:\app\emulator\nsw\citron\update_staging" "D:\app\emulator\nsw\citron" >nul 2>&1

if errorlevel 1 (
    echo Update failed. Please restart Citron manually.
    timeout /t 5
    exit /b 1
)

echo Update applied successfully!
timeout /t 1 /nobreak >nul

echo Restarting Citron...
start "" "D:\app\emulator\nsw\citron\citron.exe"

REM Clean up staging directory
rd /s /q "D:\app\emulator\nsw\citron\update_staging" >nul 2>&1

REM Delete this script
del "%~f0"
