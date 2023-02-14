#NoEnv

/**
 * Command line Interface with in / out pipe
 */
class Cli {

 	hStdInputWritePipe  := 0
 	hStdOutputReadPipe  := 0
 	processId           := 0

 	__New( commandLine, showConsole=true ) {

 		DllCall( "CreatePipe", "Ptr*", hStdInputReadPipe,  "Ptr*", hStdInputWritePipe,  "UInt", 0, "UInt", 0 )
 		DllCall( "CreatePipe", "Ptr*", hStdOutputReadPipe, "Ptr*", hStdOutputWritePipe, "UInt", 0, "UInt", 0 )

 		DllCall( "SetHandleInformation", "Ptr", hStdInputReadPipe,   "UInt", 1, "UInt", 1 )
 		DllCall( "SetHandleInformation", "Ptr", hStdOutputWritePipe, "UInt", 1, "UInt", 1 )

		if ( a_ptrSize == 4 ) {

	 		VarSetCapacity( processInfo, 16, 0 )
	 		startupInfoSize := VarSetCapacity( startupInfo, 68, 0 )

	 		NumPut( startupInfoSize,     startupInfo,  0, "UInt" )
	 		NumPut( 0x00000100,          startupInfo, 44, "UInt" )
	 		NumPut( hStdInputReadPipe,   startupInfo, 56, "Ptr"  )
	 		NumPut( hStdOutputWritePipe, startupInfo, 60, "Ptr"  )
	 		NumPut( hStdOutputWritePipe, startupInfo, 64, "Ptr"  )

		} else {

	 		VarSetCapacity( processInfo, 24, 0 )
	 		startupInfoSize := VarSetCapacity( startupInfo, 96, 0 )

	 		NumPut( startupInfoSize,     startupInfo,  0, "UInt" )
	 		NumPut( 0x00000100,          startupInfo, 60, "UInt" )
	 		NumPut( hStdInputReadPipe,   startupInfo, 80, "Ptr"  )
	 		NumPut( hStdOutputWritePipe, startupInfo, 88, "Ptr"  )
	 		NumPut( hStdOutputWritePipe, startupInfo, 96, "Ptr"  )

		}

 		DllCall( "CreateProcessW"
 			, "UInt", 0
 			, "Ptr",  &commandLine
 			, "UInt", 0
 			, "UInt", 0
 			, "Int",  1
 			, "UInt", showConsole == true ? 0 : 0x08000000 ; Create_NO_WINDOW
 			, "UInt", 0
 			, "Ptr",  &A_ScriptDir
 			, "Ptr",  &startupInfo
 			, "Ptr",  &processInfo )

 		this.processId := NumGet( processInfo, a_ptrSize * 2, "UInt" )

 		; MsgBox, % "processId : " this.processId "`nhStdOutputWritePipe : " hStdOutputWritePipe "`nhStdInputReadPipe : " hStdInputReadPipe

 		Process, Wait, % this.processId

 		DllCall( "CloseHandle", "Ptr", NumGet(processInfo, 0)         )
 		DllCall( "CloseHandle", "Ptr", NumGet(processInfo, a_ptrSize) )
 		DllCall( "CloseHandle", "Ptr", hStdOutputWritePipe            )
 		DllCall( "CloseHandle", "Ptr", hStdInputReadPipe              )

 		this.hStdInputWritePipe  := hStdInputWritePipe
 		this.hStdOutputReadPipe  := hStdOutputReadPipe

 	}

  __Delete() {
    this.close()
  }

 	waitForClose() {

 		Loop {
 			Process, Exist, % this.processId
 			if (ErrorLevel == 0) {
 				break
 			}
 			Sleep, 100
 		}

 	}

 	close() {

 		hStdInputWritePipe  := this.hStdInputWritePipe
 		hStdOutputReadPipe  := this.hStdOutputReadPipe

 		DllCall( "CloseHandle", "Ptr", hStdInputWritePipe  )
 		DllCall( "CloseHandle", "Ptr", hStdOutputReadPipe  )

 		Process, Close, % this.processId

 	}

 	readPipe( codepage="" ) {

    hStdOutputReadPipe:=this.hStdOutputReadPipe
    
    if ( codepage == "" )
      codepage := A_FileEncoding
    
    file   := FileOpen( hStdOutputReadPipe, "h", codepage )
    result := ""

    if ( IsObject(file) && file.AtEOF == 0 ) {
    	result := file.Read()
    }

    file.Close()

    return result

 	}

 	writePipe( command, codepage="" ) {

		hStdInputWritePipe  := this.hStdInputWritePipe

		if ( command == "" )
			return

		file := FileOpen( hStdInputWritePipe, "h", codepage )
		file.Write( command )
		file.Read(0) ; flush buffer
		file.Close()

 	}

 	getProcessId() {
 		return this.processId
 	}

}

cmdlet( command, Callback := "", WorkingDir:=0, ByRef ProcessID:=0 ) {
  Static StrGet := "StrGet"
  tcWrk := WorkingDir=0 ? "Int" : "Str"
  DllCall( "CreatePipe", UIntP,hPipeRead, UIntP,hPipeWrite, UInt,0, UInt,0 )
  DllCall( "SetHandleInformation", UInt,hPipeWrite, UInt,1, UInt,1 )
  If A_PtrSize = 8
  {
    VarSetCapacity( STARTUPINFO, 104, 0  )     ; STARTUPINFO
    NumPut( 68,         STARTUPINFO,  0 )      ; cbSize
    NumPut( 0x100,      STARTUPINFO, 60 )      ; dwFlags    =>  STARTF_USESTDHANDLES = 0x100
    NumPut( hPipeWrite, STARTUPINFO, 88 )      ; hStdOutput
    NumPut( hPipeWrite, STARTUPINFO, 96 )      ; hStdError
    VarSetCapacity( PROCESS_INFORMATION, 24 )  ; PROCESS_INFORMATION
  }
  Else
  {
    VarSetCapacity( STARTUPINFO, 68, 0  )
    NumPut( 68,         STARTUPINFO,  0 )
    NumPut( 0x100,      STARTUPINFO, 44 )
    NumPut( hPipeWrite, STARTUPINFO, 60 )
    NumPut( hPipeWrite, STARTUPINFO, 64 )
    VarSetCapacity( PROCESS_INFORMATION, 16 )
  }

  ;Tip for struct calculation
  ; Any member should be aligned to multiples of its size
  ; Full size of structure should be multiples of the largest member size
  ;============================================================================
  ;
  ; x64
  ; STARTUPINFO
  ;                             offset    size                    comment
  ;DWORD  cb;                   0         4
  ;LPTSTR lpReserved;           8         8(A_PtrSize)            aligned to 8-byte boundary (4 + 4)
  ;LPTSTR lpDesktop;            16        8(A_PtrSize)
  ;LPTSTR lpTitle;              24        8(A_PtrSize)
  ;DWORD  dwX;                  32        4
  ;DWORD  dwY;                  36        4
  ;DWORD  dwXSize;              40        4
  ;DWORD  dwYSize;              44        4
  ;DWORD  dwXCountChars;        48        4
  ;DWORD  dwYCountChars;        52        4
  ;DWORD  dwFillAttribute;      56        4
  ;DWORD  dwFlags;              60        4
  ;WORD   wShowWindow;          64        2
  ;WORD   cbReserved2;          66        2
  ;LPBYTE lpReserved2;          72        8(A_PtrSize)           aligned to 8-byte boundary (2 + 4)
  ;HANDLE hStdInput;            80        8(A_PtrSize) 
  ;HANDLE hStdOutput;           88        8(A_PtrSize) 
  ;HANDLE hStdError;            96        8(A_PtrSize) 
  ;
  ;ALL : 96+8=104=8*13
  ;
  ; PROCESS_INFORMATION
  ;
  ;HANDLE hProcess              0         8(A_PtrSize)
  ;HANDLE hThread               8         8(A_PtrSize)
  ;DWORD  dwProcessId           16        4
  ;DWORD  dwThreadId            20        4
  ;
  ;ALL : 20+4=24=8*3
  ;============================================================================
  ; x86
  ; STARTUPINFO
  ;                             offset     size
  ;DWORD  cb;                   0          4
  ;LPTSTR lpReserved;           4          4(A_PtrSize)            
  ;LPTSTR lpDesktop;            8          4(A_PtrSize)
  ;LPTSTR lpTitle;              12         4(A_PtrSize)
  ;DWORD  dwX;                  16         4
  ;DWORD  dwY;                  20         4
  ;DWORD  dwXSize;              24         4
  ;DWORD  dwYSize;              28         4
  ;DWORD  dwXCountChars;        32         4
  ;DWORD  dwYCountChars;        36         4
  ;DWORD  dwFillAttribute;      40         4
  ;DWORD  dwFlags;              44         4
  ;WORD   wShowWindow;          48         2
  ;WORD   cbReserved2;          50         2
  ;LPBYTE lpReserved2;          52         4(A_PtrSize)           
  ;HANDLE hStdInput;            56         4(A_PtrSize) 
  ;HANDLE hStdOutput;           60         4(A_PtrSize) 
  ;HANDLE hStdError;            64         4(A_PtrSize) 
  ;
  ;ALL : 64+4=68=4*17
  ;
  ; PROCESS_INFORMATION
  ;
  ;HANDLE hProcess              0         4(A_PtrSize)
  ;HANDLE hThread               4         4(A_PtrSize)
  ;DWORD  dwProcessId           8         4
  ;DWORD  dwThreadId            12        4
  ;
  ;ALL : 12+4=16=4*4
  
  If ! DllCall( "CreateProcess", UInt,0, UInt,&command, UInt,0, UInt,0
              , UInt,1, UInt,0x08000000, UInt,0, tcWrk, WorkingDir
              , UInt,&STARTUPINFO, UInt,&PROCESS_INFORMATION ) 
  {
    DllCall( "CloseHandle", UInt,hPipeWrite ) 
    DllCall( "CloseHandle", UInt,hPipeRead )
    DllCall( "SetLastError", Int,-1 )     
    Return "" 
  }
   
  hProcess := NumGet( PROCESS_INFORMATION, 0 )                 
  hThread  := NumGet( PROCESS_INFORMATION, A_PtrSize )  
  ProcessID:= NumGet( PROCESS_INFORMATION, A_PtrSize*2 )  

  DllCall( "CloseHandle", UInt,hPipeWrite )

  AIC := ( SubStr( A_AhkVersion, 1, 3 ) = "1.0" )
  VarSetCapacity( Buffer, 4096, 0 ), nSz := 0 
  
  While DllCall( "ReadFile", UInt,hPipeRead, UInt,&Buffer, UInt,4094, UIntP,nSz, Int,0 ) {
    tOutput := ( AIC && NumPut( 0, Buffer, nSz, "Char" ) && VarSetCapacity( Buffer,-1 ) ) 
              ? Buffer : %StrGet%( &Buffer, nSz, "UTF-8" ) ; formerly CP850, but I guess CP0 is suitable for different locales
              ; ? Buffer : %StrGet%( &Buffer, nSz, "CP936" ) ; formerly CP850, but I guess CP0 is suitable for different locales
              ; ? Buffer : %StrGet%( &Buffer, nSz, "CP0" ) ; formerly CP850, but I guess CP0 is suitable for different locales
    Isfunc( Callback ) ? %Callback%( tOutput, A_Index ) : sOutput .= tOutput
  }                   
 
  DllCall( "GetExitCodeProcess", UInt,hProcess, UIntP,ExitCode )
  DllCall( "CloseHandle",  UInt,hProcess  )
  DllCall( "CloseHandle",  UInt,hThread   )
  DllCall( "CloseHandle",  UInt,hPipeRead )
  DllCall( "SetLastError", UInt,ExitCode  )
  VarSetCapacity(STARTUPINFO, 0)
  VarSetCapacity(PROCESS_INFORMATION, 0)

  Return Isfunc( Callback ) ? %Callback%( "", 0 ) : sOutput      

}

EucEncode( p_data, p_reserved=true, p_encode=true ) {

   old_FormatInteger := A_FormatInteger
   SetFormat, Integer, hex
   unsafe =
      ( Join LTrim
         25000102030405060708090A0B0C0D0E0F101112131415161718191A1B1C1D1E1F20
         22233C3E5B5C5D5E607B7C7D7F808182838485868788898A8B8C8D8E8F9091929394
         95969798999A9B9C9D9E9FA0A1A2A3A4A5A6A7A8A9AAABACADAEAFB0B1B2B3B4B5B6
         B7B8B9BABBBCBDBEBFC0C1C2C3C4C5C6C7C8C9CACBCCCDCECFD0D1D2D3D4D5D6D7D8
         D9DADBDCDDDEDF7EE0E1E2E3E4E5E6E7E8E9EAEBECEDEEEFF0F1F2F3F4F5F6F7F8F9
         FAFBFCFDFEFF
      )

   if ( p_reserved )
      unsafe = %unsafe%24262B2C2F3A3B3D3F40

   if ( p_encode )
      loop, % StrLen( unsafe )//2
      {
         StringMid, token, unsafe, A_Index*2-1, 2
         StringReplace, p_data, p_data, % Chr( "0x" token ), `%%token%, all
      }
   else
      loop, % StrLen( unsafe )//2
      {
         StringMid, token, unsafe, A_Index*2-1, 2
         StringReplace, p_data, p_data, `%%token%, % Chr( "0x" token ), all
      }

   SetFormat, Integer, %old_FormatInteger%
   return, p_data

}

EucDecode( p_data ) {
   return, EucEncode( p_data, true, false )
}