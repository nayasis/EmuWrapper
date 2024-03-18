#NoEnv
#include %A_ScriptDir%\script\AbstractFunction.ahk

imageDir := %0%
; imageDir := "\\NAS\emul\image\MSX\Puyo Puyo (compile)(T-en 1.0 by 232, BiFi)"
; imageDir := "\\NAS2\emul\image\MSX\Illusion City (micro cabin)(T-ko 20220112 by kkitty5425)"
; imageDir := "\\NAS2\emul\image\MSX\MSX2 Various\AshGuine 2 (T-ko)"
; imageDir := "\\NAS2\emul\image\MSX\Aleste 2 (compile)(T-ko)"
;imageDir := "\\NAS2\emul\image\MSX\Zatsugaku Olympic Watanabe Wataru Hen (hard)(ja)"

option    := getOption( imageDir )
config    := setConfig( "bluemsx_libretro", option )
imageFile := getRomPath( imageDir, option, "m3u|zip|7z|rom|dsk" )

; config.core := "bluemsx_libretro"
; config.bluemsx_msxtype := "MSX2"
; config.bluemsx_cartmapper := "Koei (SRAM)"

setCustomFont( imageDir )

writeConfig( config, imageFile )
runEmulator( imageFile, config )

ExitApp

setCustomFont( imageDir ) {

  src := imageDir "\KANJI.rom"
  if( ! FileUtil.exist(src) ) {
  	src := EMUL_ROOT "\system\Machines\Shared Roms\KANJI.rom.src"
  }
	trg := EMUL_ROOT "\system\Machines\Shared Roms\KANJI.rom"

	debug( ">> " src " -> " trg)

	; FileUtil.makeLink(src,trg)
	; sleep 500
	FileUtil.copy(src,trg)

}

#include %A_ScriptDir%\script\AbstractHotkey.ahk