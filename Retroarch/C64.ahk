#NoEnv
#include %A_ScriptDir%\script\AbstractFunction.ahk

imageDir := %0%
; imageDir := "\\NAS2\emul\image\c64\Black Magic (en)"
; imageDir := "\\NAS2\emul\image\c64\Commando"
; imageDir := "\\NAS2\emul\image\c64\Bards Tale 3 (en)"
; imageDir := "\\NAS2\emul\image\c64\Ultima V - Warriors of Destiny (origin)(en)\"
 ;imageDir := "\\NAS2\emul\image\c64\Leaderboard - Tournament (access)(en)"

option    := getOption( imageDir )
config    := setConfig( "vice_x64sc_libretro", option )
imageFile := getRomPath( imageDir, option, "m3u|zip|adf|adz|hdf|hdz|bin|crt|prg|p00|d64|d71|d81|dfi|dmp|g64|lbr|lnx|nbz|nib|tap|t64|hdd" )

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