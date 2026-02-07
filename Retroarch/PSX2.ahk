#Requires AutoHotkey >=2.0
#Include %A_ScriptDir%\script\AbstractFunction.ahk

; EMUL_ROOT := A_ScriptDir "\1.8.4"

imageDir := A_Args.Length ? A_Args[1] : ""
;imageDir := "\\NAS2\emul\image\PSX2\Wizardry - Tale of the Forsaken Land (atlus)(en)"

option := getOption( imageDir )
config := setConfig( "pcsx2_libretro", option, true )
imageFile := getRomPath(imageDir, option, "m3u|cso|bin|iso|chd")

linkSaveFolder(imageDir)

; config.core := "pcsx2_libretro"

; config.driver_switch_enable := "true"
; config.video_driver := "glcore"

writeConfig( config, imageFile )
runEmulator( imageFile, config )

ExitApp

linkSaveFolder(imageDir) {
	src := imageDir "\_EL_CONFIG\save\ra\save"
	trg := EMUL_ROOT "\system\pcsx2\memcards"
	FileUtil.makeLink(src,trg,true)
}

#Include %A_ScriptDir%\script\AbstractHotkey.ahk