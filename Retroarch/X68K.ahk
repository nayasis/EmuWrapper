#NoEnv
#include %A_ScriptDir%\script\AbstractFunction.ahk

imageDir := %0%
; imageDir := "\\NAS2\emul\image\x68000\Ys 3 - Wanderers From Ys (ja)\"
; imageDir := "\\NAS2\emul\image\x68000\Ys 2 - Ancient Ys Vanished (ja)\"
; imageDir := "\\NAS2\emul\image\x68000\Akumajou Dracula (ja)\"
; imageDir := "\\NAS2\emul\image\x68000\Final Fight (ja)\"
; imageDir := "\\NAS2\emul\image\x68000\Sangokushi (ja)\"
; imageDir := "\\NAS2\emul\image\x68000\Sangokushi III (ja)\"

option    := getOption( imageDir )
config    := setConfig( "px68k_libretro", option )
imageFile := getRomPath( imageDir, option, "cmd|m3u|zip|dim|img|d88|88d|hdm|dup|2hd|xdf|hdf" )

writeConfig( config, imageFile )
runEmulator( imageFile, config )

ExitApp

#include %A_ScriptDir%\script\AbstractHotkey.ahk