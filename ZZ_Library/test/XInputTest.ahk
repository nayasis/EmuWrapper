#Singleinstance force
#NoEnv ;may improve performance
SendMode Input

#include %A_ScriptDir%\..\XInput.ahk

XInput_Init()

F1::
	Caps := XInput_GetCapabilities()
	if Caps {
		MsgBox % "UserIndex: " . Caps.UserIndex . "`n"
			. "SubType: " . Caps.SubType . "`n" 
			. "Flags: " . Caps.Flags . "`n" 
			. "Buttons: " . Caps.Buttons . "`n" 
			. "LeftTrigger: " . Caps.LeftTrigger . "`n" 
			. "RightTrigger: " . Caps.RightTrigger . "`n" 
			. "ThumbLX: " . Caps.ThumbLX . "`n" 
			. "ThumbLY: " . Caps.ThumbLY . "`n" 
			. "ThumbRX: " . Caps.ThumbRX . "`n" 
			. "ThumbRY: " . Caps.ThumbRY . "`n" 
			. "LeftMotorSpeed: " . Caps.LeftMotorSpeed . "`n" 
			. "RightMotorSpeed: " . Caps.RightMotorSpeed . "`n" 
	}
	else if ErrorLevel = ERROR_DEVICE_NOT_CONNECTED
		MsgBox, Failed to find a connected XInput gamepad controller.
	else
		MsgBox, ErrorLevel: %ErrorLevel% `n`nERROR_SUCCESS = 0`nERROR_DEVICE_NOT_CONNECTED = 1167
return


F2::
	State := XInput_GetState()
	
	if State {
		MsgBox % "UserIndex: " . State.UserIndex . "`n" ; The index number of the gamepad
			;. "PacketNumber: " . State.PacketNumber . PacketNumber . "`n" ; This value increments whenever the state of the gamepad changes.
			. "Buttons: " . State.Buttons . "`n" ; Which buttons are pressed (Bitwise OR). See XInput_Init (above) for the list of buttons.
			. "LeftTrigger: " . State.LeftTrigger . "`n" ; Between 0 and 255
			. "RightTrigger: " . State.RightTrigger . "`n" 
			. "ThumbLX: " State.ThumbLX . "`n" ; Between -32768 to 32767. 0 is centered. Negative is down or left.
			. "ThumbLY: " . State.ThumbLY . "`n" 
			. "ThumbRX: " . State.ThumbRX . "`n" 
			. "ThumbRY: " . State.ThumbRY . "`n" 
	}
	else if ErrorLevel = ERROR_DEVICE_NOT_CONNECTED
		MsgBox, Failed to find a connected XInput gamepad controller.
	else
		MsgBox, ErrorLevel: %ErrorLevel% `n`nERROR_SUCCESS = 0`nERROR_DEVICE_NOT_CONNECTED = 1167
return


F3::
	Battery := XInput_GetBatteryInformation()
	if Battery {
		MsgBox % "UserIndex: " . Battery.UserIndex . "`n" ; Index of the user's controller. Can be a value of 0 to XUSER_MAX_COUNT - 1.
			. "DevType: " . DevType . "`n" ; Specifies which device associated with this user index should be queried. Must be BATTERY_DEVTYPE_GAMEPAD or BATTERY_DEVTYPE_HEADSET.
			. "BatteryType: " . BatteryType . "`n" ; The type of battery.
			. "BatteryLevel: " . BatteryLevel . "`n"  ; The charge state of the battery. This value is only valid for wireless devices with a known battery type.
	}
	else if ErrorLevel = ERROR_DEVICE_NOT_CONNECTED
		MsgBox, Failed to find a connected XInput gamepad controller.
	else
		MsgBox, ErrorLevel: %ErrorLevel% `n`nERROR_SUCCESS = 0`nERROR_DEVICE_NOT_CONNECTED = 1167
return


F4::
	Keystroke = XInput_GetKeystroke()
	
	if Keystroke {
		MsgBox % "UserIndex: " . Keystroke.UserIndex . "`n" ; Index of the signed-in gamer associated with the device. Can be a value in the range 0–3.
			. "VirtualKey: " . Keystroke.VirtualKey . "`n" ; Virtual-key code of the key, button, or stick movement. 
			;. "Unicode: " . Keystroke.Unicode . "`n" ; This member is unused and the value is zero.
			. "Flags: " . Keystroke.Flags . "`n" ; Flags that indicate the keyboard state at the time of the input event. 
			. "HidCode: " . Keystroke.HidCode . "`n" ; HID code corresponding to the input. If there is no corresponding HID code, this value is zero.
	}
	else if ErrorLevel = ERROR_EMPTY
		MsgBox, No new gamepad keystrokes.
	else if ErrorLevel = ERROR_DEVICE_NOT_CONNECTED
		MsgBox, Failed to find a connected XInput gamepad controller.
	else
		MsgBox, ErrorLevel: %ErrorLevel% `n`nERROR_SUCCESS = 0`nERROR_DEVICE_NOT_CONNECTED = 1167`nERROR_EMPTY = 4306
return

F5::Reload
F6::Suspend
F7::ExitApp 