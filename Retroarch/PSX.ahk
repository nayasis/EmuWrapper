#NoEnv
#include %A_ScriptDir%\script\AbstractFunction.ahk

imageDir := %0%
; imageDir := "\\NAS\emul\image\PlayStation\Silent Hill (T-ko)"
; imageDir := "\\NAS\emul\image\PlayStation\Ganbare Goemon - Uchuu Kaizoku Akogingu (en)"

option := getOption( imageDir )
setCustomFont( imageDir, option )
config := setConfig( "mednafen_psx_libretro", option )
; config := setConfig( "pcsx_rearmed_libretro", option )
imageFile := getRomPath( imageDir, option, "m3u|chd|cue|pbp" )

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