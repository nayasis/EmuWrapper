#SingleInstance, Force
#NoEnv
#Include, c:\app\emulator\ZZ_Library\Common.ahk
#Include, c:\app\emulator\ZZ_Library\FileUtil.ahk
#Include, c:\app\emulator\ZZ_Library\Xml.ahk

dirSrc := FileUtil.getParentDir(A_ScriptDir)
dirSrc := FileUtil.getParentDir(dirSrc)

debug("dirSrc: " dirSrc)

doc := FileUtil.readXml( "Oppai_inst.xml")
doc.setText("//InstallSetting/InstallPath", dirSrc)
doc.setText("//InstallSetting/RunExe", dirSrc "\Oppai.EXE")
doc.saveXML()

ExitApp