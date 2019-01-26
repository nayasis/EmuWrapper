MEmu = M88
MEmuV = v2013/05/14 (unofficial)
MURL = http://illusioncity.net/nec-pc-88-series-emulators-tools-lists/
MAuthor = djvj
MVersion = 2.0.0
MCRC =
iCRC =
mId =
MSystem = "NEC PC-88","NEC PC-8800","NEC PC-8801"
;----------------------------------------------------------------------------
; Notes:
; Make sure msvcr71.dll is installed in your system or it exists in the emu's root folder
;----------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()

; settingsFile := modulePath . "\" . moduleName . ".ini"
; Fullscreen := IniReadCheck(settingsFile, "Settings", "Fullscreen","true",,1)

m88INI := CheckFile(emuPath . "\M88.ini")
; Did not work to set fullscreen...need another method
; IniRead, currentFullScreen , %iniFile%, M88p2 for Windows, FullWindow
; if (currentFullScreen = 0) and (Fullscreen != "Fullscreen")
; IniWrite, 1, %m88INI%, M88p2 for Windows, FullWindow
; Else If (currentFullScreen = 1) and (Fullscreen = "Fullscreen")
; IniWrite, 0, %m88INI%, M88p2 for Windows, FullWindow

BezelStart("FixResMode")

hideEmuObj := Object("88 ahk_class M88p2 WinUI",1) ; Hide_Emu will hide these windows. 0 = will never unhide, 1 = will unhide later
7z(romPath, romName, romExtension, 7zExtractPath)



If (romExtension = ".d88") {
; Will also need MultiGame support here
IniRead, pc88Mode , %iniFile%, M88p2 for Windows, BASICMode ; get current mode set in emu
; If (pc88Mode != 113)
; IniWrite, 113, %m88INI%, M88p2 for Windows, BASICMode ; set to N88-V2 mode - oddly doesn't set the system correctly on next launch, yet this is the only ini setting that changes.
IniWrite, %romPath%\%romName%%romExtension%, %m88INI%, M88p2 for Windows, d88
IniWrite, %romPath%\%romName%%romExtension%, %m88INI%, M88p2 for Windows, FD1NAME0
IniWrite, 0, %m88INI%, M88p2 for Windows, Resume
} Else {
; Add other rom extension support here, like t88 and cmt for cassettes, not sure what extensions are CDs
; IniWrite, 49, %m88INI%, M88p2 for Windows, BASICMode ; set to N88-V2(CD) mode
ScriptError("This is not a supported extension in the module yet")
}

HideEmuStart()
Run(executable, emuPath)

WinWait("88 ahk_class M88p2 WinUI")
WinWaitActive("88 ahk_class M88p2 WinUI")

PostMessage, 0x111, 40400,,,88 ahk_class M88p2 WinUI ; Select FD1NAME0
PostMessage, 0x111, 40003,,,88 ahk_class M88p2 WinUI ; Reset system to load rom

BezelDraw()
HideEmuEnd()
FadeInExit()
Process("WaitClose", executable)
7zCleanUp()
BezelExit()
FadeOutExit()
ExitModule()


CloseProcess:
FadeOutStart()
WinClose("88 ahk_class M88p2 WinUI")
Return