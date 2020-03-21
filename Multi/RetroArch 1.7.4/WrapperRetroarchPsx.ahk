#NoEnv
#include WrapperAbstrctFunction.ahk

imageDirPath := %0%
imageDirPath := "\\NAS\emul\image\PlayStation\R4 Ridge Racer Type 4 (en)"
; imageDirPath := "\\NAS\emul\image\PlayStation\Silent Hill (T-ko)"
; imageDirPath := "\\NAS\emul\image\PlayStation\Ganbare Goemon - Uchuu Kaizoku Akogingu (en)"

option := getOption( imageDirPath )
core   := getCore( option, "mednafen_psx_libretro" )
; core   := getCore( option, "pcsx_rearmed_libretro" )
filter := getFilter( option, "chd|cue|pbp" )

setCustomFont( imageDirPath, option )

modifyConfigDefault( option )
modifyConfigCore( option )

imageFilePath := getRomPath( imageDirPath, option, filter )

runRomEmulator( imageFilePath, core )

ExitApp

setCustomFont( imageDirPath, option ) {
	if ( FileUtil.exist(imageDirPath "\scph5500.bin") == true ) {
		option.systemfiles_in_content_dir := "true"
	} else {
		option.systemfiles_in_content_dir := "false"
	}
}

#include %A_ScriptDir%\WrapperAbstrctHotkey.ahk


