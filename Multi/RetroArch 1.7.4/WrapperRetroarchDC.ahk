#NoEnv
#include WrapperAbstrctFunction.ahk

imageDirPath := %0%
; imageDirPath := "f:\download\Virtua Cop 2 v1.011 (2000)(Sega)(NTSC)(JP)(en)[!]"
; imageDirPath := "f:\download\_dc\Kidou Senshi Gundam - Renpou vs. Zeon DX (Japan)"

option := getOption( imageDirPath )
; core   := nvl( option.run.core, "redream_libretro" )
core   := nvl( option.run.core,   "reicast_libretro" )
filter := nvl( option.run.filter, "chd|iso" )

modifyConfigDefault( option )
modifyConfigCore( option )

imageFilePath := getRomPath( imageDirPath, option, filter, false )

runRomEmulator( imageFilePath, core )

ExitApp

setCoreConfig( config, option ) {
	config.reicast_cable_type := nvl( option.run.cableType, "VGA (RGB)" )
}

#include %A_ScriptDir%\WrapperAbstrctHotkey.ahk