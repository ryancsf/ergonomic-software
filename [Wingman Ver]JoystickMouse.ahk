; Using a Joystick as a Mouse
; http://www.autohotkey.com
; This script converts a joystick into a three-button mouse.  It allows each
; button to drag just like a mouse button and it uses virtually no CPU time.
; Also, it will move the cursor faster depending on how far you push the joystick
; from center. You can personalize various settings at the top of the script.

; Increase the following value to make the mouse cursor move faster:
JoyMultiplier = 0.20

; Decrease the following value to require less joystick displacement-from-center
; to start moving the mouse.  However, you may need to calibrate your joystick
; -- ensuring it's properly centered -- to avoid cursor drift. A perfectly tight
; and centered joystick could use a value of 1:
JoyThreshold = 3

; Change the following to true to invert the Y-axis, which causes the mouse to
; move vertically in the direction opposite the stick:
InvertYAxis := false

; Change these values to use joystick button numbers other than 1, 2, and 3 for
; the left, right, and middle mouse buttons.  Available numbers are 1 through 32.
; Use the Joystick Test Script to find out your joystick's numbers more easily.
ButtonLeft = 4
ButtonRight = 3
ButtonMiddle = 2


; If your joystick has a POV control, you can use it as a mouse wheel.  The
; following value is the number of milliseconds between turns of the wheel.
; Decrease it to have the wheel turn faster:
WheelDelay = 250

; If your system has more than one joystick, increase this value to use a joystick
; other than the first:
JoystickNumber = 1

; END OF CONFIG SECTION -- Don't change anything below this point unless you want
; to alter the basic nature of the script.

#SingleInstance

JoystickPrefix = %JoystickNumber%Joy
Hotkey, %JoystickPrefix%%ButtonLeft%, ButtonLeft
Hotkey, %JoystickPrefix%%ButtonRight%, ButtonRight
Hotkey, %JoystickPrefix%%ButtonMiddle%, ButtonMiddle

; Calculate the axis displacements that are needed to start moving the cursor:
JoyThresholdUpper := 50 + JoyThreshold
JoyThresholdLower := 50 - JoyThreshold
if InvertYAxis
	YAxisMultiplier = -1
else
	YAxisMultiplier = 1

SetTimer, WatchJoystick, 10  ; Monitor the movement of the joystick.

GetKeyState, JoyInfo, %JoystickNumber%JoyInfo
IfInString, JoyInfo, P  ; Joystick has POV control, so use it as a mouse wheel.
	SetTimer, MouseWheel, %WheelDelay%

return  ; End of auto-execute section.


; The subroutines below do not use KeyWait because that would sometimes trap the
; WatchJoystick quasi-thread beneath the wait-for-button-up thread, which would
; effectively prevent mouse-dragging with the joystick.


#If GetKeyState("Joy1", "p") ; Autohotkey_L directive for enabling following mappings when key is physically down
	Joy4::
		Send, ^{w} ; ctrl + w to close tab
	return

	Joy2::
		Send, ^{Tab} ; ctrl + shift + tab
	return

	Joy3::
		Send, ^+{Tab} ; ctrl + shift + tab
	return
#If

ButtonLeft:
SetMouseDelay, -1  ; Makes movement smoother.
MouseClick, left,,, 1, 0, D  ; Hold down the left mouse button.
SetTimer, WaitForLeftButtonUp, 10
return

ButtonRight:
SetMouseDelay, -1  ; Makes movement smoother.
MouseClick, right,,, 1, 0, D  ; Hold down the right mouse button.
SetTimer, WaitForRightButtonUp, 10
return

ButtonMiddle:
SetMouseDelay, -1  ; Makes movement smoother.
MouseClick, middle,,, 1, 0, D  ; Hold down the right mouse button.
SetTimer, WaitForMiddleButtonUp, 10
return

WaitForLeftButtonUp:
if GetKeyState(JoystickPrefix . ButtonLeft)
	return  ; The button is still, down, so keep waiting.
; Otherwise, the button has been released.
SetTimer, WaitForLeftButtonUp, off
SetMouseDelay, -1  ; Makes movement smoother.
MouseClick, left,,, 1, 0, U  ; Release the mouse button.
return

WaitForRightButtonUp:
if GetKeyState(JoystickPrefix . ButtonRight)
	return  ; The button is still, down, so keep waiting.
; Otherwise, the button has been released.
SetTimer, WaitForRightButtonUp, off
MouseClick, right,,, 1, 0, U  ; Release the mouse button.
return

WaitForMiddleButtonUp:
if GetKeyState(JoystickPrefix . ButtonMiddle)
	return  ; The button is still, down, so keep waiting.
; Otherwise, the button has been released.
SetTimer, WaitForMiddleButtonUp, off
MouseClick, middle,,, 1, 0, U  ; Release the mouse button.
return

WatchJoystick:
MouseNeedsToBeMoved := false  ; Set default.
SetFormat, float, 03
GetKeyState, joyx, %JoystickNumber%JoyX
GetKeyState, joyy, %JoystickNumber%JoyY
if joyx > %JoyThresholdUpper%
{
	MouseNeedsToBeMoved := true
	DeltaX := joyx - JoyThresholdUpper
}
else if joyx < %JoyThresholdLower%
{
	MouseNeedsToBeMoved := true
	DeltaX := joyx - JoyThresholdLower
}
else
	DeltaX = 0
if joyy > %JoyThresholdUpper%
{
	MouseNeedsToBeMoved := true
	DeltaY := joyy - JoyThresholdUpper
}
else if joyy < %JoyThresholdLower%
{
	MouseNeedsToBeMoved := true
	DeltaY := joyy - JoyThresholdLower
}
else
	DeltaY = 0
if MouseNeedsToBeMoved
{
	SetMouseDelay, -1  ; Makes movement smoother.
	if (GetKeystate("Joy1") = 1) ; Speed up the mouse cursor
    {
        JoyMultiplier = 0.6
    }else if (GetKeystate("Joy6") = 1) ; Slow down the mouse cursor
    {
        JoyMultiplier = 0.05
    }else{
    	JoyMultiplier = 0.2
    }
	MouseMove, DeltaX * JoyMultiplier, DeltaY * JoyMultiplier * YAxisMultiplier, 0, R
}
return

MouseWheel:
GetKeyState, JoyPOV, %JoystickNumber%JoyPOV
if JoyPOV = -1  ; No angle.
	return
if (JoyPOV > 31500 or JoyPOV < 4500)  ; Forward
	Send {WheelUp}
else if JoyPOV between 13500 and 22500  ; Back
	Send {WheelDown}
return
