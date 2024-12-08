#NoEnv
#include %A_ScriptDir%\script\AbstractFunction.ahk

imageDir := %0%
 ;imageDir := "\\NAS2\emul\image\PlayStation\Psychic Force (T-ko)"

option := getOption(imageDir)
setCustomFont( imageDir, option )
config := setConfig( "pcsx_rearmed_libretro", option, true )
imageFile := getRomPath( imageDir, option, "m3u|chd|cue|pbp" )

; config.core := "pcsx_rearmed_libretro"
; config.core := "swanstation_libretro"
; config.core := "mednafen_psx_libretro"

writeConfig( config, imageFile )
runEmulator( imageFile, config )

ExitApp

setCustomFont( imageDir, option ) {
	customfont := FileUtil.getFile(imageDir, "scph.*\.bin")
	if ( customfont != "" ) {
		option.systemfiles_in_content_dir := "true"
	} else {
		option.systemfiles_in_content_dir := "false"
	}
}

#include %A_ScriptDir%\script\AbstractHotkey.ahk