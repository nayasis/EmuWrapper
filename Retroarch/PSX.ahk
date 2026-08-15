#Requires AutoHotkey >=2.0
#Include %A_ScriptDir%\script\AbstractFunction.ahk

imageDir := A_Args.Length ? A_Args[1] : ""
;imageDir := "\\NAS2\emul\image\PlayStation\Alundra (T-ko)"

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

setCustomFont(imageDir, option) {
	customfont := FileUtil.findFile(imageDir, "i)scph.*\.bin")
	debug("customfont: " customfont)
	if ( customfont != "" ) {
		option.systemfiles_in_content_dir := "true"
	} else {
		option.systemfiles_in_content_dir := "false"
	}
	debug("option.systemfiles_in_content_dir: " option.systemfiles_in_content_dir)
}

#Include %A_ScriptDir%\script\AbstractHotkey.ahk