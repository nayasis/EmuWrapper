#NoEnv

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
runProgram( fileIni, prop )
runSub( "post", fileIni, prop )

ExitApp

closeApplication() {
	debug(">> close application")
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

runAsAdmin( fileIni ) {
	IniRead, value, % fileIni, init, runAsAdmin, false
	if ( value == "true" ) {
		restartAsAdmin()
	}
}

runMidThread:
  SetTimer, runMidThread, off
  runSub( "mid", fileIni, prop )
  return

runSub( section, fileIni, properties ) {
  indices = ,0,1,2,3,4,5,6,7,8,9
  loop, parse, indices, `,
  {
		IniRead, executor,      %fileIni%, %section%, executor%a_loopfield%,      _
		IniRead, executorDir,   %fileIni%, %section%, executor%a_loopfield%Dir,   _
		IniRead, executorDelay, %fileIni%, %section%, executor%a_loopfield%Delay, _
		IniRead, executorWait,  %fileIni%, %section%, executor%a_loopfield%Wait,  _
		IniRead, closeWait,     %fileIni%, %section%, closeWait%a_loopfield%,      _
		IniRead, closeWaitSec,  %fileIni%, %section%, closeWait%a_loopfield%Sec,   _
		IniRead, closeWin,      %fileIni%, %section%, closeWin%a_loopfield%,      _
		IniRead, closeWinSec,   %fileIni%, %section%, closeWin%a_loopfield%Sec,   _
		IniRead, closeProc,     %fileIni%, %section%, closeProc%a_loopfield%,      _
		IniRead, closeProcSec,  %fileIni%, %section%, closeProc%a_loopfield%Sec,   _

	  executor      := removeComment(executor)
	  executorDir   := removeComment(executorDir)
	  executorDelay := removeComment(executorDelay)
	  executorWait  := removeComment(executorWait)
	  closeWait     := removeComment(closeWait)
	  closeWaitSec  := removeComment(closeWaitSec)
	  closeWin      := removeComment(closeWin)
	  closeWinSec   := removeComment(closeWinSec)
	  closeProc     := removeComment(closeProc)
	  closeProcSec  := removeComment(closeProcSec)

		StringLower, executorWait, executorWait

		if ( executor != "_" ) {
			executor      := RegExReplace( executor,      "\\",     "\\" )
			executorDir   := RegExReplace( executorDir,   "\\",     "\\" )
			executorDelay := RegExReplace( executorDelay, "[^0-9]", ""   )
			executorWait  := executorWait == "true"
			runSubHelper( executor, executorDir, executorDelay, executorWait, properties )
		}
  }
	if ( closeWait != "_" ) {
		applicationCloseWait := RegExReplace(closeWait,"i)ahk_(exe|class) ","")
		WinWait, % closeWait,, % closeWaitSec
		WinWaitClose, % closeWait,,
	}

	if ( closeWin != "_" ) {
		applicationCloseWin := RegExReplace(closeWin,"i)ahk_(exe|class) ","")
		WinWait, % closeWin,, % closeWinSec
		WinClose, % closeWin,,
	}

	if ( closeProc != "_" ) {
		applicationCloseProc := RegExReplace(closeProc,"i)ahk_(exe|class) ","")
		Process, Wait, % closeProc, % closeProcSec 
		Process, Close, % closeProc
	}
}

runSubHelper( executor, executorDir, executorDelay, executorWait, properties ) {
	if ( executor == "_" )
		return
	if ( executorDelay != "_" )
		Sleep, %executorDelay%
	if ( executor == "!RESOLUTION" ) {
		debug( "executorDir in resolution : " executorDir )
		changeResolution( executorDir )
	} else {
		executor := bindValue( executor, properties )
		if ( executorDir == "_" ) {
			SplitPath, executor, , executorDir
		}
		executorDir := bindValue( executorDir, properties )
		if ( executorWait == "true" ) {
			RunWait, %executor%, %executorDir%, Hide
			debug( "closed ??")
		} else {
			Run, %executor%, %executorDir%, Hide
		}
	}
}

runProgram( fileIni, properties ) {

	IniRead, executor,          %fileIni%, init,   executor,     _
	IniRead, unblockPath,       %fileIni%, init,   unblockPath,  _
	IniRead, executorDir,       %fileIni%, init,   executorDir,  _
	IniRead, resolution,        %fileIni%, init,   resolution,   _
	IniRead, hideTaskbar,       %fileIni%, init,   hideTaskbar,  _
	IniRead, hideMouse,         %fileIni%, init,   hideMouse,    _
  IniRead, symlink,           %fileIni%, init,   symlink,      _
	IniRead, hideConsole,       %fileIni%, init,   hideConsole,  false
	IniRead, isRunWait,         %fileIni%, init,   runwait,      true
  IniRead, exitAltF4,         %fileIni%, init,   exitAltF4,    true
	IniRead, windowTarget,      %fileIni%, window, target,       _
	IniRead, windowSearchDelay, %fileIni%, window, searchDelay,  0
	IniRead, windowStart,       %fileIni%, window, start,        _
	IniRead, windowSize,        %fileIni%, window, size,         _
	IniRead, windowBorderless,  %fileIni%, window, borderless,   false

  executor          := removeComment(executor)
  unblockPath       := removeComment(unblockPath)
  executorDir       := removeComment(executorDir)
  resolution        := removeComment(resolution)
  hideTaskbar       := removeComment(hideTaskbar)
  hideMouse         := removeComment(hideMouse)
  symlink           := removeComment(symlink)
  hideConsole       := removeComment(hideConsole)
  isRunWait         := removeComment(isRunWait)
  exitAltF4         := removeComment(exitAltF4)
  windowTarget      := removeComment(windowTarget)
  windowSearchDelay := removeComment(windowSearchDelay)
  windowStart       := removeComment(windowStart)
  windowSize        := removeComment(windowSize)
  windowBorderless  := removeComment(windowBorderless)
  windowNeedResize  := ( windowStart != "_" || windowSize != "_" )

	hideConsole := hideConsole == "true" ? "Hide" : ""

	; executor    := RegExReplace( executor,    "\\", "\\" )
	; executorDir := RegExReplace( executorDir, "\\", "\\" )

  if ( unblockPath != "_" ) {
  	unblockPath := bindValue( unblockPath, properties )
  	command := "powershell unblock-file ""-path \""" unblockPath "\"""""
  	debug( command )
  	RunWait, % command,,Hide
  }

	if ( resolution != "_" ) {
		changeResolution( resolution )
		if ( windowSize == "_" ) {
		    windowSize := resolution
		}
	}

  if ( exitAltF4 == "true" ) {
  	Hotkey, !F4, closeApplication
  }

	if ( windowStart == "_" ) {
	  windowStart := "0,0"
	}

	if ( windowSize == "_" ) {
		windowSize := A_ScreenWidth "x" A_ScreenHeight
	}

	makeSymlink( symlink, properties )

	if ( hideTaskbar != "_" && hideTaskbar == "true" ) {
		Taskbar.hide()
	}

	if ( hideMouse != "_" && hideMouse == "true" ) {
		MouseCursor.hide()
	}

	if ( executor != "_" ) {

		executor := bindValue( executor, properties )
		; executorDir 변수에 executor의 경로만 담는다.
		if ( executorDir == "_" ) {
			SplitPath, executor, , executorDir
		}
		executorDir := bindValue( executorDir, properties )

		debug( "executor     : " executor     )
		debug( "executorDir  : " executorDir  )
		debug( "windowTarget : " windowTarget )
		debug( "isRunWait    : " isRunWait    )

		if ( windowTarget != "_" ) {

			SetTimer, runMidThread, 500
			Run, %executor%, %executorDir%,%hideConsole%,applicationPid
			Sleep, %windowSearchDelay%
			WinWait, %windowTarget%,, 20

			If ErrorLevel {
				MsgBox % "There is no window to wait.(" windowTarget ")"
				Process, Close, %applicationPid%
			} else {

				WinGet, applicationPid, PID, %windowTarget%

			  startX := Trim( RegExReplace( windowStart, "i)^\D*?(\d*?)\D*?,\D*?(\d*?)\D*?$", "$1" ) )
			  startY := Trim( RegExReplace( windowStart, "i)^\D*?(\d*?)\D*?,\D*?(\d*?)\D*?$", "$2" ) )
		    width  := Trim( RegExReplace( windowSize,  "i)^\D*?(\d*?)\D*?x\D*?(\d*?)\D*?$", "$1" ) )
		    height := Trim( RegExReplace( windowSize,  "i)^\D*?(\d*?)\D*?x\D*?(\d*?)\D*?$", "$2" ) )

				debug( "target:" windowTarget ", borderless:" windowBorderless ", need resize:" windowNeedResize ", start:(" startX "," startY "), resolution:" width "x" height )

		    if ( windowBorderless == "true" ) {
					WinSet, Style, -0xC40000, %windowTarget% ; remove the titlebar and border(s)
		    }

		    if( windowNeedResize == true )  {
					WinMove, %windowTarget%,, %startX%, %startY%, %width%, %height%  ; move the window to 0,0 and reize to width x height
					MouseMove, %width% + startY, %height% + startX
		    }

				WinWaitClose, %windowTarget%

			}

      ResolutionChanger.restore()
			Taskbar.show()
			MouseCursor.show()

		} else if ( isRunWait == "true" ) {

			SetTimer, runMidThread, 500
			RunWait, %executor%, %executorDir%, %hideConsole%, applicationPid

			ResolutionChanger.restore()
			Taskbar.show()
			MouseCursor.show()

		} else {
			SetTimer, runMidThread, 500
			Run, %executor%, %executorDir%,Hide
		}

	}

}

readProperties( file ) {

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
	prop[ "cd" ]     := A_ScriptDir
	prop[ "cdWin" ]  := RegExReplace( A_ScriptDir, "\\", "\\" ) ; double file seperator slash
	prop[ "cdUnix" ] := RegExReplace( A_ScriptDir, "\\", "/" ) ; normal file seperator

	EnvGet, userHome, userprofile
	prop[ "home" ] := userHome

	return prop

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

		; debug( "[" regKey "] " regName " - " regType ":" regVal )

		; if it needs to run as admin, restart itself
		if ( ! RegExMatch(regKey, "^(HKEY_CURRENT_USER|HKEY_USERS)\\.*$") ) {
			restartAsAdmin()
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

makeSymlink( symlink, properties ) {

	if ( symlink == "_" )
		return

	links := StrSplit( symlink, ";" )

	for i, link in links {
		link := bindValue( link, properties )
		debug( "link : " link )
		path := StrSplit( link, "->" )
		if ( path.MaxIndex() == 2 ) {
			sourceDir := Trim( path[1] )
			targetDir := Trim( path[2] )
			debug( ">> Make symlink" )
			debug( "   sourceDir : " sourceDir )
			debug( "   targetDir : " targetDir )
			FileUtil.makeLink( sourceDir, targetDir )
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

restartAsAdmin() {
	if not (A_IsAdmin) {
    try ; leads to having the script re-launching itself as administrator
    {
        if A_IsCompiled
            Run *RunAs "%A_ScriptFullPath%" /restart
        else
            Run *RunAs "%A_AhkPath%" /restart "%A_ScriptFullPath%"
    }
    ExitApp
	}
}

debug( message ) {
 if( A_IsCompiled == 1 )
   return
  message .= "`n"
  FileAppend %message%, * ; send message to stdout
}

class ResolutionChanger {

    static void    := ResolutionChanger._init()
    static changed := false

    _init() {
        this.srcWidth  := A_ScreenWidth
        this.srcHeight := A_ScreenHeight
    }

    change( width, height, colorDepth := 32, refreshRate := 60 ) {

    	If ( RegExMatch(width, "^\d+$") == false || RegExMatch(height, "^\d+$") == false ) {
        MsgBox Resolution must be consisted with digit values ( input values : [%width%]x[%height%])
        return
    	}

			VarSetCapacity( deviceMode, 156, 0 )
			NumPut( 156, deviceMode, 36 )
			DllCall( "EnumDisplaySettingsA", UInt, 0, UInt, -1, UInt, &deviceMode )
			NumPut( 0x5c0000,    deviceMode,  40 )
			NumPut( colorDepth,  deviceMode, 104 )
			NumPut( width,       deviceMode, 108 )
			NumPut( height,      deviceMode, 112 )
			NumPut( refreshRate, deviceMode, 120 )
			DllCall( "ChangeDisplaySettingsA", UInt, &deviceMode, UInt, 0 )

			ResolutionChanger.changed := true

    }

    restore() {
    	;MsgBox, % A_ScreenWidth "x" A_ScreenHeight " -> " this.srcWidth "x" this.srcHeight
      if ( ResolutionChanger.changed == true && (A_ScreenWidth != this.srcWidth || A_ScreenHeight != this.srcHeight) ) {
        this.change( this.srcWidth, this.srcHeight )
        ResolutionChanger.changed := false
      }
    }


}

class Taskbar {
	static void := Taskbar._init()
  __New() {
      throw Exception( "TaskbarChanger is a static class, dont instante it!", -1 )
  }
  _init() {
  	this.allTray := false
  }

  /**
	* set working tray target to all or main (for Windows 10)
  * @param {boolean} yn 	true for all, false for main only.
  */
  setAllTray( yn) {
  	this.allTray := ( yn == true )
  }

  toggle() {
		IfWinNotExist ahk_class Shell_TrayWnd
		{
			this.show()
		} else {
			this.hide()
		}
  }

  show() {
		;Enable "Always on top" (& disable auto-hide)
		NumPut( (ABS_ALWAYSONTOP := 0x2), APPBARDATA, 32, "UInt" )
    DllCall( "Shell32.dll\SHAppBarMessage", "UInt", ( ABM_SETSTATE := 0xA ), "UInt", &APPBARDATA )
    WinShow ahk_class Shell_TrayWnd
    if ( this.allTray == true ) {
			WinHide ahk_class Shell_SecondaryTrayWnd
    }
		WinShow, Start ahk_class Button
  }

  hide() {
		IfWinExist ahk_class Shell_TrayWnd
		{
			;Disable "Always on top" (& enable auto-hide to hide Start button)
			NumPut( ( ABS_AUTOHIDE := 0x1 ), APPBARDATA, 32, "UInt" )
	    DllCall( "Shell32.dll\SHAppBarMessage", "UInt", ( ABM_SETSTATE := 0xA ), "UInt", &APPBARDATA )
	    WinHide ahk_class Shell_TrayWnd
	    if ( this.allTray == true ) {
	    	WinShow ahk_class Shell_SecondaryTrayWnd
	    }
			WinHide, Start ahk_class Button
		}
  }
}

/**
* MouseCursor Controller
*/
class MouseCursor {

  static void := FileUtil._init()

  _init() {
      this._setSystemCursor( "Init" )
  }

  _setSystemCursor( OnOff=1 ) {  ; INIT = "I","Init"; OFF = 0,"Off"; TOGGLE = -1,"T","Toggle"; ON = others
    static AndMask, XorMask, $, h_cursor
      ,c0,c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12,c13 ; system cursors
      ,b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13    ; blank cursors
      ,h1,h2,h3,h4,h5,h6,h7,h8,h9,h10,h11,h12,h13    ; handles of default cursors
    if (OnOff = "Init" or OnOff = "I" or $ = "")       ; init when requested or at first call
    {
      $ = h                                          ; active default cursors
      VarSetCapacity( h_cursor,4444, 1 )
      VarSetCapacity( AndMask, 32*4, 0xFF )
      VarSetCapacity( XorMask, 32*4, 0 )
      system_cursors = 32512,32513,32514,32515,32516,32642,32643,32644,32645,32646,32648,32649,32650
      StringSplit c, system_cursors, `,
      Loop %c0%
      {
          h_cursor   := DllCall( "LoadCursor", "Ptr",0, "Ptr",c%A_Index% )
          h%A_Index% := DllCall( "CopyImage", "Ptr",h_cursor, "UInt",2, "Int",0, "Int",0, "UInt",0 )
          b%A_Index% := DllCall( "CreateCursor", "Ptr",0, "Int",0, "Int",0
              , "Int",32, "Int",32, "Ptr",&AndMask, "Ptr",&XorMask )
      }
    }
    if (OnOff = 0 or OnOff = "Off" or $ = "h" and (OnOff < 0 or OnOff = "Toggle" or OnOff = "T"))
      $ = b  ; use blank cursors
    else
      $ = h  ; use the saved cursors

    Loop %c0%
    {
      h_cursor := DllCall( "CopyImage", "Ptr",%$%%A_Index%, "UInt",2, "Int",0, "Int",0, "UInt",0 )
      DllCall( "SetSystemCursor", "Ptr",h_cursor, "UInt",c%A_Index% )
    }
  }

  show() {
    MouseCursor._setSystemCursor( "On" )
  }

  hide() {
    MouseCursor._setSystemCursor( "Off" )
  }

}

class FileUtil {

	static void := FileUtil._init()

	_init() {
	}

	getDir( path ) {
		path := RegExReplace( path, "^(.*?)\\$", "$1" )
		if( this.isDir(path) )
			return path
		return this.getParentDir( path )
	}

	getParentDir( path ) {
		path := RegExReplace( path, "^(.*?)\\$", "$1" )
		path := RegExReplace( path, "^(.*)\\.+?$", "$1" )
		return path
	}

	getExt( filePath ) {
		SplitPath, % filePath, fileName, fileDir, fileExtention, fileNameWithoutExtension, DriveName
		StringLower, fileExtention, fileExtention
		return fileExtention
	}

  /**
  * File extention is matched width extentionPattern
  *
  * @param {string} filePath
  * @param {string} extentionPattern
  * @exmaple
  *   FileUtil.isExt("cue|mdx")
  */
	isExt( filePath, extentionPattern ) {

		IfNotExist %filePath%
			return false

		if ( RegExMatch( filePath, "i).*\.(" extentionPattern ")$" ) ) {
			return true
		} else {
			return false
		}

	}

	getFileName( filePath, withExt:=true ) {
		filePath := RegExReplace( filePath, "^(.*?)\\$", "$1" )
		SplitPath, filePath, fileName, fileDir, fileExtention, fileNameWithoutExtension, DriveName
		if( withExt == true )
			return fileName
		return fileNameWithoutExtension
	}

	getFiles( path, pattern=".*", includeDir=false, recursive=false ) {

		files := []

		if ( this.isFile(path) ) {
			if RegExMatch( path, pattern )
				files.Insert( path )

		} else {

		currDir := this.getDir( path )
			Loop, %currDir%\*, % includeDir, % recursive
			{
					if not RegExMatch( A_LoopFileFullPath, pattern )
						continue
					files.Insert( A_LoopFileFullPath )
			}

			this._sortArray( files )

		}

		return files

	}

	getFile( pathDirOrFile, pattern=".*" ) {

		if ( pathDirOrFile == "" or this.isFile(pathDirOrFile) )  {
			return pathDirOrFile
		}

        files := this.getFiles( pathDirOrFile, pattern )

        if ( files.MaxIndex() > 0 ) {
        	return files[ 1 ]
        }

        return ""

	}

	isDir( path ) {
		if( ! this.exist(path) )
			return false
		FileGetAttrib, attr, %path%
		Return InStr( attr, "D" )
	}

	isFile( path ) {
		if( ! this.exist(path) )
			return false
		FileGetAttrib, attr, %path%
		Return ! InStr( attr, "D" )
	}

	readProperties( path ) {

		prop := []

		Loop, Read, %path%
		{

			If RegExMatch(A_LoopReadLine, "^#.*" )
				continue

			splitPosition := InStr(A_LoopReadLine, "=" )

			If ( splitPosition = 0 ) {
				key := A_LoopReadLine
				val := ""
			} else {
				key := SubStr( A_LoopReadLine, 1, splitPosition - 1 )
				val := SubStr( A_LoopReadLine, splitPosition + 1 )
			}

			prop[ Trim(key) ] := Trim(val)

		}

		return prop

	}

	makeDir( path ) {
		FileCreateDir, %path%
	}

	makeParentDir( path, forDirectory=true ) {
		if ( forDirectory == true ) {
			parentDir := this.getParentDir( path )
		} else {
			parentDir := this.getDir( path )
		}
		FileCreateDir, % parentDir
	}

	exist( path ) {
		return FileExist( path )
	}

	delete( path, recursive=1 ) {
		if ( this.isFile(path) ) {
			FileDelete, % path
		} else if( this.isDir(path) ) {
			FileRemoveDir, % path, % recursive
		}
	}

	move( src, trg, overwrite=1 ) {
		if ( ! this.exist(src) )
			return
		this.makeParentDir( trg, this.isDir(src) )
		FileMove, % src, % trg, % overwrite
	}

	copy( src, trg, overwrite=1 ) {
		if ( ! this.exist(src) )
			return
		this.makeParentDir( trg, this.isDir(src) )
		if ( this.isDir(src) ) {
			FileCopyDir, % src, % trg, % overwrite
		} else {
			FileCopy, % src, % trg, % overwrite
		}
	}

  /**
  * get file size
  *
  * @param {path} filePath
  * @return size (byte)
  */
	getSize( path ) {
		FileGetSize, size, % path
		return size
	}

  /**
  * get time
  *
  * @param {path} file path
  * @param {witchTime} M: modification time (default), C: creation time, A: last access time
  * @return YYYYMMDDHH24MISS
  */
	getTime( path, whichTime="M" ) {
		FileGetTime, var, % path, % whichTime
		return var
	}

    /**
    * Get Symbolic Link Information
    *
    * @param  filePath   path to check if it is symbolic link
    * @param  srcPath    path to linked by filePath
    * @param  linkType   link type ( file or directory )
    * @return true if filepath is symbolic link
    */
	isSymlink( filePath, ByRef srcPath="", ByRef linkType="" ) {

		IfNotExist, % filePath
			return false

		if RegExMatch(filePath,"^\w:\\?$") ; false if it is a root directory
			return false

		SplitPath, filePath, fn, parentDir

		result := this.cli( "/c dir /al """ (InStr(FileExist(filePath),"D") ? parentDir "\" : filePath) """" )

		if RegExMatch(result,"<(.+?)>.*?\b" fn "\b.*?\[(.+?)\]",m) {
			linkType:= m1, srcPath := m2
			if ( linkType == "SYMLINK" )
  			linkType := "file"
			else if ( linkType == "SYMLINKD" )
  			linkType := "directory"
			return true
		} else {
			return false
		}

	}

  /**
  * make symbolic link
  *
  * @param src  source path (real file)
  * @param trg  target path (path to used as link)
  */
  makeLink( src, trg ) {

  	if this.isSymlink( trg ) {
  		this.delete( trg )
  	}

		this.makeParentDir( trg, this.isDir(src) )
		if ( this.isDir(src) ) {
			cmd := "/c mklink /d /j """ trg """ """ src """"
		} else {
			cmd := "/c mklink """ trg """ """ src """"
		}
		debug( cmd )
		this.cli( cmd )

  }

  /**
  * run command and return result
  *
  * @param  command	 command
  * @return command execution result
  */
	cli( command ) {

		dhw := A_DetectHiddenWindows
		DetectHiddenWindows,On
		Run, %ComSpec% /k,,Hide UseErrorLevel, pid
		if not ErrorLevel
		{
			while ! WinExist("ahk_pid" pid)
				Sleep,100
			DllCall( "AttachConsole","UInt",pid )
		}
		DetectHiddenWindows, % dhw

		; debug( "command :`n`t" command )
		shell := ComObjCreate("WScript.Shell")
		try {
			exec := shell.Exec( comspec " " command )
			While ! exec.Status
				sleep, 100
			result := exec.StdOut.readAll()
		}
		catch e
		{
			debug( "error`n" e.what "`n" e.message )
		}
		; debug( "result :`n`t" result )
		DllCall("FreeConsole")
		Process Close, %pid%

		return result

	}

	_sortArray( Array ) {
	  t := Object()
	  for k, v in Array
	    t[RegExReplace(v,"\s")]:=v
	  for k, v in t
	    Array[A_Index] := v
	  return Array
	}

}