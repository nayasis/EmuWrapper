#NoEnv

; MouseCursor.show()
; ExitApp

SplitPath, A_ScriptName, , , , NoextScriptFileName

fileIni := A_ScriptDir "\" NoextScriptFileName ".ini"
fileReg := A_ScriptDir "\" NoextScriptFileName ".reg"

runAsAdmin( fileIni )

prop := readProperties( fileIni )

; set default
prop[ "cd" ]      := A_ScriptDir
prop[ "cdWin" ]   := RegExReplace( A_ScriptDir, "\\", "\\" ) ; double file seperator slash
; single file seperator slash
prop[ "cdUnix" ]  := RegExReplace( A_ScriptDir, "\\", "/" ) ; normal file seperator

setRegistry( fileReg, prop )

runSub( "pre", fileIni, prop )
runProgram( fileIni, prop )
runSub( "post", fileIni, prop )

ExitApp

runAsAdmin( fileIni ) {
	IniRead, value, % fileIni, init, runAsAdmin, false
	if ( value == true ) {
		restartAsAdmin()
	}
}

; check whether ini file has executor to Run
; @param section    pre,mid,post
; @param fileIni    ini file path
hasSub( section, fileIni ) {
  indices = ,0,1,2,3,4,5,6,7,8,9
  loop, parse, indices, `,
  {
		IniRead, executor,    %fileIni%, %section%, executor%a_loopfield%,    _
		IniRead, executorDir, %fileIni%, %section%, executor%a_loopfield%Dir, _
		executor    := RegExReplace( executor,    "\\", "\\" )
		debug( executor )
		if( executor != "_" )
			return true
  }	
  return false
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

		executor      := RegExReplace( executor,      "\\",     "\\"    )
		executorDir   := RegExReplace( executorDir,   "\\",     "\\"    )
		executorDelay := RegExReplace( executorDelay, "[^0-9]", ""      )
		executorWait  := RegExReplace( executorWait,  "_",      "true"  )

		; debug( section "-executor : " executor )

		_runSub( executor, executorDir, executorDelay, executorWait, properties )    
  }
}

_runSub( executor, executorDir, executorDelay, executorWait, properties ) {

	if ( executor == "_" )
		return

	if ( executorDelay != "" )
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
			RunWait, %executor%, %executorDir%
		} else {
			Run, %executor%, %executorDir%
		}

	}

}

runProgram( fileIni, properties ) {

	IniRead, executor,                 %fileIni%, init,   executor,     _
	IniRead, executorDir,              %fileIni%, init,   executorDir,  _
	IniRead, resolution,               %fileIni%, init,   resolution,   _
	IniRead, hideTaskbar,              %fileIni%, init,   hideTaskbar,  _
	IniRead, hideMouse,                %fileIni%, init,   hideMouse,    _
	IniRead, isRunWait,                %fileIni%, init,   runWait,      "true"

	IniRead, windowTarget,             %fileIni%, window, target,       _
	IniRead, windowSearchDelay,        %fileIni%, window, searchDelay,  0
	IniRead, windowStart,              %fileIni%, window, start,        _
	IniRead, windowSize,               %fileIni%, window, size,         _
	IniRead, windowBorderless,         %fileIni%, window, borderless,   "true"

	; executor    := RegExReplace( executor,    "\\", "\\" )
	; executorDir := RegExReplace( executorDir, "\\", "\\" )

	if ( resolution != "_" ) {
		changeResolution( resolution )
		isRunWait := "true"
		if ( windowSize == "_" ) {
		    windowSize := resolution
		}
	}

	if ( windowStart == "_" ) {
	  windowStart := "0,0"
	}

	if ( windowSize == "_" ) {
		windowSize := A_ScreenWidth x A_ScreenHeight
	}

	if ( hideTaskbar != "_" && hideTaskbar == "true" ) {
		isRunWait := "true"
		Taskbar.hide()
	}

	if ( hideMouse != "_" && hideMouse == "true" ) {
		isRunWait := "true"
		MouseCursor.hide()
	}

	if ( hasSub("mid", fileIni) == true ) {
		isRunWait := "true"
	}

	if ( ResolutionChanger.changed == true ) {
	  isRunWait := "true"	
	}

	;MsgBox windowSize : %windowSize%

	if ( executor != "_" ) {
		
		executor    := bindValue( executor, properties )
		; executorDir 변수에 executor의 경로만 담는다.
		if ( executorDir == "_" ) {
			SplitPath, executor, , executorDir
		}
		executorDir := bindValue( executorDir, properties )

		if ( windowTarget != "_" ) {
			SetTimer, runMidThread, 500
			Run, %executor%, %executorDir%,,applicationPid
			debug( "windowSearchDelay : " windowSearchDelay )
			Sleep, %windowSearchDelay%
			WinWait, %windowTarget%,, 20

			If ErrorLevel {
				MsgBox % "There is no window to wait.(" windowTarget ")"
				Process, Close, %applicationPid%
			} else {
			  startX := Trim( RegExReplace( windowStart, "i)^\D*?(\d*?)\D*?,\D*?(\d*?)\D*?$", "$1" ) )
			  startY := Trim( RegExReplace( windowStart, "i)^\D*?(\d*?)\D*?,\D*?(\d*?)\D*?$", "$2" ) )
		    width  := Trim( RegExReplace( windowSize, "i)^\D*?(\d*?)\D*?x\D*?(\d*?)\D*?$", "$1" ) )
		    height := Trim( RegExReplace( windowSize, "i)^\D*?(\d*?)\D*?x\D*?(\d*?)\D*?$", "$2" ) )
		    debug( "target : " windowTarget ", borderless : " windowBorderless ", start : (" startX "," startY "), resolution : " width " x " height )

		    if ( windowBorderless == "true" ) {
		    	debug( "set borderless" )
					WinSet, Style, -0xC40000, %windowTarget% ; remove the titlebar and border(s)
		    }

				WinMove, %windowTarget%,, %startX%, %startY%, %width%, %height%  ; move the window to 0,0 and reize to width x height 
				MouseMove, %width% + startY, %height% + startX

				WinWaitClose, %windowTarget%

			}

      ResolutionChanger.restore()
			Taskbar.show()
			MouseCursor.show()

		} else if ( isRunWait == "true" ) {
			SetTimer, runMidThread, 500
			RunWait, %executor%, %executorDir%
			ResolutionChanger.restore()
			Taskbar.show()
		} else {
			SetTimer, runMidThread, 500
			debug( "executor    : " executor    )
			debug( "executorDir : " executorDir )
			Run, %executor%, %executorDir%
		}

	}


}

isFile( path ) {
	IfNotExist %path%, return false
	FileGetAttrib, attr, %path%
	Return ! InStr( attr, "D" )
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

    key := RegExReplace( A_LoopReadLine, "^(.*?)=.*?$", "$1" )
    val := RegExReplace( A_LoopReadLine, "^.*?=(.*?)$", "$1" )

		prop[ Trim(key) ] := Trim(val)
	}

	return prop

}

/**
* Set Registry from file 
*
* @param file       {String} filePath contains data formatted Windows Registry
* @param properties {Array}  properties to bind
*/
setRegistry( file, properties ) {

	SetRegView 32
	_setRegistry( file, properties )

	SetRegView 64
	_setRegistry( file, properties )

}

/**
* Write Registry from file 
*
* @param file       {String} filePath contains data formatted Windows Registry
* @param properties {Array}  properties to bind
*/
_setRegistry( file, properties ) {

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

			debug( regName ":" regVal )

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

		debug( "[" regKey "] " regName " - " regType ":" regVal )

		; if it needs to run as admin, restart itself
		if ( ! RegExMatch(regKey, "^(HKEY_CURRENT_USER|HKEY_USERS)\\.*$") ) {
			restartAsAdmin()
		}


		RegWrite, % regType, % regKey, % regName, % regVal

	}

}

bindValue( value, properties ) {

	For key, val in properties
		value := StrReplace( value, "#{" key "}", val )

	return value

}

toStringFromHex( hexValue ) {

  if ! hexValue
    return 0

  array := StrSplit( hexValue, "," )

  if ( mod( array.MaxIndex(), 2 ) != 0 ) {
  	array.Insert( "00" )
  }

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

  if ( mod( array.MaxIndex(), 2 ) != 0 ) {
  	array.Insert( "00" )
  }

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

class ResolutionChanger {

    static void := ResolutionChanger._init()

    static changed := false

    _init() {
        this.srcWidth  := A_ScreenWidth
        this.srcHeight := A_ScreenHeight
    }
  
    __New() {
        throw Exception( "ResolutionChanger is a static class, dont instante it!", -1 )
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
    }

    toggle() {
			IfWinExist ahk_class Shell_TrayWnd
			{
				NumPut( ( ABS_AUTOHIDE := 0x1 ), APPBARDATA, 32, "UInt" )            ;Disable "Always on top" (& enable auto-hide to hide Start button)
		    DllCall( "Shell32.dll\SHAppBarMessage", "UInt", ( ABM_SETSTATE := 0xA ), "UInt", &APPBARDATA )

		    WinHide ahk_class Shell_TrayWnd
		    WinHide ahk_class Shell_SecondaryTrayWnd
				WinHide, Start ahk_class Button

			} Else {
				NumPut( (ABS_ALWAYSONTOP := 0x2), APPBARDATA, 32, "UInt" )           ;Enable "Always on top" (& disable auto-hide)
		    DllCall( "Shell32.dll\SHAppBarMessage", "UInt", ( ABM_SETSTATE := 0xA ), "UInt", &APPBARDATA )

		    WinShow ahk_class Shell_TrayWnd
		    WinShow ahk_class Shell_SecondaryTrayWnd
				WinShow, Start ahk_class Button
			}
    }

    show() {
			IfWinNotExist ahk_class Shell_TrayWnd
			{
				;Enable "Always on top" (& disable auto-hide)
				NumPut( (ABS_ALWAYSONTOP := 0x2), APPBARDATA, 32, "UInt" )
		    DllCall( "Shell32.dll\SHAppBarMessage", "UInt", ( ABM_SETSTATE := 0xA ), "UInt", &APPBARDATA )
		    WinShow ahk_class Shell_TrayWnd
		    WinShow ahk_class Shell_SecondaryTrayWnd
				WinShow, Start ahk_class Button
			}
    }

    hide() {
			IfWinExist ahk_class Shell_TrayWnd
			{
				;Disable "Always on top" (& enable auto-hide to hide Start button)
				NumPut( ( ABS_AUTOHIDE := 0x1 ), APPBARDATA, 32, "UInt" )
		    DllCall( "Shell32.dll\SHAppBarMessage", "UInt", ( ABM_SETSTATE := 0xA ), "UInt", &APPBARDATA )
		    WinHide ahk_class Shell_TrayWnd
		    WinHide ahk_class Shell_SecondaryTrayWnd
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
        SetTimer, MouseCursor.no_move_check, off
        MouseCursor._setSystemCursor( "On" )
    }

    hide( duration=500 ) {

        SetTimer, MouseCursor.no_move_check, %duration%
        MouseCursor._setSystemCursor( "Off" )
        return

        MouseCursor.no_move_check:

            MouseGetPos, prevX, prevY
            
            Sleep 100

            MouseGetPos, x, y

            if ( prevX != x or prevY != y ) {
                MouseCursor._setSystemCursor( "On" )
            } else {
                MouseCursor._setSystemCursor( "Off" )
            }

            return

    }

}

debug( message ) {

 if( A_IsCompiled == 1 )
   return

  message .= "`n" 
  FileAppend %message%, * ; send message to stdout
    
}


