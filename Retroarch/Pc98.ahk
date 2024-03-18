#NoEnv
#include %A_ScriptDir%\script\AbstractFunction.ahk

imageDir := %0%
; imageDir := "\\NAS2\emul\image\PC98\Suiryuushi Gaiden (shanbara)(ja)"
 ;imageDir := "\\NAS2\emul\image\PC98\Policenauts (ja)"
; imageDir := "\\NAS\emul\image\PC98\Sacchan no Daibouken (agumix)(ja)"
 imageDir := "\\NAS2\emul\image\PC98\Dragon Buster (dempa shinbunsha)(ja)"

option := getOption( imageDir )
config := setConfig( "np2kai_libretro", option, true )
; config := setConfig( "nekop2_libretro", option )

setNpConfig(config)
applyCustomFont(imageDir, config)
fileCmd := makeCmd(imageDir)

; setCdRom( imageDir, config )
; setHdd( imageDir, config )
; setFdd( imageDir, config )

; imageFile := getRomPath( imageDir, option, "cmd|m3u|d88|fdi|fdd|hdm|nfd|xdf|tfd" )
;imageFile := getRomPath( imageDir, option, "cmd" )
writeConfig(config)

runEmulator(fileCmd, config)

deleteTempFile()

ExitApp

deleteTempFile() {
  tempFiles := FileUtil.getFiles( A_ScriptDir, ".*" )
  for i, file in tempFiles {
    size := FileUtil.getSize(file)
    if( size != 6 )
      continue
    FileUtil.delete( file )
  }
}

applyCustomFont( imageDir, config ) {

  fontPath := FileUtil.getFile( imageDir "\_EL_CONFIG\font\" )
  if( config.core == "np2kai_libretro" ) {
  	fontPath := nvl( fontPath, EMUL_ROOT "\system\np2kai\font.rom" )
  } else if( config.core == "nekop2_libretro" ) {
  	fontPath := nvl( fontPath, EMUL_ROOT "\system\np2\font.rom" )
  } else {
  	return
  }

  cfg := getCfg( config )
  if( ! FileUtil.exist(cfg.path) )
 	  FileAppend, % "[" cfg.section "]", % cfg.path  

  IniWrite, % fontPath, % cfg.path, % cfg.section, fontfile

  debug( "fontPath  : " fontPath )

}

setNpConfig( config ) {

  cfg := getCfg( config )

  ; set DIP switch
  dipswitch := "3e"

  if( config.np2kai_gdc_block == "2.5" ) {
    dipswitch .= " e3"
  } else {
    dipswitch .= " 63"
  }

  if( config.np2kai_cpu_mode == "low" ) {
    dipswitch .= " fb"
  } else {
    dipswitch .= " 7b"
  }

  IniWrite, % dipswitch, % cfg.path, % cfg.section, DIPswtch

	; set MEM switch
  IniRead, MEMswitch, % cfg.path, % cfg.section, MEMswtch
  debug( "MEMswtch (before) : " MEMswitch )

  ; boot priority
  ; - MEMswtch=48 05 04 08 0b 20 00 6e : 1 Floopy disk -> Hard disk
  ; - MEMswtch=48 05 04 08 2b 20 00 6e : 2 Boot on 640KB Floop disk
  ; - MEMswtch=48 05 04 08 4b 20 00 6e : 3 Boot on 1MB Floop disk
  ; - MEMswtch=48 05 04 08 ab 20 00 6e : 4 Boot on hard disk 1
  ; - MEMswtch=48 05 04 08 bb 20 00 6e : 5 Boot on hard disk 2
  ; - MEMswtch=48 05 04 08 fb 20 00 6e : 6 ROM BASIC

  switch config.bootPrior {
    case "1" : MEMswitch := RegExReplace( MEMswitch, "(.. .. .. ..) .(.) (.. .. ..)", "$1 0$2 $3")
    case "2" : MEMswitch := RegExReplace( MEMswitch, "(.. .. .. ..) .(.) (.. .. ..)", "$1 2$2 $3")
    case "3" : MEMswitch := RegExReplace( MEMswitch, "(.. .. .. ..) .(.) (.. .. ..)", "$1 4$2 $3")
    case "4" : MEMswitch := RegExReplace( MEMswitch, "(.. .. .. ..) .(.) (.. .. ..)", "$1 a$2 $3")
    case "5" : MEMswitch := RegExReplace( MEMswitch, "(.. .. .. ..) .(.) (.. .. ..)", "$1 b$2 $3")
    case "6" : MEMswitch := RegExReplace( MEMswitch, "(.. .. .. ..) .(.) (.. .. ..)", "$1 f$2 $3")
  }
  debug( "MEMswtch (after)  : " MEMswitch )
    
  IniWrite, % MEMswitch, %NekoIniFile%, NekoProjectIIkai, MEMswtch

  ; seekSnd := config.np2kai_Seek_Snd == "ON" ? "true" : "false"

  debug( ">> seek snd : " (config.np2kai_Seek_Snd == "ON" ? "true" : "false") )
  debug( ">> seek vol : " config.np2kai_Seek_Vol )

  IniWrite, % " " (config.np2kai_Seek_Snd == "ON" ? "true" : "false"), %NekoIniFile%, NekoProjectIIkai, Seek_Snd
  ; IniWrite, % " " config.np2kai_Seek_Vol, %NekoIniFile%, NekoProjectIIkai, Seek_Vol

  ; ExitApp

}

getCfg( config ) {
  if( config.core == "np2kai_libretro" ) {
  	cfgPath := EMUL_ROOT "\system\np2kai\np2kai.cfg"
  	section := "NekoProjectIIkai"
  } else if( config.core == "nekop2_libretro" ) {
  	cfgPath := EMUL_ROOT "\system\np2\np2.cfg"
  	section := "NekoProjectII"
  }
  return { "path" : cfgPath, "section" : section }
}

makeCmd(imageDir) {

  files := FileUtil.getFiles( imageDir, "i).*\.(d88|d98|fdi|fdd|hdm|nfd|xdf|tfd)$" )
  hdd   := FileUtil.getFile( imageDir, "i).*\.(hdi|hdd)$" )
  cdrom := getCdrom( imageDir )
  if( hdd != "" )
    files.push( hdd )
  if( cdrom != "" )
    files.push( cdrom )

  cmd := "np2kai"
  for i, file in files {
    cmd .= " " wrap(file)
  }

  fileCmd := A_ScriptDir "\Pc98.cmd"
  FileUtil.write(fileCmd, cmd)
  debug(">> fileCmd: " fileCmd ", cmd: " cmd)
  return fileCmd

}

getCdrom( imageDir ) {
  dir := imageDir "\_EL_CONFIG\cdrom"
  cdRom := FileUtil.getFile( dir, "i).*\.(cue)$" )
  if( cdRom == "" )
    cdRom := FileUtil.getFile( dir, "i).*\.(ccd)$" )
  if( cdRom == "" )
    cdRom := FileUtil.getFile( dir, "i).*\.(iso|bin|img)$" )  
  return cdRom
}

setHdd( imageDir, config ) {
 	cfg := getCfg( config )
	hdd := FileUtil.getFile( imageDir, "i).*\.(hdi|hdd)$" )
  IniWrite, % hdd, % cfg.path, % cfg.section, HDD1FILE
}

setFdd( imageDir, config ) {
	cfg := getCfg( config ) 
	files := FileUtil.getFiles( imageDir, "i).*\.(d88|fdi|fdd|hdm|nfd|xdf|tfd)$" )
	Loop, % 2
	{
		if( A_Index > 2 )
			break
		IniWrite, % files[a_index], % cfg.path, % cfg.section, FDD%a_index%FILE
	}
}

#include %A_ScriptDir%\script\AbstractHotkey.ahk