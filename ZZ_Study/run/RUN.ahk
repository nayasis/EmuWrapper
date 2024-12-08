#NoEnv
#Include, c:\app\emulator\ZZ_Library\Common.ahk
#Include, c:\app\emulator\ZZ_Library\FileUtil.ahk
#Include, c:\app\emulator\ZZ_Library\ResolutionChanger.ahk
#Include, c:\app\emulator\ZZ_Library\Xml.ahk
#Include, c:\app\emulator\ZZ_Library\Taskbar.ahk

FileEncoding, UTF-8
FileEncoding, UTF-8
DetectHiddenWindows, On

global applicationPid       := ""
global applicationCloseWait := ""
global applicationCloseWin  := ""
global applicationCloseProc := ""

SplitPath, A_ScriptName, , , , NoextScriptFileName

fileIni := A_ScriptDir "\" NoextScriptFileName ".ini"
fileReg := A_ScriptDir "\" NoextScriptFileName ".reg"

runAsAdmin( fileIni )

prop := readProperties( fileIni )

setEnvVariable( fileIni, prop )
setRegistry( fileReg, prop )

runSub( "pre", fileIni, prop )
runMain( fileIni, prop )
runSub( "post", fileIni, prop )

closeApp()

ExitApp

closeApp() {
	closeProcess()
	ResolutionChanger.restore()
	Taskbar.show(true)
	MouseCursor.show()	
	ExitApp
}

closeProcess() {
	debug(">> close process")
	if( applicationPid != "" ) {
		debug("  - applicationId: " applicationPid)
		Process, Close, % applicationPid
	}
	if( applicationCloseWait != "" ) {
		debug("  - applicationCloseWait: " applicationCloseWait)
		Process, Close, % applicationCloseWait
	}
	if( applicationCloseWin != "" ) {
		debug("  - applicationCloseWin: " applicationCloseWin)
		Process, Close, % applicationCloseWin
	}
	if( applicationCloseProc != "" ) {
		debug("  - applicationCloseProc: " applicationCloseProc)
		Process, Close, % applicationCloseProc
	}
}

runAsAdmin(fileIni) {
	IniRead, value, % fileIni, init, runAsAdmin, false
	if ( value == "true" ) {
		Environment.restartAsAdmin()
	}
}

runMidThread:
  SetTimer, runMidThread, off
  runSub( "mid", fileIni, prop )
  return

runSub( section, fileIni, properties ) {

	debug(">> run " section)

  indices = ,0,1,2,3,4,5,6,7,8,9

  loop, parse, indices, `,
  {
		executor      := readIni(fileIni, section, "executor" a_loopfield,         properties, "_")
		executorDir   := readIni(fileIni, section, "executor" a_loopfield "Dir",   properties, "_")
		executorDelay := readIni(fileIni, section, "executor" a_loopfield "Delay", properties, "_")
		executorWait  := readIni(fileIni, section, "executor" a_loopfield "Wait",  properties, "true")
    executorDelay := RegExReplace( executorDelay, "[^0-9]", "" )
    if ( executorDelay != "_" ) {
    	Sleep, %executorDelay%
    }
		if ( executor != "_" ) {
			executorWait  := (executorWait == "true" || executorWait == "_")
			runSubHelper( executor, executorDir, executorWait, properties )
		}
  }

  resolution      := readIni(fileIni, section, "resolution",    properties, "_")
  resolutionDelay := readIni(fileIni, section, "resolutionSec", properties, "_")
  if( resolution != "_" ) {
    if( resolutionDelay != "_" ) {
    	sleep, % resolutionDelay
    }
    changeResolution(resolution)
  }

  loop, parse, indices, `,
  {
	  waitWin         := readIni(fileIni, section, "waitWin"   a_loopfield,       properties, "_")
	  waitWinSec      := readIni(fileIni, section, "waitWin"   a_loopfield "Sec", properties, "10")
	  waitProc        := readIni(fileIni, section, "waitProc"  a_loopfield,       properties, "_")
	  waitProcSec     := readIni(fileIni, section, "waitProc"  a_loopfield "Sec", properties, "10")

		if ( waitWin != "_" ) {
			applicationwaitWin := RegExReplace(waitWin,"i)^ahk_(exe|class)\s+(\S+).*$","$2")
			debug("- waitWin : " waitWin )
			WinWait, % waitWin,, % waitWinSec
			IfWinExist
			{
				debug("wait win close : " waitWin)
				WinWaitClose, % waitWin,,
			}
			else
			{
				break
			}
		}

		if ( waitProc != "_" ) {
			applicationCloseProc := waitProc
			debug("- waitProc : " waitProc )
			Process, Wait, % waitProc, % waitProcSec
			if(ProcessExist(waitProc)) {
				debug("wait proc close: " waitProc)
				Process, WaitClose, % waitProc,
			} else {
				break
			}
		}

  }

  closeWin        := readIni(fileIni, section, "closeWin"  a_loopfield,       properties, "_")
  closeWinSec     := readIni(fileIni, section, "closeWin"  a_loopfield "Sec", properties, "10")
  closeProc       := readIni(fileIni, section, "closeProc" a_loopfield,       properties, "_")
  closeProcSec    := readIni(fileIni, section, "closeProc" a_loopfield "Sec", properties, "10")

	if ( closeWin != "_" ) {
		applicationCloseWin := RegExReplace(closeWin,"i)^ahk_(exe|class)\s+(\S+).*$","$2")
		debug("- closeWin : " closeWin )
		WinWait, % closeWin,, % closeWinSec
		WinClose, % closeWin,,
	}

	if ( closeProc != "_" ) {
		applicationCloseProc := RegExReplace(closeProc,"i)^ahk_(exe|class)\s+(\S+).*$","$2")
		debug("- closeProc : " closeProc )
		Process, Wait, % closeProc, % closeProcSec 
		Process, Close, % closeProc
	}

}

ProcessExist(Name) {
	Process,Exist,%Name%
	return Errorlevel
}

runSubHelper( executor, executorDir, executorWait, properties ) {
	if ( executor == "_" )
		return
  if( InStr(executor, ":scriptEnter\", true) ) {
  	param := StrReplace(executor, ":scriptEnter\","")
  	scriptEnter(param)
  	return
  }
  if( InStr(executor, ":scriptClick\", true) ) {
  	param := StrReplace(executor, ":scriptClick\","")
  	param := StrSplit(param, ",")
  	debug(param[1] "," param[2] "," param[3])
  	scriptClick(param[1],param[2],param[3])
  	return
  }
	executor    := RegExReplace( executor,    "\\", "\\" )
	executorDir := RegExReplace( executorDir, "\\", "\\" )
	if ( executorDir == "_" ) {
		SplitPath, executor, , executorDir
	}
	if ( executorWait == true ) {
		runWait(executor, executorDir)
	} else {
		run(executor, executorDir)
	}
}

runMain( fileIni, properties ) {

  debug(">> run main")

  executor          := readIni(fileIni, "init",   "executor",     properties, "_")
  unblockPath       := readIni(fileIni, "init",   "unblockPath",  properties, "_")
  executorDir       := readIni(fileIni, "init",   "executorDir",  properties, "_")
  resolution        := readIni(fileIni, "init",   "resolution",   properties, "_")
  hideTaskbar       := readIni(fileIni, "init",   "hideTaskbar",  properties, "_")
  hideMouse         := readIni(fileIni, "init",   "hideMouse",    properties, "_")
  symlink           := readIni(fileIni, "init",   "symlink",      properties, "_")
  blockNetwork      := readIni(fileIni, "init",   "blockNetwork", properties, "_")
  isRunWait         := readIni(fileIni, "init",   "runwait",      properties, true)
  exitAltF4         := readIni(fileIni, "init",   "exitAltF4",    properties, true)
  fontPath          := readIni(fileIni, "init",   "font",         properties, "_")
  mountImage        := readIni(fileIni, "init",   "mountImage",   properties, "_")
  windowTarget      := readIni(fileIni, "window", "target",       properties, "_")
  windowSearchDelay := readIni(fileIni, "window", "searchDelay",  properties, 0)
  windowStart       := readIni(fileIni, "window", "start",        properties, "_")
  windowSize        := readIni(fileIni, "window", "size",         properties, "_")
  windowBorderless  := readIni(fileIni, "window", "borderless",   properties, false)
  windowNeedResize  := ( windowStart != "_" || windowSize != "_" )

  makeSymlink(symlink)

  if ( unblockPath != "_" )
  	runWait("powershell unblock-file ""-path \""" unblockPath "\""""", "")

	if ( resolution != "_" ) {
		changeResolution( resolution )
		if ( windowSize == "_" ) {
		    windowSize := resolution
		}
	}

	blockNetwork(blockNetwork)
  installFont(fontPath, properties)

	if ( mountImage != "_" ) {
		VirtualDisk.mount(mountImage)
	}

  if ( exitAltF4 == "true" )
  	Hotkey, !F4, closeApp

	if ( windowStart == "_" )
	  windowStart := "0,0"

	if ( windowSize == "_" )
		windowSize := A_ScreenWidth "x" A_ScreenHeight

	if ( hideTaskbar == "true" )
		Taskbar.hide()

	if ( hideMouse == "true" )
		MouseCursor.hide()

	if ( executor != "_" ) {

    SetTimer, runMidThread, 500

		if ( executorDir == "_" )
		  executorDir := getRunDir(executor)

		debug( "executor     : " executor     )
		debug( "executorDir  : " executorDir  )
		debug( "windowTarget : " windowTarget )
		debug( "isRunWait    : " isRunWait    )

		if ( windowTarget != "_" ) {

			applicationPid := run(executor,executorDir)
			If(applicationPid == "")
				return
			sleep, % windowSearchDelay
			WinWait, %windowTarget%,, 10
			IfWinNotExist
			{
				MsgBox % "There is no window to wait.`n`n - " windowTarget
				return
			} else {
				WinGet, applicationPid, PID, %windowTarget%
			  startX := Trim( RegExReplace( windowStart, "i)^\D*?(\d*?)\D*?,\D*?(\d*?)\D*?$", "$1" ) )
			  startY := Trim( RegExReplace( windowStart, "i)^\D*?(\d*?)\D*?,\D*?(\d*?)\D*?$", "$2" ) )
		    width  := Trim( RegExReplace( windowSize,  "i)^\D*?(\d*?)\D*?x\D*?(\d*?)\D*?$", "$1" ) )
		    height := Trim( RegExReplace( windowSize,  "i)^\D*?(\d*?)\D*?x\D*?(\d*?)\D*?$", "$2" ) )
				debug( "target:" windowTarget ", borderless:" windowBorderless ", need resize:" windowNeedResize ", start:(" startX "," startY "), resolution:" width "x" height )

				WinActivate
		    if ( windowBorderless == "true" ) {
		    	debug("- set borderless")
					WinSet, Style, -0xC40000
		    }
		    if( windowNeedResize == true )  {
		    	debug("- resize")
					WinMove,,, %startX%, %startY%, %width%, %height%
					MouseMove, %width% + startY, %height% + startX
		    }

				WinWaitClose, % windowTarget

			}

		} else if ( isRunWait == true ) {
			runWait(executor,executorDir)
			; applicationPid := run(executor,executorDir)
			; Process, Wait, % applicationPid
		} else {
			run(executor,executorDir)
		}

		VirtualDisk.unmount()

	}

}

blockNetwork(param) {
	if (param == "_")
		return
	rules := StrSplit(param, ";")
	for i, rule in rules {
		arr := StrSplit(rule, "->")
		if (arr.MaxIndex() == 2) {
			name := Trim(arr[1])
			path := Trim(arr[2])
			Network.block(name, path)
		}
	}
}

installFont(fontDir, properties) {
	if ( fontDir == "_" )
		return
	winDir := properties["windir"] "\Fonts"
	fonts  := FileUtil.getFiles(fontDir)
	for i, path in fonts {
		installed := winDir "\" FileUtil.getName(path)
		if( ! FileUtil.isFile(installed) ) {
			debug(">> install font : " path " -> " installed)
			Environment.restartAsAdmin()
			FileCopy, % path, % winDir
			DllCall("AddFontResource", Str, installed)
			SendMessage,  0x1D,,,, ahk_id 0xFFFF
		}
	}
	
}

readProperties(file) {

	prop     := []
	readMode := false

	Loop, Read, %file%
	{
		if RegExMatch(A_LoopReadLine, "^#.*" )
			continue
		if ( readMode == false ) {
			if RegExMatch(A_LoopReadLine, "i)^\[properties\]" )
				readMode = true
			continue
		} else {
			If RegExMatch(A_LoopReadLine, "^\[.*\]" ) {
				readMode = false
				continue
			}
		}

		line := removeComment(A_LoopReadLine)
    key := RegExReplace( line, "^(.*?)=.*?$", "$1" )
    val := RegExReplace( line, "^.*?=(.*?)$", "$1" )

		prop[ Trim(key) ] := Trim(val)
	}

	; set default
	prop["cd"    ] := A_ScriptDir
	prop["cdWin" ] := RegExReplace( A_ScriptDir, "\\", "\\" ) ; double file seperator slash
	prop["cdUnix"] := RegExReplace( A_ScriptDir, "\\", "/" ) ; normal file seperator

	EnvGet, userHome, userprofile
	prop["home"  ] := userHome

  EnvGet, windir, SystemRoot
  prop["windir"] := windir

  prop["sid"   ] := readSID()
  prop["drive" ] := readDrive()

	return prop

}

readSID() {
	Loop , HKLM , SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList, 1, 1
  {
    if A_LoopRegName = ProfileImagePath
    {
      RegRead , OutputVar
      if outputvar contains %A_UserName%
        StringReplace , SID, A_LoopRegSubKey, SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\ ,,
    }
  }
  return SID
}

readDrive() {
	EnvGet, root, SystemDrive
	StringReplace, root, root, :,,
	return root
}

removeComment(text) {
	return Trim(RegExReplace( text, "#.*$", "" ))
}

setEnvVariable( fileIni, properties ) {

	IniRead, env, %fileIni%, init, env, _

	if( env == "_" )
	  return
	envs := StrSplit( "" env, ";" )

	for i, env in envs {

		overwrite := true

		key := "____"
		val := "____"

		path := StrSplit( env, "+=" )
		if ( path.MaxIndex() == 2 ) {
			key := Trim( path[1] )
			val := Trim( path[2] )
			overwrite := false
		} else {
			path := StrSplit( env, "=" )
			if ( path.MaxIndex() == 2 ) {
				key := Trim( path[1] )
				val := Trim( path[2] )
				overwrite := true
			} if ( path.MaxIndex() == 1 ) {
				key := Trim( path[1] )
				val := ""
				overwrite := true
			}
		}

		if( key != "____" && val != "____" ) {

      key := bindValue( key, properties )
      val := bindValue( val, properties )

			debug( ">> EnvSet"                 )
			debug( "   key       : " key       )
			debug( "   value     : " val       )
			debug( "   overwrite : " overwrite )

			prevEnv := ""

			if( overwrite == false ) {
				EnvGet, prevEnv, % key
			}

			if( prevEnv != "" ) {
				EnvSet, % key, % prevEnv ";" val
			} else {
				EnvSet, % key, % val
			}

		}

	}

}

run(executor, executorDir, wait=false) {
	if(wait == true) {
		debug(">> run")
	} else {
		debug(">> runwait")
	}
	debug("- exe: " executor)
	debug("- dir: " executorDir)
	if(wait == true) {
		RunWait, % executor, % executorDir, UseErrorLevel, processId
	} else {
		Run, % executor, % executorDir, UseErrorLevel, processId
	}
	if ErrorLevel {
		debug("Error Level : " ErrorLevel)
	}
	if(ErrorLevel == "ERROR") {
    MsgBox % "There is no application to run.`n`n - " executor 
	}
	return processId
}

runWait(executor, executorDir) {
	return run(executor, executorDir, true)
}

getRunDir(executor) {
	SplitPath, executor, , executorDir
	return executorDir
}

readIni(fileIni, section, key, properties, defaultValue := "_") {
	IniRead, value, % fileIni, % section, % key, % defaultValue
	; value := removeComment(value)
	; debug("key:" key ", value:" value)
	return bindValue(value,properties)
}

scriptEnter(waitCmd) {
	WinWait, % waitCmd
	IfWinExist
	{
		WinActivate, % waitCmd
		Send, {Enter}
	}
}

scriptClick(waitCmd, px, py) {
	WinWait, % waitCmd
	IfWinExist
	{
		WinActivate, % waitCmd
		Click, % px "," py
	}
}

/**
* Set Registry from file
*
* @param file       {String} filePath contains data formatted Windows Registry
* @param properties {Array}  properties to bind
*/
setRegistry( file, properties ) {

	SetRegView 32
	writeRegistryFrom( file, properties )

	SetRegView 64
	writeRegistryFrom( file, properties )

}

/**
* Write Registry from file
*
* @param file       {String} filePath contains data formatted Windows Registry
* @param properties {Array}  properties to bind
*/
writeRegistryFrom( file, properties ) {

	regKey       := ""
	readNextLine := false
	isHex        := true

	Loop, Read, %file%
	{

		line := Trim( A_LoopReadLine )

		if RegExMatch(line, "^Windows Registry Editor" ) {
			continue
		} else if ( StrLen(line) == 0 ) {
			Continue
		} else if RegExMatch(line, "^\[.*\]" ) {
			regKey := RegExReplace( line, "^\[(.*)\]", "$1" )
			continue
		} else if ( regKey == "" ) {
			continue
		}

		regKey := bindValue( regKey, properties )

		if ( readNextLine == true ) {
			regVal := regVal line
		} else {

			regName := RegExReplace( line, "^(@|"".+?"")=.*$", "$1" )
			regName := RegExReplace( regName, "^""(.+?)""$","$1" )
			regName := RegExReplace( regName, "\\""", """" )
			regName := bindValue( regName, properties )
			regVal  := RegExReplace( line, "^(@|"".*?"")=(.*)$", "$2" )
			regVal  := RegExReplace( regVal, "\\""", """" )
			regType := "REG_SZ"

			; debug( regName ":" regVal )

      if ( regName == "@" ) {
      	regName := ""
      }

			if RegExMatch( regVal, "^"".*""$" ) {
				regType := "REG_SZ"
				regVal  := RegExReplace( regVal, "^""(.*)""$", "$1" )
				regVal  := bindValue( regVal, properties )
				isHex   := false
			} else if RegExMatch( regVal, "^dword:" ) {
				regType := "REG_DWORD"
				regVal  := RegExReplace( regVal, "^dword:(.*)$", "$1" )
				; regVal  := bindValue( regVal, properties )
				isHex   := false
			} else if RegExMatch( regVal, "^hex\(b\):" ) {
				regType := "REG_QWORD"
				regVal  := RegExReplace( regVal, "^hex\(b\):(.*)$", "$1" )
				; regVal  := bindValue( regVal, properties )
				isHex   := true
			} else if RegExMatch( regVal, "^hex\(7\):" ) {
				regType := "REG_MULTI_SZ"
				regVal  := RegExReplace( regVal, "^hex\(7\):(.*)$", "$1" )
				isHex   := true
			} else if RegExMatch( regVal, "^hex\(2\):" ) {
				regType := "REG_EXPAND_SZ"
				regVal  := RegExReplace( regVal, "^hex\(2\):(.*)$", "$1" )
				isHex   := true
			} else if RegExMatch( regVal, "^hex:" ) {
				regType := "REG_BINARY"
				regVal  := RegExReplace( regVal, "^hex:(.*)$", "$1" )
				isHex   := true
			}

		}

		if ( RegExMatch(line, "^.*\\$") ) {
			readNextLine := true
			continue
		} else {
			readNextLine := false
		}

		if ( isHex == true ) {
			regVal := RegExReplace( regVal, "[\\\t ]", "" )
		}

		if ( regType == "REG_DWORD" ) {
			regVal := "0x" regVal
		} else if ( regType == "REG_QWORD" ) {
			regVal := "0x" toNumberFromHex( regVal )
		} else if( regType == "REG_MULTI_SZ" ) {
			regVal := toStringFromHex( regVal )
		} else if( regType == "REG_EXPAND_SZ" ) {
			regVal := toStringFromHex( regVal )
		} else if( regType == "REG_BINARY" ) {
			StringReplace, regVal, regVal, % ",", , All
		}

		regName := bindValue( regName, properties )

    RegRead, oldVal, % regKey, % regName
    if(regVal == oldVal)
    	continue

    debug( "[" regKey "] " regName " - " regType ":" regVal )

		; if it needs to run as admin, restart itself
		if ( ! RegExMatch(regKey, "^(HKEY_CURRENT_USER|HKEY_USERS)\\.*$") ) {
			Environment.restartAsAdmin()
		}
		RegWrite, % regType, % regKey, % regName, % regVal

	}

}

bindValue( value, properties ) {
	For key, val in properties
		value := StrReplace( value, "${" key "}", val )
	return value
}

toStringFromHex( hexValue ) {

  if ! hexValue
    return 0

  array := StrSplit( hexValue, "," )

  if ( mod( array.MaxIndex(), 2 ) != 0 )
  	array.Insert( "00" )

  result := ""

  for i, element in array
  {
  	if ( mod(i,2) == 0 )
  		Continue
  	result := result chr( "0x" array[i + 1] array[i] )
  }

  return result

}

toNumberFromHex( hexValue ) {

  if ! hexValue
    return 0

  array := StrSplit( hexValue, "," )

  if ( mod( array.MaxIndex(), 2 ) != 0 )
  	array.Insert( "00" )

  result := ""

  for i, element in array
  {
  	if ( mod(i,2) == 0 )
  		Continue
  	result := array[i + 1] array[i] result
  }

  ;return "0x" result
  return "0x0000000c"

}

makeSymlink( symlink ) {

	if ( symlink == "_" )
		return

	if(! FileUtil.hasSymlinkAuth()) {
		debug(">> No symlink creating auth. run as Admin again")
		Environment.restartAsAdmin()
		FileUtil.createSymlinkAuth()
	}

	links := StrSplit( symlink, ";" )

	for i, link in links {
		debug( "link : " link )
		path := StrSplit( link, "->" )
		if ( path.MaxIndex() == 2 ) {
			sourceDir := Trim( path[1] )
			targetDir := Trim( path[2] )
			debug( ">> Make symlink" )
			debug( "   sourceDir : " sourceDir )
			debug( "   targetDir : " targetDir )
			FileUtil.makeLink(sourceDir, targetDir, true)
		}
	}

}

convertBase( fromBase, toBase, number ) {
  static u := A_IsUnicode ? "_wcstoui64" : "_strtoui64"
  static v := A_IsUnicode ? "_i64tow"    : "_i64toa"
  VarSetCapacity(s, 65, 0)
  value := DllCall("msvcrt.dll\" u, "Str", number, "UInt", 0, "UInt", fromBase, "CDECL Int64")
  DllCall("msvcrt.dll\" v, "Int64", value, "Str", s, "UInt", toBase, "CDECL")
  return s
}

changeResolution( resolutionConfig ) {
	if ( resolutionConfig != "_" ) {
    width  := Trim( RegExReplace( resolutionConfig, "i)^\D*?(\d*?)\D*?x\D*?(\d*?)\D*?$", "$1" ) )
    height := Trim( RegExReplace( resolutionConfig, "i)^\D*?(\d*?)\D*?x\D*?(\d*?)\D*?$", "$2" ) )
		ResolutionChanger.change( width, height )
	}
}