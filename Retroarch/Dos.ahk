#Requires AutoHotkey >=2.0
#Include %A_ScriptDir%\script\AbstractFunction.ahk

imageDir := A_Args.Length ? A_Args[1] : ""
;imageDir := "\\NAS2\emul\image\DOS\WIN98SE"
;imageDir := "\\NAS2\emul\image\DOS\Brandish 3 (falcom)(ko)"
;imageDir := "\\NAS2\emul\image\DOS\CRW Metal Jacket (team kikai)(ko)"

option := getOption( imageDir )
config := setConfig( "dosbox_pure_libretro", option, true )

 ;config.core := "dosbox_svn_libretro"
 ;config.core := "dosbox_core_libretro"
 ;config.core := "dosbox_pure_libretro"

imageFile := getRomPath( imageDir, option, "m3u|m3u8" )
if( imageFile == "" )
  imageFile := getRomPath( imageDir, option, "zip|7z" )
if( imageFile == "" ) {
  makeAutoboot(imageDir,config)
  imageFile := imageDir "\autoboot.bat"
}

writeConfig(config,imageFile)

runEmulator( imageFile, config )

ExitApp

makeAutoboot(imageDir, config) {

  autoboot := RegExReplace(config.dosbox_startup,"(#{path}|\${cd})", imageDir)

  ; dosbox-pure mount cdrom automatically
  if( config.core == "dosbox_svn_libretro" ) {
    cdroms := getCdroms(imageDir)
    if (cdroms.Length > 0) {
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

  config.Delete("dosbox_startup")
  config.Delete("dosbox_executable")

  debug(">> AUTOBOOT.BAT")
  debug(autoboot)

}


getCdroms(imageDir) {
  dirCdrom := imageDir "\_EL_CONFIG\cdrom"
  files := FileUtil.getFiles(dirCdrom,"i).*\.(cue)$")
  if (files.Length == 0) {
    files := FileUtil.getFiles(dirCdrom,"i).*\.(iso|bin)$")
  }
  return files
}


#Include %A_ScriptDir%\script\AbstractHotkey.ahk