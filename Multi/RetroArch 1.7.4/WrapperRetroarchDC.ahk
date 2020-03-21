#NoEnv
#include WrapperAbstrctFunction.ahk

imageDirPath := %0%
; imageDirPath := "e:\download\[GDI] Napple Tale - Arsia in Daydream (JP)\ttt\new"
; imageDirPath := "e:\download\[GDI] Napple Tale - Arsia in Daydream (JP)"
; imageDirPath := "e:\download\LazyBoot_v3.3_20181116_oketado\LazyBoot_v3.3_20181116\Lazyboot\gdi_image"
; imageDirPath := "e:\download\RebuildGDI\NAPPLETALE ARSIA IN DAYDREAM"
; imageDirPath := "f:\download\_dc\Kidou Senshi Gundam - Renpou vs. Zeon DX (Japan)"

option := getOption( imageDirPath )
; core   := nvl( option.run.core, "redream_libretro" )
core   := nvl( option.run.core,   "flycast_libretro" )
filter := nvl( option.run.filter, "chd|gdi|cdi|cue|iso" )

modifyConfigDefault( option )
modifyConfigCore( option )

imageFilePath := getRomPath( imageDirPath, option, filter, false )

runRomEmulator( imageFilePath, core )

ExitApp

setCoreConfig( config, option ) {
	config.reicast_cable_type := nvl( option.run.cableType, "VGA (RGB)" )
}

#include %A_ScriptDir%\WrapperAbstrctHotkey.ahk