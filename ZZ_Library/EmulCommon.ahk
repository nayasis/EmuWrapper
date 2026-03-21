#Requires AutoHotkey >=2.0

getOption(imageDir) {
  dirConf := imageDir "\_EL_CONFIG"
  debug(dirConf "\option\option.json")
  return FileUtil.readJson(dirConf "\option\option.json")
}

