#NoEnv
#include %A_ScriptDir%\script\AbstractFunction.ahk

; EMUL_ROOT     := A_ScriptDir "\1.8.4"

imageDir := %0%
; imageDir := "\\NAS2\emul\image\PlayStation\Valkyrie Profile (en)"

option := getOption( imageDir )
setCustomFont( imageDir, option )
config := setConfig( "mednafen_psx_libretro", option, true )
imageFile := getRomPath( imageDir, option, "m3u|chd|cue|pbp" )

; config.core := "pcsx_rearmed_libretro"
; config.core := "mednafen_psx_libretro"

writeConfig( config, imageFile )
runEmulator( imageFile, config )

ExitApp

setCustomFont( imageDir, option ) {
	if ( FileUtil.exist(imageDir "\scph5500.bin") == true ) {
		option.systemfiles_in_content_dir := "true"
	} else {
		option.systemfiles_in_content_dir := "false"
	}
}

#include %A_ScriptDir%\script\AbstractHotkey.ahk