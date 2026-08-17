#Requires AutoHotkey >=2.0
#Include %A_ScriptDir%\script\AbstractFunction.ahk

imageDir := A_Args.Length ? A_Args[1] : ""
;imageDir := "\\NAS2\emul\image\DreamCast\Sakura Taisen 4 - Koi Seyo Otome (T-ko 0.3)"

option    := getOption(imageDir)
config    := setConfig("flycast_libretro", option, true)
; config    := setConfig( "reicast_libretro", option )
imageFile := getRomPath(imageDir, option, "m3u|chd|gdi|cdi|cue|iso|zip|7z")

writeConfig(config, imageFile)

applyTexture(imageDir)

runEmulator(imageFile, config)

debug( "wait sub process !" )
waitEmulator(1)
waitCloseEmulator()

ExitApp

applyTexture(imageDir) {
  for _, src in FileUtil.findDirs(imageDir "\_EL_CONFIG\textures", ".*", 1) {
    trg := EMUL_ROOT "\system\dc\textures\" . FileUtil.getName(src)
    FileUtil.makeLink(src, trg, true)
  }
}

#Include %A_ScriptDir%\script\AbstractHotkey.ahk