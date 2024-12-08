#SingleInstance, Force
#NoEnv
#Include, c:\app\emulator\ZZ_Library\Common.ahk
#Include, c:\app\emulator\ZZ_Library\FileUtil.ahk
#Include, c:\app\emulator\ZZ_Library\Xml.ahk

dirSrc := FileUtil.getParentDir(A_ScriptDir)
debug("dirSrc: " dirSrc)
doc := FileUtil.readXml(dirSrc "/bin/_7thHeaven-v3.3.1.0_Release/7thWorkshop/settings.xml")

doc.setText("//Settings/LibraryLocation", dirSrc "\bin\mods\7th heaven")
doc.setText("//Settings/FF7Exe", dirSrc "\bin\FF7.exe")
doc.saveXML()

debug( doc.getText("//Settings/LibraryLocation") )
debug( doc.getText("//Settings/FF7Exe") )

ExitApp