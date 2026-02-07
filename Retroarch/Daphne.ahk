#Requires AutoHotkey >=2.0
#Include %A_ScriptDir%\script\AbstractFunction.ahk

; daphne-core is missing sound feature on Windows platform.

imageDir := A_Args.Length ? A_Args[1] : ""
; imageDir := "e:\download\Daphne for Retropie\lair\roms"
;imageDir := "\\NAS\emul\ZZ_Temp\daphne\Daphne for Retropie\ROMs\lair2.daphne"

option    := getOption( imageDir )
config    := setConfig( "daphne_libretro", option )
imageFile := getRomPath( imageDir, option, "zip|7z" )

writeConfig( config, imageFile )
runEmulator( imageFile, config )
waitCloseEmulator()

ExitApp

#Include %A_ScriptDir%\script\AbstractHotkey.ahk