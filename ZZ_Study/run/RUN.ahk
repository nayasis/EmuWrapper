#Requires AutoHotkey >=2.0
#Include d:\app\emulator\ZZ_Library\Include.ahk

FileEncoding("UTF-8")
DetectHiddenWindows(true)

global applicationPid       := ""
global applicationCloseWait := ""
global applicationCloseWin  := ""
global applicationCloseProc := ""

SplitPath(A_ScriptName, , , , &NoextScriptFileName)

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

ExitApp()

closeApp() {
	closeProcess()
	ResolutionChanger.restore()
	Taskbar.show(true)
	MouseCursor.show()	
	ExitApp()
}

closeProcess() {
	global applicationPid, applicationCloseWait, applicationCloseWin, applicationCloseProc
	debug(">> close process")
	if( applicationPid != "" ) {
		debug("  - applicationId: " applicationPid)
		ProcessClose(applicationPid)
	}
	if( applicationCloseWait != "" ) {
		debug("  - applicationCloseWait: " applicationCloseWait)
		ProcessClose(applicationCloseWait)
	}
	if( applicationCloseWin != "" ) {
		debug("  - applicationCloseWin: " applicationCloseWin)
		ProcessClose(applicationCloseWin)
	}
	if( applicationCloseProc != "" ) {
		debug("  - applicationCloseProc: " applicationCloseProc)
		ProcessClose(applicationCloseProc)
	}
}

runAsAdmin(fileIni) {
	value := readIni(fileIni, "init", "runAsAdmin", "", "false")
	if ( value == "true" ) {
		Environment.restartAsAdmin()
	}
}

runMidThread() {
	global fileIni, prop
	runSub( "mid", fileIni, prop )
}

runSub( section, fileIni, properties ) {

	debug(">> run " section)

  indices := ",0,1,2,3,4,5,6,7,8,9"

  for _, loopField in StrSplit(indices, ",")
  {
		executor      := readIni(fileIni, section, "executor" loopField,         properties, "_")
		executorDir   := readIni(fileIni, section, "executor" loopField "Dir",   properties, "_")
		executorDelay := readIni(fileIni, section, "executor" loopField "Delay", properties, "_")
		executorWait  := readIni(fileIni, section, "executor" loopField "Wait",  properties, "true")
    executorDelay := RegExReplace( executorDelay, "[^0-9]", "" )
    if ( executorDelay != "" ) {
    	Sleep(executorDelay)
    }
		if ( executor != "_" ) {
			executorWait  := (executorWait == "true" || executorWait == "_")
			runSubHelper( executor, executorDir, executorWait, properties )
		}
  }

  resolution      := readIni(fileIni, section, "resolution",    properties, "_")
  resolutionDelay := readIni(fileIni, section, "resolutionSec", properties, "_")
  if( resolution != "_" ) {
    if( resolutionDelay != "_" && resolutionDelay != "" ) {
    	Sleep(resolutionDelay)
    }
    changeResolution(resolution)
  }

  for _, loopField in StrSplit(indices, ",")
  {
	  waitWin         := readIni(fileIni, section, "waitWin"   loopField,       properties, "_")
	  waitWinSec      := readIni(fileIni, section, "waitWin"   loopField "Sec", properties, "10")
	  waitProc        := readIni(fileIni, section, "waitProc"  loopField,       properties, "_")
	  waitProcSec     := readIni(fileIni, section, "waitProc"  loopField "Sec", properties, "10")

		if ( waitWin != "_" ) {
			applicationwaitWin := RegExReplace(waitWin,"i)^ahk_(exe|class)\s+(\S+).*$","$2")
			debug("- waitWin : " waitWin )
			WinWait(waitWin,, waitWinSec)
			if WinExist(waitWin) {
				debug("wait win close : " waitWin)
				WinWaitClose(waitWin)
			}
			else {
				break
			}
		}

		if ( waitProc != "_" ) {
			applicationCloseProc := waitProc
			debug("- waitProc : " waitProc )
			ProcessWait(waitProc, waitProcSec)
			if(ProcessExistsByName(waitProc)) {
				debug("wait proc close: " waitProc)
				ProcessWaitClose(waitProc)
			} else {
				break
			}
		}

  }

  for _, loopField in StrSplit(indices, ",")
  {
    closeWin        := readIni(fileIni, section, "closeWin"  loopField,       properties, "_")
    closeWinSec     := readIni(fileIni, section, "closeWin"  loopField "Sec", properties, "10")
    closeProc       := readIni(fileIni, section, "closeProc" loopField,       properties, "_")
    closeProcSec    := readIni(fileIni, section, "closeProc" loopField "Sec", properties, "10")

		if ( closeWin != "_" ) {
			applicationCloseWin := RegExReplace(closeWin,"i)^ahk_(exe|class)\s+(\S+).*$","$2")
			debug("- closeWin : " closeWin )
			WinWait(closeWin,, closeWinSec)
			WinClose(closeWin)
		}

		if ( closeProc != "_" ) {
			applicationCloseProc := RegExReplace(closeProc,"i)^ahk_(exe|class)\s+(\S+).*$","$2")
			debug("- closeProc : " closeProc )
			ProcessWait(closeProc, closeProcSec)
			ProcessClose(closeProc)
		}
  }

}

ProcessExistsByName(name) {
	return ProcessExist(name) != 0
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
  if( InStr(executor, ":scriptFocus\", true) ) {
  	param := StrReplace(executor, ":scriptFocus\","")
  	scriptFocus(param)
  	return
  }
	executor    := RegExReplace( executor,    "\\", "\\" )
	executorDir := RegExReplace( executorDir, "\\", "\\" )
	if ( executorDir == "_" ) {
		SplitPath(executor, , &executorDir)
	}
	if ( executorWait == true ) {
		appRunWait(executor, executorDir)
	} else {
		appRun(executor, executorDir)
	}
}

runMain( fileIni, properties ) {
	global applicationPid

  debug(">> run main")

  executor          := readIni(fileIni, "init",   "executor",     properties, "_")
  unblockPath       := readIni(fileIni, "init",   "unblockPath",  properties, "_")
  executorDir       := readIni(fileIni, "init",   "executorDir",  properties, "_")
  resolution        := readIni(fileIni, "init",   "resolution",   properties, "_")
  hideTaskbar       := readIni(fileIni, "init",   "hideTaskbar",  properties, "_")
  hideMouse         := readIni(fileIni, "init",   "hideMouse",    properties, "_")
  symlink           := readIni(fileIni, "init",   "symlink",      properties, "_")
  blockNetworkRule  := readIni(fileIni, "init",   "blockNetwork", properties, "_")
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
  	appRunWait('powershell unblock-file -path "' unblockPath '"', "")

	if ( resolution != "_" ) {
		changeResolution( resolution )
		if ( windowSize == "_" ) {
		    windowSize := resolution
		}
	}

	blockNetwork(blockNetworkRule)
  installFont(fontPath, properties)

	if ( mountImage != "_" ) {
		mountDisk(mountImage)
	}

  if ( exitAltF4 == "true" )
  	Hotkey("!F4", closeApp)

	if ( windowStart == "_" )
	  windowStart := "0,0"

	if ( windowSize == "_" )
		windowSize := A_ScreenWidth "x" A_ScreenHeight

	if ( hideTaskbar == "true" )
		Taskbar.hide()

	if ( hideMouse == "true" )
		MouseCursor.hide()

	if ( executor != "_" ) {

    SetTimer(runMidThread, -500)

		if ( executorDir == "_" )
		  executorDir := getRunDir(executor)

		debug( "executor     : " executor     )
		debug( "executorDir  : " executorDir  )
		debug( "windowTarget : " windowTarget )
		debug( "isRunWait    : " isRunWait    )

		if ( windowTarget != "_" ) {

			applicationPid := appRun(executor,executorDir,false,false)
			If(applicationPid == "")
				return
			Sleep(windowSearchDelay)
			WinWait(windowTarget,, 10)
			if !WinExist(windowTarget) {
				MsgBox("There is no window to wait.`n`n - " windowTarget)
				return
			} else {
				applicationPid := WinGetPID(windowTarget)
			  startX := Trim( RegExReplace( windowStart, "i)^\D*?(\d*?)\D*?,\D*?(\d*?)\D*?$", "$1" ) )
			  startY := Trim( RegExReplace( windowStart, "i)^\D*?(\d*?)\D*?,\D*?(\d*?)\D*?$", "$2" ) )
		    width  := Trim( RegExReplace( windowSize,  "i)^\D*?(\d*?)\D*?x\D*?(\d*?)\D*?$", "$1" ) )
		    height := Trim( RegExReplace( windowSize,  "i)^\D*?(\d*?)\D*?x\D*?(\d*?)\D*?$", "$2" ) )
				debug( "target:" windowTarget ", borderless:" windowBorderless ", need resize:" windowNeedResize ", start:(" startX "," startY "), resolution:" width "x" height )

				WinActivate(windowTarget)
		    if ( windowBorderless == "true" ) {
		    	debug("- set borderless")
					WinSetStyle("-0xC40000", windowTarget)
		    }
		    if( windowNeedResize == true )  {
		    	debug("- resize")
					WinMove(startX, startY, width, height, windowTarget)
					MouseMove(width + startY, height + startX)
		    }

				WinWaitClose(windowTarget)

			}

		} else if ( isRunWait == true ) {
			appRunWait(executor,executorDir,false)
			; applicationPid := appRun(executor,executorDir)
			; Process, Wait, % applicationPid
		} else {
			appRun(executor,executorDir,false,false)
		}

		if ( mountImage != "_" ) {
			unmountDisk(mountImage)
		}

	}

}

blockNetwork(param) {
	if (param == "_")
		return
	rules := StrSplit(param, ";")
	for i, rule in rules {
		arr := StrSplit(rule, "->")
		if (arr.Length == 2) {
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
			FileCopy(path, winDir)
			DllCall("AddFontResource", "Str", installed)
			SendMessage(0x1D, 0, 0,, "ahk_id 0xFFFF")
		}
	}
	
}

readProperties(file) {

	prop := FileUtil.readIni(file, "properties")
	if (Type(prop) != "Map")
		prop := Map()

	; set default
	prop["cd"    ] := A_ScriptDir
	prop["cdWin" ] := RegExReplace( A_ScriptDir, "\\", "\\" ) ; double file seperator slash
	prop["cdUnix"] := RegExReplace( A_ScriptDir, "\\", "/" ) ; normal file seperator

	userHome := EnvGet("userprofile")
	prop["home"  ] := userHome

  windir := EnvGet("SystemRoot")
  prop["windir"] := windir

  prop["sid"   ] := readSID()
  prop["drive" ] := readDrive()

	return prop

}

readSID() {
	sid := ""
	Loop Reg, "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList", "R"
  {
    if (A_LoopRegName = "ProfileImagePath")
    {
			try outputVar := RegRead(A_LoopRegKey, A_LoopRegName)
			catch
				outputVar := ""
      if InStr(outputVar, A_UserName)
        sid := RegExReplace(A_LoopRegKey, "i)^.*ProfileList\\")
    }
  }
  return sid
}

readDrive() {
	root := EnvGet("SystemDrive")
	root := StrReplace(root, ":")
	return root
}

setEnvVariable( fileIni, properties ) {

	env := readIni(fileIni, "init", "env", properties, "_")

	if( env == "_" )
	  return
	envs := StrSplit( "" env, ";" )

	for i, env in envs {

		overwrite := true

		key := "____"
		val := "____"

		path := StrSplit( env, "+=" )
		if ( path.Length == 2 ) {
			key := Trim( path[1] )
			val := Trim( path[2] )
			overwrite := false
		} else {
			path := StrSplit( env, "=" )
			if ( path.Length == 2 ) {
				key := Trim( path[1] )
				val := Trim( path[2] )
				overwrite := true
			} if ( path.Length == 1 ) {
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
				prevEnv := EnvGet(key)
			}

			if( prevEnv != "" ) {
				EnvSet(key, prevEnv ";" val)
			} else {
				EnvSet(key, val)
			}

		}

	}

}

appRun(executor, executorDir:="", wait:=false, hide:=true) {
	if(wait == true) {
		debug(">> run - wait")
	} else {
		debug(">> run - no wait")
	}
	debug("- exe: " executor)
	debug("- dir: " executorDir)

  option := "UseErrorLevel"
	if(hide) {
		option .= " Hide"
	}

	if(wait == true) {
		try {
			RunWait(executor, executorDir, option)
			processId := ""
		} catch Error as err {
			debug("Error Level : ERROR")
			MsgBox("There is no application to run.`n`n - " executor)
			debug(err.Message)
			processId := ""
		}
	} else {
		try {
			processId := Run(executor, executorDir, option)
		} catch Error as err {
			debug("Error Level : ERROR")
			MsgBox("There is no application to run.`n`n - " executor)
			debug(err.Message)
			processId := ""
		}
	}
	return processId
}

appRunWait(executor, executorDir:="", hide:=true) {
	return appRun(executor, executorDir, true, hide)
}

getRunDir(executor) {
	SplitPath(executor, , &executorDir)
	return executorDir
}

readIni(fileIni, section, key, properties := "", defaultValue := "_") {
	value := FileUtil.readIni(fileIni, section, key, defaultValue)

	if (Type(properties) == "Map")
		return bindValue(value, properties)
	return value
}

scriptEnter(waitCmd) {
	WinWait(waitCmd)
	if WinExist(waitCmd)
	{
		WinActivate(waitCmd)
		Send("{Enter}")
	}
}

scriptFocus(waitCmd) {
	WinWait(waitCmd)
	if WinExist(waitCmd)
	{
		WinActivate(waitCmd)
	}
}

scriptClick(waitCmd, px, py) {
	WinWait(waitCmd)
	if WinExist(waitCmd)
	{
		WinActivate(waitCmd)
		Click(px, py)
	}
}

/**
* Set Registry from file
*
* @param file       {String} filePath contains data formatted Windows Registry
* @param properties {Array}  properties to bind
*/
setRegistry( file, properties ) {

	SetRegView(32)
	writeRegistryFrom( file, properties )

	SetRegView(64)
	writeRegistryFrom( file, properties )

}

/**
* Write Registry from file
*
* @param file       {String} filePath contains data formatted Windows Registry
* @param properties {Array}  properties to bind
*/
writeRegistryFrom( file, properties ) {
	if !FileExist(file)
		return

	regKey       := ""
	readNextLine := false
	isHex        := true

	for loopLine in StrSplit(FileRead(file), "`n", "`r")
	{

		line := Trim(loopLine)

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

			regName := RegExReplace( line, '^(@|".+?")=.*$', "$1" )
			regName := RegExReplace( regName, '^"(.+?)"$', "$1" )
			regName := RegExReplace( regName, '\\"', '"' )
			regName := bindValue( regName, properties )
			regVal  := RegExReplace( line, '^(@|".*?")=(.*)$', "$2" )
			regVal  := RegExReplace( regVal, '\\"', '"' )
			regType := "REG_SZ"

			; debug( regName ":" regVal )

      if ( regName == "@" ) {
      	regName := ""
      }

			if RegExMatch( regVal, '^".*"$' ) {
				regType := "REG_SZ"
				regVal  := RegExReplace( regVal, '^"(.*)"$', "$1" )
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
			regVal := StrReplace(regVal, ",")
		}

		regName := bindValue( regName, properties )

		try oldVal := RegRead(regKey, regName)
		catch
			oldVal := ""
    if(regVal == oldVal)
    	continue

    debug( "[" regKey "] " regName " - " regType ":" regVal )

		; if it needs to run as admin, restart itself
		if ( ! RegExMatch(regKey, "^(HKEY_CURRENT_USER|HKEY_USERS)\\.*$") ) {
			Environment.restartAsAdmin()
		}
		RegWrite(regVal, regType, regKey, regName)

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

  if ( mod( array.Length, 2 ) != 0 )
  	array.Push( "00" )

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

  if ( mod( array.Length, 2 ) != 0 )
  	array.Push( "00" )

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
		if ( path.Length == 2 ) {
			sourceDir := Trim( path[1] )
			targetDir := Trim( path[2] )
			if (sourceDir = "" || targetDir = "")
				continue
			debug( ">> Make symlink" )
			debug( "   sourceDir : " sourceDir )
			debug( "   targetDir : " targetDir )
			try FileUtil.makeLink(sourceDir, targetDir, true)
			catch Error as err {
				debug("   symlink skipped: " err.Message)
			}
		}
	}

}

convertBase( fromBase, toBase, number ) {
  ; currently unused in this script. keep a safe passthrough for v2 compatibility.
  return number
}

changeResolution( resolutionConfig ) {
	if ( resolutionConfig != "_" ) {
    width  := Trim( RegExReplace( resolutionConfig, "i)^\D*?(\d*?)\D*?x\D*?(\d*?)\D*?$", "$1" ) )
    height := Trim( RegExReplace( resolutionConfig, "i)^\D*?(\d*?)\D*?x\D*?(\d*?)\D*?$", "$2" ) )
		ResolutionChanger.change( width, height )
	}
}

mountDisk(path) {
	cmd := wrap(path, '"')
	cmd := wrap("-ImagePath " cmd)
	cmd := "powershell -WindowStyle Hidden Mount-DiskImage " cmd
	appRunWait(cmd)
}

unmountDisk(path) {
	cmd := wrap(path, '"')
	cmd := wrap("-ImagePath " cmd)
	cmd := "powershell -WindowStyle Hidden Dismount-DiskImage " cmd
	appRunWait(cmd)
}
