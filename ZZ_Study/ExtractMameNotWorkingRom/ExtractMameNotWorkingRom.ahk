#NoEnv

IfWinNotExist, ahk_class MainClass ahk_exe mameui64.exe
{
	Run "mameui64.exe",,,emulatorPid
}

WinWait, ahk_class MainClass ahk_exe mameui64.exe, 1
IfWinExist
{

	debug( ">> Start" )

	;WinActivate, ahk_class MainClass ahk_exe mameui64.exe
	WinGet, List, ControlList, ahk_class MainClass ahk_exe mameui64.exe
	Loop, Parse, List, `n
	{
		ControlGetText, Text, %A_LoopField%, ahk_class MainClass ahk_exe mameui64.exe
		if( A_LoopField == "SysListView321" ) {
			;debug( "ClassNN:" Text "," A_LoopField )
		}

		;If (Text = SearchText)
		;debug( "ClassNN:" Text "," A_LoopField )
	}

	ControlGet, List, List,, SysListView321, ahk_class MainClass ahk_exe mameui64.exe
	Loop, Parse, List, `n  ; Rows are delimited by linefeeds (`n).
	{
	    rowIndex := A_Index
	    Loop, Parse, A_LoopField, %A_Tab% ; Fields (columns) in each row are delimited by tabs (A_Tab).
	    {
	    	colIndex := A_Index

	    	if( colIndex != 2 )
	    		continue

	    	debug( A_LoopField )
				
				;debug( "Row #" rowIndex "Col #" A_Index " is " A_LoopField "." )
	    }  
	        
	}

	Process, Close, %emulatorPid%

}

ExitApp


debug( message ) {

 if( A_IsCompiled == 1 )
   return

  message .= "`n" 
  FileAppend %message%, * ; send message to stdout
    
}