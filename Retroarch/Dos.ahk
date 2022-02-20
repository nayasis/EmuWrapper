#NoEnv
#include %A_ScriptDir%\script\AbstractFunction.ahk

imageDir := %0%
; imageDir := "\\NAS2\emul\image\DOS\Uncharted Water (en)"
; imageDir := "\\NAS2\emul\image\DOS\Uncharted Water (en)\_EL_CONFIG\dosboxConf\dosbox.conf"
; imageDir := "\\NAS2\emul\image\DOS\Neuromancer (en)\cga"
; imageDir := "\\NAS2\emul\image\DOS\Nanpa 2 (T-ko)\nanpa2"
; imageDir := "\\NAS2\emul\image\DOS\Brandish 3 (NW) (ko)"
; imageDir := "\\NAS2\emul\image\DOS\Heroes of Might and Magic 1"
; imageDir := "\\NAS2\emul\image\DOS\Ultima 8 - Pagan"
; imageDir := "\\NAS2\emul\image\DOS\Sangokushi 2 (koei)(ko)"
; imageDir := "\\NAS2\emul\image\DOS\Uncharted Water - test (koei)(en)"
; imageDir := "\\NAS2\emul\image\DOS\Cobra (loriciel)(fr)"
; imageDir := "\\NAS2\emul\image\DOS\Wasteland (en)"

option := getOption( imageDir )
config := setConfig( "dosbox_pure_libretro", option )

 ; config.core := "dosbox_svn_libretro"
; config.core := "dosbox_core_libretro"

makeAutoboot(imageDir,config)

imageFile := imageDir "\autoboot.bat"
if( ! FileUtil.exist(imageFile) )
  imageFile := getRomPath( imageDir, option, "bat|com|exe" )
if( imageFile == "" )
  imageFile := getRomPath( imageDir, option, "zip" )

writeConfig(config,imageFile)

runEmulator( imageFile, config )

ExitApp

makeAutoboot(imageDir, config) {

  ; if( FileUtil.getFiles(imageDir,"(?i).*\.((?!zip).*)$").MaxIndex() == "" ) {
  ;   debug("ZIP is used by DosboxPure.")
  ;   return
  ; }

  autoboot := RegExReplace(config.dosbox_startup,"#{path}",imageDir)

  if( config.core == "dosbox_svn_libretro" ) {
    cdroms := getCdroms(imageDir)
    if( cdroms.length() > 0 ) {
      images := ""
      for i, f in cdroms {
        images := images " """ f """"
      }
      autoboot := autoboot "imgmount D: " images " -t iso -ide 2m`n`n"
    }
  }

  if( config.dosbox_executable != "" && config.dosbox_executable != "AUTOBOOT.BAT" ) {
    autoboot := autoboot "`n" "C:`n" config.dosbox_executable
  }

  FileUtil.write( imageDir "\AUTOBOOT.DBP", "C:\AUTOBOOT.BAT" )
  FileUtil.write( imageDir "\AUTOBOOT.BAT", autoboot )

  config.Remove["dosbox_startup"]
  config.Remove["dosbox_executable"]

  debug(">> AUTOBOOT.BAT")
  debug(autoboot)

}


getCdroms(imageDir) {
  dirCdrom := imageDir "\_EL_CONFIG\cdrom"
  files := FileUtil.getFiles(dirCdrom,"i).*\.(cue)$")
  if( files.length() == 0 ) {
    files := FileUtil.getFiles(dirCdrom,"i).*\.(iso|bin)$")
  }
  return files
}


#include %A_ScriptDir%\script\AbstractHotkey.ahk