#Requires AutoHotkey >=2.0
#Include %A_ScriptDir%\script\AbstractFunction.ahk

imageDir := A_Args.Length ? A_Args[1] : ""
;imageDir := "\\NAS2\emul\image\Apple2\Times of Lore (origin)(en)"
;imageDir := "\\NAS2\emul\image\Apple2\Questron II (westwood)(en)"

option    := getOption(imageDir)
config    := setConfig("applewin_libretro", option)

;config.core := "applewin_libretro"

imageFile := getRomPath( imageDir, option, "m3u|bin|do|dsk|nib|po|gz|woz|zip|2mg|2img|iie|apl|hdv|yaml" )

debug(">> imageFile : " imageFile )

writeConfig( config, imageFile )
runEmulator( imageFile, config )

ExitApp

#Include %A_ScriptDir%\script\AbstractHotkey.ahk