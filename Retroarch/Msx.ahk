#Requires AutoHotkey >=2.0
#Include %A_ScriptDir%\script\AbstractFunction.ahk

imageDir := A_Args.Length ? A_Args[1] : ""

option := getOption(imageDir)
config := setConfig("bluemsx_libretro", option)
imageFile := getRomPath(imageDir, option, "m3u|zip|7z|rom|dsk")

setCustomFont(imageDir)

writeConfig(config, imageFile)
runEmulator(imageFile, config)

ExitApp

setCustomFont(imageDir) {
  src := imageDir "\KANJI.rom"
  if (!FileUtil.exist(src))
    src := EMUL_ROOT "\system\Machines\Shared Roms\KANJI.rom.src"
  trg := EMUL_ROOT "\system\Machines\Shared Roms\KANJI.rom"
  FileUtil.makeLink(src, trg, true)
}

#Include %A_ScriptDir%\script\AbstractHotkey.ahk
