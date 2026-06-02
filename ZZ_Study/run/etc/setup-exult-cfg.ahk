#Requires AutoHotkey >=2.0
#Include d:\app\emulator\ZZ_Library\Include.ahk

pathCfg := A_ScriptDir "\exult.cfg"
if !FileUtil.exist(pathCfg)
	ExitApp

cfgDoc := FileUtil.readXml(pathCfg)

node := cfgDoc.selectSingleNode("/config/disk/game/blackgate/path")
if node {
  node.text := A_ScriptDir . "\blackgate"
}

node := cfgDoc.selectSingleNode("/config/disk/game/serpentisle/path")
if node {
	node.text := A_ScriptDir . "\serpentisle"	
}

cfgDoc.save(pathCfg)

ExitApp