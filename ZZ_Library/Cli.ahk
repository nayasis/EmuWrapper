/**
 * Command line Interface with in / out pipe
 */
class Cli {

 	hStdInputWritePipe  := 0
 	hStdOutputReadPipe  := 0
 	processId           := 0

 	__New( commandLine, showConsole:=true ) {

		hStdInputReadPipe := 0
		hStdInputWritePipe := 0
		hStdOutputReadPipe := 0
		hStdOutputWritePipe := 0

 		DllCall( "CreatePipe", "Ptr*", hStdInputReadPipe,  "Ptr*", hStdInputWritePipe,  "UInt", 0, "UInt", 0 )
 		DllCall( "CreatePipe", "Ptr*", hStdOutputReadPipe, "Ptr*", hStdOutputWritePipe, "UInt", 0, "UInt", 0 )

 		DllCall( "SetHandleInformation", "Ptr", hStdInputReadPipe,   "UInt", 1, "UInt", 1 )
 		DllCall( "SetHandleInformation", "Ptr", hStdOutputWritePipe, "UInt", 1, "UInt", 1 )

		if ( A_PtrSize == 4 ) {
	 		startupInfoSize := 68
	 		startupInfo := BufferAlloc(startupInfoSize, 0)
	 		processInfo := BufferAlloc(16, 0)

	 		NumPut("UInt", startupInfoSize, startupInfo, 0)
	 		NumPut("UInt", 0x00000100, startupInfo, 44)
	 		NumPut("Ptr", hStdInputReadPipe, startupInfo, 56)
	 		NumPut("Ptr", hStdOutputWritePipe, startupInfo, 60)
	 		NumPut("Ptr", hStdOutputWritePipe, startupInfo, 64)
		} else {
	 		startupInfoSize := 96
	 		startupInfo := BufferAlloc(startupInfoSize, 0)
	 		processInfo := BufferAlloc(24, 0)

	 		NumPut("UInt", startupInfoSize, startupInfo, 0)
	 		NumPut("UInt", 0x00000100, startupInfo, 60)
	 		NumPut("Ptr", hStdInputReadPipe, startupInfo, 80)
	 		NumPut("Ptr", hStdOutputWritePipe, startupInfo, 88)
	 		NumPut("Ptr", hStdOutputWritePipe, startupInfo, 96)
		}

 	DllCall( "CreateProcessW"
 			, "Ptr",  0
 			, "Ptr",  StrPtr(commandLine)
 			, "Ptr",  0
 			, "Ptr",  0
 			, "Int",  1
 			, "UInt", showConsole == true ? 0 : 0x08000000 ; Create_NO_WINDOW
 			, "Ptr",  0
 			, "Ptr",  A_ScriptDir
 			, "Ptr",  &startupInfo
 			, "Ptr",  &processInfo )

 		this.processId := NumGet( processInfo, A_PtrSize * 2, "UInt" )

 		; MsgBox, % "processId : " this.processId "`nhStdOutputWritePipe : " hStdOutputWritePipe "`nhStdInputReadPipe : " hStdInputReadPipe

 		ProcessWait(this.processId)

 		DllCall( "CloseHandle", "Ptr", NumGet(processInfo, 0, "Ptr")         )
 		DllCall( "CloseHandle", "Ptr", NumGet(processInfo, A_PtrSize, "Ptr") )
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
			if !ProcessExist(this.processId)
				break
			Sleep(100)
		}

 	}

 	close() {

 		hStdInputWritePipe  := this.hStdInputWritePipe
 		hStdOutputReadPipe  := this.hStdOutputReadPipe

 		DllCall( "CloseHandle", "Ptr", hStdInputWritePipe  )
 		DllCall( "CloseHandle", "Ptr", hStdOutputReadPipe  )

 		ProcessClose(this.processId)

 	}

 	readPipe( codepage:="" ) {

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

 	writePipe( command, codepage:="" ) {

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

cmdlet( command, Callback := "", WorkingDir:=0, &ProcessID := 0 ) {
  tcWrk := WorkingDir=0 ? "Int" : "Str"
  DllCall( "CreatePipe", "Ptr*", hPipeRead, "Ptr*", hPipeWrite, "Ptr", 0, "UInt", 0 )
  DllCall( "SetHandleInformation", "Ptr", hPipeWrite, "UInt", 1, "UInt", 1 )
  If A_PtrSize = 8
  {
    STARTUPINFO := BufferAlloc(104, 0)     ; STARTUPINFO
    NumPut("UInt", 68, STARTUPINFO, 0)      ; cbSize
    NumPut("UInt", 0x100, STARTUPINFO, 60)  ; dwFlags    =>  STARTF_USESTDHANDLES = 0x100
    NumPut("Ptr", hPipeWrite, STARTUPINFO, 88)      ; hStdOutput
    NumPut("Ptr", hPipeWrite, STARTUPINFO, 96)      ; hStdError
    PROCESS_INFORMATION := BufferAlloc(24, 0)  ; PROCESS_INFORMATION
  }
  Else
  {
    STARTUPINFO := BufferAlloc(68, 0)
    NumPut("UInt", 68, STARTUPINFO, 0)
    NumPut("UInt", 0x100, STARTUPINFO, 44)
    NumPut("Ptr", hPipeWrite, STARTUPINFO, 60)
    NumPut("Ptr", hPipeWrite, STARTUPINFO, 64)
    PROCESS_INFORMATION := BufferAlloc(16, 0)
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
  
  If ! DllCall( "CreateProcessW", "Ptr", 0, "Ptr", StrPtr(command), "Ptr", 0, "Ptr", 0
              , "Int", 1, "UInt", 0x08000000, "Ptr", 0, tcWrk, WorkingDir
              , "Ptr", &STARTUPINFO, "Ptr", &PROCESS_INFORMATION )
  {
    DllCall( "CloseHandle", "Ptr", hPipeWrite )
    DllCall( "CloseHandle", "Ptr", hPipeRead )
    DllCall( "SetLastError", "Int", -1 )
    Return "" 
  }
   
  hProcess := NumGet( PROCESS_INFORMATION, 0, "Ptr" )
  hThread  := NumGet( PROCESS_INFORMATION, A_PtrSize, "Ptr" )
  ProcessID:= NumGet( PROCESS_INFORMATION, A_PtrSize*2, "UInt" )

  DllCall( "CloseHandle", "Ptr", hPipeWrite )

  Buffer := BufferAlloc(4096)
  nSz := 0
  
  While DllCall( "ReadFile", "Ptr", hPipeRead, "Ptr", Buffer, "UInt", 4094, "UIntP", nSz, "Ptr", 0 ) {
    tOutput := StrGet(Buffer, nSz, "UTF-8") ; formerly CP850, but I guess CP0 is suitable for different locales
              ; ? Buffer : %StrGet%( &Buffer, nSz, "CP936" ) ; formerly CP850, but I guess CP0 is suitable for different locales
              ; ? Buffer : %StrGet%( &Buffer, nSz, "CP0" ) ; formerly CP850, but I guess CP0 is suitable for different locales
    IsFunc(Callback) ? Callback.Call(tOutput, A_Index) : sOutput .= tOutput
  }                   
 
  DllCall( "GetExitCodeProcess", "Ptr", hProcess, "UIntP", ExitCode )
  DllCall( "CloseHandle",  "Ptr", hProcess  )
  DllCall( "CloseHandle",  "Ptr", hThread   )
  DllCall( "CloseHandle",  "Ptr", hPipeRead )
  DllCall( "SetLastError", "UInt", ExitCode  )

  Return IsFunc(Callback) ? Callback.Call("", 0) : sOutput      

}

EucEncode( p_data, p_reserved:=true, p_encode:=true ) {

   unsafe := "25000102030405060708090A0B0C0D0E0F101112131415161718191A1B1C1D1E1F2022233C3E5B5C5D5E607B7C7D7F808182838485868788898A8B8C8D8E8F909192939495969798999A9B9C9D9E9FA0A1A2A3A4A5A6A7A8A9AAABACADAEAFB0B1B2B3B4B5B6B7B8B9BABBBCBDBEBFC0C1C2C3C4C5C6C7C8C9CACBCCCDCECFD0D1D2D3D4D5D6D7D8D9DADBDCDDDEDF7EE0E1E2E3E4E5E6E7E8E9EAEBECEDEEEFF0F1F2F3F4F5F6F7F8F9FAFBFCFDFEFF"

   if (p_reserved)
      unsafe .= "24262B2C2F3A3B3D3F40"

   if (p_encode) {
      loop (StrLen(unsafe) // 2) {
         token := SubStr(unsafe, A_Index * 2 - 1, 2)
         p_data := StrReplace(p_data, Chr(Integer("0x" token)), "%" token "%", "All")
      }
   } else {
      loop (StrLen(unsafe) // 2) {
         token := SubStr(unsafe, A_Index * 2 - 1, 2)
         p_data := StrReplace(p_data, "%" token "%", Chr(Integer("0x" token)), "All")
      }
   }

   return p_data
}

EucDecode( p_data ) {
   return EucEncode( p_data, true, false )
}
