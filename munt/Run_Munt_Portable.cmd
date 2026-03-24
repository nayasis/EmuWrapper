@echo off
setlocal
powershell -ExecutionPolicy Bypass -File "%~dp0Run_Munt_Portable.ps1" %*
