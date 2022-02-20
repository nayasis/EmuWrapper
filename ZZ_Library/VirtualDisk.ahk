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
      this.DRIVE_LETTER := "F"
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

    ; debug( commandLine )

    RunWait % commandLine

    if ErrorLevel
    { 
      debug( "`t`t" ErrorLevel )
      return false
    }

    return true

  }

}

/*

Commands:
  -a [ --add ]          Adds an optical virtual device.
  -m [ --mount ]        Mounts a new or existing optical virtual drive
                        depending on what is chosen in Preferences.
  -M [ --mount_to ]     Mounts existing optical virtual drive with an image
                        file.
  -u [ --unmount ]      Unmounts a virtual drive.
  -U [ --unmount_all ]  Unmounts all currently mounted images.
  -r [ --remove ]       Unmounts(if needed) and deletes the specified drive.
  -R [ --remove_all ]   Removes all virtual devices.
  -s [ --set_count ]    Sets quantity of optical virtual devices.
  -G [ --get_letter ]   Returns a letter assigned to an optical virtual device.
  -g [ --get_count ]    Returns the quantity of all virtual devices.
  -h [ --help ]         Shows this info.

Note that SCSI and IDE functionality is limited in Windows 10.

add command options:
  -t [ --type ] arg     "dt", "scsi" or "ide"
                        (IDE devices are available only with "Advanced Mount"
                        feature.)

                        Example: DTCommandLine.exe --add --type "dt"

mount command options:
  -t [ --type ] arg (=dt) "dt", "scsi" or "ide"
                          (Can not be used with *.iscsi, *.vhd, *.tc, *.hc,
                          *.vmdk and *.zip files)
  -l [ --letter ] arg     device letter
                          (If not specified, the first free letter will be used
                          by default. Can not be used for *.iscsi files)
  --pass arg              password for crypted *.tc, *.hc files
  --ro                    mount as read-only device
  -p [ --path ] arg       path to file

                        Example: DTCommandLine.exe --mount --letter "K" --pass "123" --ro --path "f:\test.tc"

mount_to command options:
  -l [ --letter ] arg   device letter
  --pass arg            password for crypted *.tc, *.hc files
  --ro                  mount as read-only device
  -p [ --path ] arg     path to file

                        Example: DTCommandLine.exe --mount_to --letter "K" --pass "123" --ro --path "f:\test.tc"

unmount command options:
  -l [ --letter ] arg   device letter

                        Example: DTCommandLine.exe --unmount --letter "K"

remove command options:
  -l [ --letter ] arg   device letter

                        Example: DTCommandLine.exe --remove --letter "K"

set_count command options:
  -t [ --type ] arg     "dt", "scsi" or "ide"
                        (IDE devices are available only with "Advanced Mount"
                        feature.)
  -n [ --number ] arg   number of virtual devices to be set
                        (Maximum number of allowed devices depends on
                        "Unlimited Devices" feature state.)

                        Example: DTCommandLine.exe --set_count --type "dt" --number 5

get_letter command options:
  -t [ --type ] arg     "dt", "scsi" or "ide"
  -n [ --number ] arg   device number.)

                        Example: DTCommandLine.exe --get_letter --type "dt" --number 1

get_count command options:
  -t [ --type ] arg     "hdd" , "dt", "scsi" or "ide"
                        (the total quantity will be returned if nothing is
                        specified)

                        Example: DTCommandLine.exe --get_count --type "scsi"

*/