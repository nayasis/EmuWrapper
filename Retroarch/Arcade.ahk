#NoEnv
#include %A_ScriptDir%\script\AbstractFunction.ahk

imageDir := %0%
; imageDir := "\\NAS\emul\image\Neogeo\Metal Slug 3 (en)"
; imageDir := "\\NAS\emul\image\ArcadeMame\Groove on Fight - Gouketsuji Ichizoku 3 (en)"
; imageDir := "\\NAS\emul\image\Saturn\Grandia (T-ko)"
; imageDir := "\\NAS\emul\image\Saturn\Cotton 2 (ja)"
; imageDir := "\\NAS\emul\image\FBA\Laser Ghost"
imageDir := "\\NAS\emul\image\ArcadeMame\Tekken Tag Tournament (en)"

option := getOption( imageDir )

; config    := setConfig( "kronos_libretro", option )
; config    := setConfig( "fbneo_libretro", option )
; config    := setConfig( "fbalpha_libretro", option )
config    := setConfig( "mame_libretro", option )
; config    := setConfig( "mame2016_libretro", option )
; config    := setConfig( "mame2003_plus_libretro", option )
imageFile := getRomPath( imageDir, option, "zip|7z" )

writeConfig( config, imageFile )
runEmulator( imageFile, config )

if( config.core == "mame_libretro" || config.core == "mame2016_libretro" ) {
	debug( "wait sub process !" )
	waitEmulator( 1 )
	waitCloseEmulator()
}

ExitApp

#include %A_ScriptDir%\script\AbstractHotkey.ahk