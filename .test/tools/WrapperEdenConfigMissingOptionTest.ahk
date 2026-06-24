#Requires AutoHotkey >=2.0
#include d:\app\emulator\ZZ_Library\Include.ahk

testDir := A_Temp "\WrapperEdenConfigMissingOptionTest"
FileUtil.delete(testDir, true)
DirCreate(testDir "\user\config")

configFile := testDir "\user\config\qt-config.ini"
FileUtil.write(configFile, "[System]`r`nlanguage_index\default=true`r`nlanguage_index=1`r`nregion_index\default=true`r`nregion_index=1`r`n`r`n[Core]`r`nuse_multi_core\default=true`r`nuse_multi_core=true`r`n`r`n[UI]`r`nfullscreen\default=true`r`nfullscreen=false`r`n")

setConfigForTest(JSON.parse("{ }", true), configFile)
verify(FileUtil.readIni(configFile, "System", "language_index") == "1", "empty option keeps language")
verify(FileUtil.readIni(configFile, "System", "region_index") == "1", "empty option keeps region")
verify(FileUtil.readIni(configFile, "Core", "use_multi_core") == "true", "empty option keeps multicore")

setConfigForTest(JSON.parse('{"system":{"language":"Korean (한국어)","region":"Korea","multicore":false,"fullscreen":true}}', true), configFile)
verify(FileUtil.readIni(configFile, "System", "language_index\default") == "false", "language default disabled")
verify(FileUtil.readIni(configFile, "System", "language_index") == "7", "language writes Korean")
verify(FileUtil.readIni(configFile, "System", "region_index") == "5", "region writes Korea")
verify(FileUtil.readIni(configFile, "Core", "use_multi_core") == "false", "multicore writes false")
verify(FileUtil.readIni(configFile, "UI", "fullscreen") == "true", "fullscreen writes true")

FileUtil.delete(testDir, true)

setConfigForTest(option, file) {
	system := option.get("system", JSON.Obj())
	if !(system is Object)
		return
	if system.has("language")
		writeSetting(file, "System", "language_index", toLanguageIndex(system.language))
	if system.has("region")
		writeSetting(file, "System", "region_index", toRegionIndex(system.region))
	if system.has("multicore")
		writeSetting(file, "Core", "use_multi_core", toIniBoolean(system.multicore))
	if system.has("fullscreen")
		writeSetting(file, "UI", "fullscreen", toIniBoolean(system.fullscreen))
}

writeSetting(file, section, key, value) {
	if (value == "")
		return
	FileUtil.writeIni(file, section, key "\default", "false")
	FileUtil.writeIni(file, section, key, value)
}

toIniBoolean(value) {
	return JSON.toBoolean(value, false) ? "true" : "false"
}

toLanguageIndex(value) {
	static aliases := Map(
		"japanese", 0,
		"englishamerican", 1, "english", 1, "en", 1,
		"french", 2,
		"german", 3,
		"italian", 4,
		"spanish", 5,
		"chinese", 6,
		"korean", 7, "ko", 7,
		"dutch", 8,
		"portuguese", 9,
		"russian", 10,
		"taiwanese", 11,
		"englishbritish", 12,
		"frenchcanadian", 13,
		"spanishlatin", 14,
		"chinesesimplified", 15,
		"chinesetraditional", 16,
		"portuguesebrazilian", 17,
		"polish", 18,
		"thai", 19
	)
	return toEnumIndex(value, aliases)
}

toRegionIndex(value) {
	static aliases := Map(
		"japan", 0,
		"usa", 1, "us", 1, "america", 1,
		"europe", 2,
		"australia", 3,
		"china", 4,
		"korea", 5, "kr", 5,
		"taiwan", 6
	)
	return toEnumIndex(value, aliases)
}

toEnumIndex(value, aliases) {
	if (value == "")
		return ""
	if IsInteger(value)
		return value
	text := Trim("" value)
	if (text ~= "^\d+$")
		return text
	key := RegExReplace(StrLower(text), "[^a-z0-9]", "")
	return aliases.Has(key) ? aliases[key] : ""
}

verify(condition, message) {
	if (!condition)
		throw Error(message)
}
