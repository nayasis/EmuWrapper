#SingleInstance, Force
#Requires AutoHotkey >=2.0
#Include, d:\app\emulator\ZZ_Library\Common.ahk
#Include, d:\app\emulator\ZZ_Library\FileUtil.ahk
#Include, d:\app\emulator\ZZ_Library\Xml.ahk

dirSrc := FileUtil.getParentDir(A_ScriptDir)
dirSrc := FileUtil.getParentDir(dirSrc)

debug("dirSrc: " dirSrc)

doc := FileUtil.readXml( "nanpa2_re_inst.xml")
doc.setText("//InstallSetting/InstallPath", dirSrc)
doc.setText("//InstallSetting/RunExe", dirSrc "\Oppai.EXE")
doc.saveXML()

ExitApp