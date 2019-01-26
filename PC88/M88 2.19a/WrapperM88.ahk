#NoEnv
#include %A_ScriptDir%\..\..\ZZ_Library\Include.ahk
; SetKeyDelay, 0, 10, Play

global emulatorExe  := "M88.exe"

emulatorPid  := ""
imageDirPath := %0%
; imageDirPath := "\\NAS\emul\image\PC88\Ys 1 (1987)(Nihon Falcom)"
; imageDirPath := "\\NAS\emul\image\PC88\Ys 2 (1988)(Nihon Falcom)\"
; imageDirPath := "\\NAS\emul\image\PC88\Zeliard (1987)(Game Arts)"
; imageDirPath := "\\NAS\emul\image\PC88\Xak (1989)(Microcabin)"

fddContainer := new DiskContainer( imageDirPath, "i).*\.(d88|fdi|fdd|hdm|nfd|xdf|tfd)$" )
fddContainer.initSlot( 2 )

;// ---------------------------------------------------------------------------
;//	コマンドライン走査
;//
;//	書式:
;//	M88 [-flags] diskimagepath
;//
;//	-bN		basic mode (hex)
;//	-fA,B	flags (16進)	(A=flagsの中身, B=反映させるビット)
;//	-gA,B	flag2 (16進)	(A=flag2の中身, B=反映させるビット)
;//	-cCLK	clock (MHz) (10進)
;//	-F		フルスクリーン起動
;//
;//	N, A, B の値は src/pc88/config.h を参照．
;//	
;//	現バージョンでは設定ダイアログでは設定できない組み合わせも
;//	受け付けてしまうので要注意
;//	例えばマウスを使用しながらキーによるメニュー抑制なんかはヤバイかも．
;//
;//	例:	M88 -b31 -c8 -f10,10 popfulmail.d88
;//		V2 モード，8MHz，OPNA モードで popfulmail.d88 を起動する
;//	
;//	説明が分かりづらいのは百も承知です(^^;
;//	詳しくは下を参照するか，開発室にでも質問してください．
;//
;//	他のパラメータも変更できるようにしたい場合も，一言頂ければ対応します．
;//

if ( setConfig( imageDirPath ) == true ) {

	command := emulatorExe " -F " fddContainer.toOption(1)
	debug( command )
	Run, % command,,,emulatorPid
	waitEmulator()
	IfWinExist
	{
		activateEmulator()
		; maximizeWindows()
		insertDisk( "1", fddContainer.getFile(1) )
		Sleep, 500
		insertDisk( "2", fddContainer.getFile(2) )
		reset()
		Process, WaitClose, %emulatorPid%
	}

	debug( fddContainer.toOption(2) )
	
} else {
	RunWait, % emulatorExe,,,emulatorPid
}

ExitApp

!F4:: ; ALT + F4
	activateEmulator()
	Send {Alt up}{Alt}{C}{X}
	return

^+PGUP::
  ; Ctrl + Shift + Z + PgUp :: Remove Disk in Drive#1
	If GetKeyState( "z", "P" )
		fddContainer.removeDisk( "1", "removeDisk" )
	; Ctrl + Shift + PgUp :: Insert Disk in Drive#1
	else
		fddContainer.insertDisk( "1", "insertDisk" )
	return

^+PGDN:: ; Insert Disk in Drive#2
	; Ctrl + Shift + Z + PgDn :: Remove Disk in Drive#2
	If GetKeyState( "z", "P" )
		fddContainer.removeDisk( "2", "removeDisk" )
	; Ctrl + Shift + PgDn :: Insert Disk in Drive#2
	else
		fddContainer.insertDisk( "2", "insertDisk" )
	return

^+End:: ; Cancel Disk Change	
	fddContainer.cancel()
	return

^+Del:: ; Reset
  reset()
	return

^+Insert:: ; Toggle Speed
	Tray.showMessage( "Toggle speed" )
	activateEmulator()
	Send {F11}
	return

getOption( imageDirPath ) {
	dirConf := imageDirPath "\_EL_CONFIG"
	IfExist %dirConf%\option\option.json
	{
		FileRead, jsonText, %dirConf%\option\option.json
		return JSON.load( jsonText )
	}
	return {}
}

waitEmulator() {
	WinWait, ahk_exe %emulatorExe%,,10
	IfWinExist
	  activateEmulator()
}

activateEmulator() {
	WinActivate, ahk_exe %emulatorExe%,,10
}

reset() {
	activateEmulator()
	Send {F12}
}

maximizeWindows() {
	activateEmulator()
	Send +{Enter}
}

insertDisk( slotNo, file ) {

	debug( "insert disk : " file )

	IfNotExist % file 
    return

  debug( "inserted : " file )

  activateEmulator()
	if( slotNo == "1" ) {
		removeDisk("1")
		Sleep, 100
		Send {Alt down}{Alt up}{1}{0}  ;FDD1
	} else if( slotNo == "2" ) {
		removeDisk("2")
		Sleep, 100
		Send {Alt down}{Alt up}{2}{0}  ;FDD2
	} else {
		return
	}
	
	WinWait, Open disk image
	IfWinExist
	{
		Send !{N}
		Clipboard = %file%
		Send ^v
		Send {Enter}
	}
    
}

removeDisk( slotNo ) {
	activateEmulator()
	if( slotNo == "1" ) {
		Send {Alt down}{Alt up}{1}{D}
	} else if( slotNo == "2" ) {
		Send {Alt down}{Alt up}{2}{D}
	} else {
		return
	}
}

setConfig( imageDirPath ) {

	currDir := FileUtil.getDir( imageDirPath )
	confDir := currDir . "\_EL_CONFIG"
	fileIni := % A_ScriptDir "\M88.ini"
	option  := getOption( imageDirPath )
	
	if ( currDir == "" ) {
		return false
	}
	
	sectionMain := "M88p2 for Windows"

	; Set font

	debug( "fileIni : " fileIni)
	
	IfExist %confDir%\font
	{
		Loop, %confDir%\font\*.*
		{
			FileUtil.copyFile( A_LoopFileFullPath, A_ScriptDir "\KANJI1.ROM" )
			break
		}
	} else {
		FileUtil.copyFile( A_ScriptDir "\KANJI1.ROM.src", A_ScriptDir "\KANJI1.ROM" )
	}

  ; PC88 Mode
	; IniWrite, 49, %iniFile%, % sectionMain, BASICMode

	IniWrite, % "", %iniFile%, % sectionMain, FD1NAME0
	IniWrite, % "", %iniFile%, % sectionMain, FD2NAME0

	files := FileUtil.getFiles( currDir, "i).*\.(d88|fdi|fdd|hdm|nfd|xdf|tfd)$" )
	Loop, % files.MaxIndex()
	{
		if( A_Index > 2 )
			break
		if ( option.run.singleFdd == "true" && a_index > 1 )
			break

		IniWrite, % files[a_index], % fileIni, % sectionMain, FD%a_index%NAME0
	}

	; Set option
	; option := getOption( imageDirPath )
	; if( option.config.BASICMode != "" )
	; 	IniWrite, % option.config.clk_mult, % fileIni, % sectionMain, BASICMode

  return true

}

