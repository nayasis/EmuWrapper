#NoEnv
#Include, c:\app\emulator\ZZ_Library\Common.ahk

 ;!T:: 
 ;   debug("taskbar is hidden ? " Taskbar.isHidden() )
 ;   Taskbar.toggle()
 ;   return
 ;!F4::
 ;   ExitApp

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
    setAllTray(yn) {
    	this.allTray := ( yn == true )
    }

    toggle() {
    	if(this.isHidden()) {
			this.show()
    	} else {
    		this.hide()
    	}
    }

    show(forcibly:=false) {
    	IfWinExist ahk_class Shell_TrayWnd
    	{
    		if(forcibly == false)
    			return
    	}
		;Enable "Always on top" (& disable auto-hide)
		NumPut( (ABS_ALWAYSONTOP := 0x2), APPBARDATA, 32, "UInt" )
	    DllCall( "Shell32.dll\SHAppBarMessage", "UInt", ( ABM_SETSTATE := 0xA ), "UInt", &APPBARDATA )
	    WinShow ahk_class Shell_TrayWnd
	    if ( this.allTray == true ) {
			WinHide ahk_class Shell_SecondaryTrayWnd
	    }
		WinShow, Start ahk_class Button
    }

    hide(forcibly:=false) {
		IfWinNotExist ahk_class Shell_TrayWnd
		{
    		if(forcibly == false)
    			return
		}
		;Disable "Always on top" (& enable auto-hide to hide Start button)
		NumPut( ( ABS_AUTOHIDE := 0x1 ), APPBARDATA, 32, "UInt" )
	    DllCall( "Shell32.dll\SHAppBarMessage", "UInt", ( ABM_SETSTATE := 0xA ), "UInt", &APPBARDATA )
	    WinHide ahk_class Shell_TrayWnd
	    if ( this.allTray == true ) {
	    	WinShow ahk_class Shell_SecondaryTrayWnd
	    }
		WinHide, Start ahk_class Button
    }

    isHidden() {
    	IfWinNotExist ahk_class Shell_TrayWnd
    	{
    		return true
    	} else {
    		return false
    	}
    }

}