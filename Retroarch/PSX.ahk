#NoEnv
#include %A_ScriptDir%\script\AbstractFunction.ahk

imageDir := %0%
; imageDir := "\\NAS2\emul\image\PlayStation\R4 Ridge Racer Type 4 (en)"
; imageDir := "\\NAS2\emul\image\PlayStation\Super Robot Taisen Alpha - Limited Edition (T-ko)"

option := getOption( imageDir )
setCustomFont( imageDir, option )
config := setConfig( "mednafen_psx_libretro", option, true )
imageFile := getRomPath( imageDir, option, "m3u|chd|cue|pbp" )

; config.core := "pcsx_rearmed_libretro"
; config.core := "swanstation_libretro"
; config.core := "mednafen_psx_libretro"

setPadConfig(config)

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

setPadConfig(config) {
	trgCore := getCoreName(config.core)
	if( trgCore == "Beetle PSX" ) return
	if( trgCore == "Beetle PSX HW" ) return
	fileRmp := EMUL_ROOT "\config\remaps\" trgCore "\" trgCore ".rmp"
	conf := ""
	conf .= "input_libretro_device_p1=""" config.input_libretro_device_p1 """`n"
	conf .= "input_libretro_device_p2=""" config.input_libretro_device_p2 """`n"
	conf .= "input_libretro_device_p3=""" config.input_libretro_device_p3 """`n"
	conf .= "input_libretro_device_p4=""" config.input_libretro_device_p4 """`n"
	conf .= "input_player1_analog_dpad_mode=""" config.input_player1_analog_dpad_mode """`n"
	conf .= "input_player2_analog_dpad_mode=""" config.input_player2_analog_dpad_mode """`n"
	conf .= "input_player3_analog_dpad_mode=""" config.input_player3_analog_dpad_mode """`n"
	conf .= "input_player4_analog_dpad_mode=""" config.input_player4_analog_dpad_mode """`n"
	FileUtil.write(fileRmp, conf)
}

#include %A_ScriptDir%\script\AbstractHotkey.ahk