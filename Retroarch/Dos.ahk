#NoEnv
#include %A_ScriptDir%\script\AbstractFunction.ahk

imageDir := %0%
;imageDir := "\\NAS2\emul\image\DOS\WIN98SE"
;imageDir := "\\NAS2\emul\image\DOS\Brandish 3 (falcom)(ko)"

option := getOption( imageDir )
config := setConfig( "dosbox_pure_libretro", option, true )

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

  ; dosbox-pure mount cdrom automatically
  if( config.core == "dosbox_svn_libretro" ) {
    cdroms := getCdroms(imageDir)
    if( cdroms.length() > 0 ) {
      images := ""
      for i, f in cdroms {
        images .= " " wrap(f)
      }
      ;autoboot := autoboot "imgmount d " images " -t iso -ide 2m`n`n"
      autoboot := autoboot "imgmount d " images " -t iso`n`n"
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