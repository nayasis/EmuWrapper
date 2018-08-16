#NoEnv

;; TestCode

; #include %A_ScriptDir%\Include.ahk
; file := "\\NAS\emul\image\MegaCd\Fahrenheit (32X) (En)\Fahrenheit_Disc-1.cue"
; ; file := "\\NAS\emul\image\PlayStation\Darius Gaiden (ja)\Darius Gaiden (Japan).mdx"
; if ( VirtualDisk.open( file ) == true ) {
;   MsgBox, % "Inserted ! (" file ")"
; }
; VirtualDisk.close()
; ExitApp

;
;-mount Mounts an optical virtual drive with an image file.
;       Syntax: -mount <type>,<n>,<path>
;       type - "dt", "scsi" or "ide" (*)
;       n    - device number (***)
;       path - path to file
;       Example: DTAgent.exe -mount ide, 0, "f:\test.iso"
;

class VirtualDisk {

  static void := VirtualDisk._init()

  _init() {
      ;this.daemonPath := "c:\Program Files (x86)\DAEMON Tools Lite\DTLite.exe"
      ; this.daemonPath   := "c:\Program Files\DAEMON Tools Lite\DTAgent.exe"
      this.daemonPath   := "c:\Program Files\DAEMON Tools Lite\DTCommandLine.exe"
      this.DRIVE_LETTER := "H"
  }

  __New() {
    throw Exception( "VirtualDisk is a static class, dont instante it!", -1 )
  }

  open( filePath, showError = false  ) {

    IfNotExist % this.daemonPath
    {
      if showError == true
        MsgBox % "VirtualDisk [" this.daemonPath "] is not exist."
        return false
    }

    IfNotExist %filePath%
    {
      if showError == true
        MsgBox % "File [" filePath "] is not exist."
      return false
    }
    
    fileExt       := this.getFileExt( filePath )
    fileExtWanted := "mdx,mdf,mds,iso,cue,bin,ccd"
    
    IfNotInString, fileExtWanted, %fileExt%
    {
      if showError == true
        MsgBox % "File [" filePath "] is not disk image. (" fileExtWanted ")"
      return false
    }

    ;   result := this._run( """" this.daemonPath """ -mount scsi, 0, """ filePath """" )
    ; if ( result == false ) {
    ;   result := this._run( """" this.daemonPath """ -mount scsi, " this.DRIVE_LETTER ", """ filePath """" )
    ; }
    ; if ( result == false ) {
    ;   result := this._run( """" this.daemonPath """ -mount_to " this.DRIVE_LETTER ", """ filePath """" )
    ; }
      result := this._run( """" this.daemonPath """ --mount -t ""scsi"" -l """ this.DRIVE_LETTER """ --ro --path """ filePath """" )
    if ( result == false ) {
      result := this._run( """" this.daemonPath """ --mount_to -l """ this.DRIVE_LETTER """ --ro --path """ filePath """" )
    }

    if ErrorLevel
    { 
      errorMsg := "VirtualDisk does not work properly for mounting cd image file [" filePath "]. (error level:" ErrorLevel ")"
      this.close()
      MsgBox % errorMsg
      return false
    }
    
    return true
  }
  
  close() {

      result := this._run( """" this.daemonPath """ --unmount -l """ this.DRIVE_LETTER """" )

    ;   result := this._run( """" this.daemonPath """ -unmount scsi, 0" )
    ; if ( result == false ) {
    ;   result := this._run( """" this.daemonPath """ -unmount " this.DRIVE_LETTER )
    ; }

    if ( result == false ) { 
      errorMsg := "VirtualDisk does not unmount (error level:" ErrorLevel ")"
      debug( errorMsg )
      MsgBox % errorMsg
      return false
    }

    return true

  }

  getFileExt( filePath ) {

    IfNotExist %filePath%
      return ""
    
    SplitPath, filePath,,, fileExt
    StringLower, fileExt, fileExt

    return fileExt
  }


  _run( commandLine ) {

    debug( commandLine )

    RunWait % commandLine

    if ErrorLevel
    { 
      debug( "`t`t" ErrorLevel )
      return false
    }

    return true

  }

}