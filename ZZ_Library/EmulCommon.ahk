#NoEnv

getOption(imageDir) {
  dirConf := imageDir "\_EL_CONFIG"
  return FileUtil.readJson(dirConf "\option\option.json")
}

