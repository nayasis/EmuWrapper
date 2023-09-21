#NoEnv
#include %A_ScriptDir%\script\AbstractFunction.ahk

imageDir := %0%
; imageDir := "\\NAS2\emul\image\c64\Black Magic (en)"
; imageDir := "\\NAS2\emul\image\c64\Commando"
; imageDir := "\\NAS2\emul\image\c64\Bards Tale 3 (en)"
; imageDir := "\\NAS2\emul\image\c64\Ultima V - Warriors of Destiny (origin)(en)\"
; imageDir := "\\NAS2\emul\image\c64\Invaders 128 (19xx)(Spiceware)"

option    := getOption( imageDir )
config    := setConfig( "vice_x64sc_libretro", option )
imageFile := getRomPath( imageDir, option, "m3u|zip|adf|adz|hdf|hdz" )

; config.core := "vice_x64_libretro"
; config.core := "vice_x64sc_libretro"
; config.core := "vice_x128_libretro"
; config.core := "vice_xscpu64_libretro"
; config.core := "vice_xplus4_libretro"
; config.core := "vice_xvic_libretro"

writeConfig( config, imageFile )
runEmulator( imageFile, config )

ExitApp

#include %A_ScriptDir%\script\AbstractHotkey.ahk