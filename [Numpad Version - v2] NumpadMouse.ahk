;START OF CONFIG SECTION

#SingleInstance force
#MaxHotkeysPerInterval 500

; Using the keyboard hook to implement the NumPad hotkeys prevents
; them from interfering with the generation of ANSI characters such
; as à.  This is because AutoHotkey generates such characters
; by holding down ALT and sending a series of NumPad keystrokes.
; Hook hotkeys are smart enough to ignore such keystrokes.
#UseHook

;Pointer movement cycle speed
PointerMovementCycleInterval:=10 ;in milliseconds (approx. depending on computer performance)

;Mouse button cycle speed
ButtonPressCycleInterval:=10 ;in milliseconds (approx. depending on computer performance)

;The following can also be configured while using the script:

;Button lock states:
;1=on (pressing once = hold, pressing again = release)
;0=off (need holding and releasing of buttons).
ClickLockState:=0
MovementLockState:=0

;Allows movement relative to the screen coordinates.
;Z and W axis (mouse wheel) can't be captured, but
;they still can be used.
MovementRelativeToScreen:=1

;Shows the coordinates traytip whenever moving.
ShowCoordinatesTooltip:=0

;Time variable deltas per cycle (speed).
tXMagnitude:=5.000000
tYMagnitude:=5.000000
tZMagnitude:=1.000000
tWMagnitude:=1.000000

;; Standard Setup For sector targetting
SysGet, resolution, Monitor

;END OF CONFIG SECTION

Equation:=0

MovementParametrizations:=0

MovementTotalMagnitudeTX:=0.000000
MovementTotalMagnitudeTY:=0.000000
MovementTotalMagnitudeTZ:=0.000000
MovementTotalMagnitudeTW:=0.000000

SysGet, ScreenResolutionWidth, 78
SysGet, ScreenResolutionHeight, 79

EquationOriginX:=(ScreenResolutionWidth/2)*1.000000
EquationOriginY:=(ScreenResolutionHeight/2)*1.000000
EquationOriginZ:=0.000000
EquationOriginW:=0.000000

GlobalPointerCurrentX:=0.000000
GlobalPointerCurrentY:=0.000000
GlobalPointerCurrentZ:=0.000000

GlobalEquationX:=0.000000
GlobalEquationY:=0.000000
GlobalEquationZ:=0.000000
GlobalEquationW:=0.000000

GlobalAngle:=0.000000
GlobalQuaternaryA:=1.000000
GlobalQuaternaryB:=0.000000
GlobalQuaternaryC:=0.000000
GlobalQuaternaryD:=0.000000
GlobalQuaternaryE:=0.000000

GlobalQuaternaryRotationX:=1.000000
GlobalQuaternaryRotationY:=1.000000
GlobalQuaternaryRotationZ:=1.000000
GlobalQuaternaryRotationW:=1.000000

GlobalRotationVectorX:=0.000000
GlobalRotationVectorY:=0.000000
GlobalRotationVectorZ:=0.000000
GlobalRotationVectorW:=0.000000

CoordMode, Mouse, Screen

;This is needed or key presses would faulty send their natural
;actions. Like NumPadDiv would send sometimes "/" to the
;screen.
#InstallKeybdHook

Buttons:=0

SetKeyDelay, -1
SetMouseDelay, -1

Hotkey, *NumPadHome, SendLeftClick
Hotkey, *NumPadUp, ButtonMiddleClickClear
Hotkey, *NumPadPgUp, ButtonRightClickDel
Hotkey, *NumPadDel, LastUsedTab
Hotkey, *NumPadClear, ReOpenTab
Hotkey, *NumPadIns, ToggleChromeVSCode
Hotkey, *NumPadDiv, CloseTab
Hotkey, *NumPadSub, PageUpHotKey
Hotkey, *NumPadAdd, PageDownHotKey
Hotkey, *NumPadRight, TabRight
Hotkey, *NumPadLeft, TabLeft
Hotkey, *NumPadMult, InspectElement
Hotkey, *NumPadPgDn, Paste
Hotkey, *NumPadEnd, Copy
Hotkey, *NumPadDown, Save

Gosub, ~NumLock  ; Initialize based on current ScrollLock state.
return

;Key activation support

~NumLock::
; Wait for it to be released because otherwise the hook state gets reset
; while the key is down, which causes the up-event to get suppressed,
; which in turn prevents toggling of the ScrollLock state/light:
KeyWait, NumLock
GetKeyState, NumLockState, NumLock, T
If NumLockState = D
{
    Hotkey, *NumPadHome, off
    Hotkey, *NumPadUp, off
    Hotkey, *NumPadPgUp, off
    Hotkey, *NumPadDel, off
    Hotkey, *NumPadClear, off
    Hotkey, *NumPadIns, off
    Hotkey, *NumPadDiv, off
    Hotkey, *NumPadSub, off
    Hotkey, *NumPadAdd, off
    Hotkey, *NumPadRight, off
    Hotkey, *NumPadLeft, off
    Hotkey, *NumPadMult, off
    Hotkey, *NumPadPgDn, off
    Hotkey, *NumPadEnd, off
    Hotkey, *NumPadDown, off
}
else
{
    Hotkey, *NumPadHome, on
    Hotkey, *NumPadUp, on
    Hotkey, *NumPadDel, on
    Hotkey, *NumPadPgUp, on
    Hotkey, *NumPadClear, on
    Hotkey, *NumPadIns, on
    Hotkey, *NumPadDiv, on
    Hotkey, *NumPadSub, on
    Hotkey, *NumPadAdd, on
    Hotkey, *NumPadRight, on
    Hotkey, *NumPadLeft, on
    Hotkey, *NumPadMult, on
    Hotkey, *NumPadPgDn, on
    Hotkey, *NumPadEnd, on
    Hotkey, *NumPadDown, on
}
return

;Pointer click section
;-----------------------

ButtonLeftClick:
ButtonLeftClickIns:
  ButtonClickType:="Left"
  PointerButtonName:="LButton"
Goto ButtonClickStart

ButtonMiddleClick:
ButtonMiddleClickClear:
  ButtonClickType:="Middle"
  PointerButtonName:="MButton"
Goto ButtonClickStart

ButtonRightClick:
ButtonRightClickDel:
  ButtonClickType:="Right"
  PointerButtonName:="RButton"
Goto ButtonClickStart

ButtonX1Click:
  ButtonClickType:="X1"
  PointerButtonName:="XButton1"
Goto ButtonClickStart

ButtonX2Click:
  ButtonClickType:="X2"
  PointerButtonName:="XButton2"

ButtonClickStart:
StringReplace, ButtonName, A_ThisHotkey, *
If (ButtonDown_%ButtonName%!=1)
{
  ;This adds the button to the button array
  ButtonDown_%ButtonName%:=1
  Buttons:=Buttons+1
  Button%Buttons%Name:=ButtonName
  Button%Buttons%ClickType:=ButtonClickType
  Button%Buttons%PointerButtonName:=PointerButtonName
  Button%Buttons%Initialized:=0
  Button%Buttons%UnHoldStep:=0
  If (Buttons = 1)
    SetTimer, ButtonPressCycle, % ButtonPressCycleInterval
}
Return

ButtonPressCycle:
If (Buttons=0)
{
  SetTimer, ButtonPressCycle, off
  Return
}

Button:=0
Loop
{
  ;Click section
  Button:=Button+1
  If (Button%Buttons%Initialized=0)
  {
    GetKeyState, PointerButtonState, % Button%Button%PointerButtonName
    If (PointerButtonState="D")
      Continue
    MouseClick, % Button%Button%ClickType,,, 1, 0, D
    Button%Buttons%Initialized:=1
  }

  ;Click release section
  GetKeyState, ButtonState, % Button%Button%Name, P
  If (ButtonState="U" and (ClickLockState=0 or (ClickLockState=1 and Button%Buttons%UnHoldStep=2)))
  {
    ButtonName:=Button%Buttons%Name
    ButtonDown_%ButtonName%:=0
    MouseClick, % Button%Button%ClickType,,, 1, 0, U

    ;This removes the button from the button array
    ;(AHK really needs proper array implementation)
    ButtonTemp:=Button
    ButtonTempPrev:=ButtonTemp-1

    Loop
    {
      ButtonTemp:=ButtonTemp+1
      ButtonTempPrev:=ButtonTempPrev+1

      If (Buttons<ButtonTemp)
      {
        Button%ButtonTempPrev%Name:=""
        Button%ButtonTempPrev%ClickType:=""
        Button%ButtonTempPrev%PointerButtonName:=""
        Button%ButtonTempPrev%Initialized:=0
        Break
      }
      Button%ButtonTempPrev%Name:=Button%ButtonTemp%Name
      Button%ButtonTempPrev%ClickType:=Button%ButtonTemp%ClickType
      Button%ButtonTempPrev%PointerButtonName:=Button%ButtonTemp%PointerButtonName
      Button%ButtonTempPrev%Initialized:=Button%ButtonTemp%Initialized
    }
    Buttons:=Buttons-1
  }

  ;LockState explaination:

  ;Start (button press): UnHoldStep is set to 1.
  ;Middle (cycles after that): click section is executed.
  ;End (button release): UnHoldStep is set to 2.
  ;(1 cycle after that): click release section is executed.

  If(ButtonState="U" and ClickLockState=1 and Button%Buttons%UnHoldStep=0)
    Button%Buttons%UnHoldStep:=1
  If(ButtonState="D" and ClickLockState=1 and Button%Buttons%UnHoldStep=1)
    Button%Buttons%UnHoldStep:=2

  If (Buttons<=Button)
    Break
}
Return


;Pointer movement section
;--------------------------
ButtonXUp:
    MovementMagnitudeTemp:=+tXMagnitude
    MovementDimensionTemp:="x"
Goto ButtonPointerMovementStart

ButtonXDown:
    MovementMagnitudeTemp:=-tXMagnitude
    MovementDimensionTemp:="x"
Goto ButtonPointerMovementStart

ButtonYUp:
    MovementMagnitudeTemp:=+tYMagnitude
    MovementDimensionTemp:="y"
Goto ButtonPointerMovementStart

ButtonYDown:
    MovementMagnitudeTemp:=-tYMagnitude
    MovementDimensionTemp:="y"
Goto ButtonPointerMovementStart

ButtonZUp:
    MovementMagnitudeTemp:=+tZMagnitude
    MovementDimensionTemp:="z"
Goto ButtonPointerMovementStart

ButtonZDown:
    MovementMagnitudeTemp:=-tZMagnitude
    MovementDimensionTemp:="z"
Goto ButtonPointerMovementStart

TabRight:
  Send ^{Tab}
Return

TabLeft:
  Send ^+{Tab}
Return

SwitchWindows:
  Send !{Esc}
Return

CloseTab:
  Send ^{w}
Return

ReOpenTab:
  Send ^+{t}
Return

CenterMouse:
  CoordMode, Mouse, Screen
  MouseMove, (A_ScreenWidth // 2), (A_ScreenHeight // 2)
Return

InspectElement:
    Send, ^+c
Return

SendBackspace:
    Send, {Backspace}
Return

SendLeftClick:
  Click
Return

Copy:
    Send, ^c
Return

Save:
    Send, ^s
Return

MiniatureWindow:
    Send, ^{Space}
Return

ToggleChromeVSCode:
    toggle := !toggle
        if(toggle)
            send #1
        else
            send #2
Return

LastUsedTab:
  Send, !s
Return

Paste:
  Send, ^v
Return

MiddleLeft:
    ;; Standard Setup
    sectorTopX := 0
    sectorTopY := 0
    sectorWidth := resolutionRight
    sectorHeight := resolutionBottom
    sectorWidth := Floor(sectorWidth/3)
    sectorHeight := Floor(sectorHeight/3)

    sectorTopY := sectorTopY + sectorHeight

    ;; Standard Execution
    newX := sectorTopX + Floor(sectorWidth/2)
    newY := sectorTopY + Floor(sectorHeight/2)
    MouseMove, %newX%, %newY%
Return

MiddleMiddle:
    ;; Standard Setup
    sectorTopX := 0
    sectorTopY := 0
    sectorWidth := resolutionRight
    sectorHeight := resolutionBottom
    sectorWidth := Floor(sectorWidth/3)
    sectorHeight := Floor(sectorHeight/3)

    sectorTopX := sectorTopX + sectorWidth
    sectorTopY := sectorTopY + sectorHeight

    ;; Standard Execution
    newX := sectorTopX + Floor(sectorWidth/2)
    newY := sectorTopY + Floor(sectorHeight/2)
    MouseMove, %newX%, %newY%
Return

MiddleRight:
    ;; Standard Setup
    sectorTopX := 0
    sectorTopY := 0
    sectorWidth := resolutionRight
    sectorHeight := resolutionBottom
    sectorWidth := Floor(sectorWidth/3)
    sectorHeight := Floor(sectorHeight/3)

    sectorTopX := sectorTopX + (2*sectorWidth)
    sectorTopY := sectorTopY + sectorHeight

    ;; Standard Execution
    newX := sectorTopX + Floor(sectorWidth/2)
    newY := sectorTopY + Floor(sectorHeight/2)
    MouseMove, %newX%, %newY%
Return

BtmLeft:
    ;; Standard Setup
    sectorTopX := 0
    sectorTopY := 0
    sectorWidth := resolutionRight
    sectorHeight := resolutionBottom
    sectorWidth := Floor(sectorWidth/3)
    sectorHeight := Floor(sectorHeight/3)

    sectorTopY := sectorTopY + (2*sectorHeight)
    
    ;; Standard Execution
    newX := sectorTopX + Floor(sectorWidth/2)
    newY := sectorTopY + Floor(sectorHeight/2)
    MouseMove, %newX%, %newY%
Return

BtmMiddle:
    ;; Standard Setup
    sectorTopX := 0
    sectorTopY := 0
    sectorWidth := resolutionRight
    sectorHeight := resolutionBottom
    sectorWidth := Floor(sectorWidth/3)
    sectorHeight := Floor(sectorHeight/3)

    sectorTopX := sectorTopX + sectorWidth
    sectorTopY := sectorTopY + (2*sectorHeight)

    ;; Standard Execution
    newX := sectorTopX + Floor(sectorWidth/2)
    newY := sectorTopY + Floor(sectorHeight/2)
    MouseMove, %newX%, %newY%
Return

BtmRight:
    ;; Standard Setup
    sectorTopX := 0
    sectorTopY := 0
    sectorWidth := resolutionRight
    sectorHeight := resolutionBottom
    sectorWidth := Floor(sectorWidth/3)
    sectorHeight := Floor(sectorHeight/3)

    sectorTopX := sectorTopX + (2*sectorWidth)
    sectorTopY := sectorTopY + (2*sectorHeight)

    ;; Standard Execution
    newX := sectorTopX + Floor(sectorWidth/2)
    newY := sectorTopY + Floor(sectorHeight/2)
    MouseMove, %newX%, %newY%
Return


ButtonWUp:
    MovementMagnitudeTemp:=+tWMagnitude
    MovementDimensionTemp:="w"
Goto ButtonPointerMovementStart

ButtonWDown:
    MovementMagnitudeTemp:=-tWMagnitude
    MovementDimensionTemp:="w"

ButtonPointerMovementStart:
StringReplace, MovementButtonName, A_ThisHotkey, *
If (MovementButtonDown_%MovementButtonName%!=1)
{
    MovementButtonDown_%MovementButtonName%:=1
    MovementParametrizations:=MovementParametrizations+1
    MovementParametrization%MovementParametrizations%Name:=MovementButtonName
    MovementParametrization%MovementParametrizations%Dimension:=MovementDimensionTemp
    MovementParametrization%MovementParametrizations%Magnitude:=MovementMagnitudeTemp
    MovementParametrization%MovementParametrizations%Initialized:=0
    MovementParametrization%MovementParametrizations%UnHoldStep:=0
    If (MovementParametrizations = 1)
    {
        SetTimer, MovementParametrizatio, % PointerMovementCycleInterval
    }
}
Return

MovementParametrizationInitialization:
If (MovementParametrization%MovementParametrization%Dimension = "x")
{
    MovementMagnitudeTX:=MovementParametrization%MovementParametrization%Magnitude
    MovementTotalMagnitudeTX:=MovementTotalMagnitudeTX+MovementMagnitudeTX
}
If (MovementParametrization%MovementParametrization%Dimension = "y")
{
    MovementMagnitudeTY:=MovementParametrization%MovementParametrization%Magnitude
    MovementTotalMagnitudeTY:=MovementTotalMagnitudeTY+MovementMagnitudeTY
}
If (MovementParametrization%MovementParametrization%Dimension = "z")
{
    MovementMagnitudeTZ:=MovementParametrization%MovementParametrization%Magnitude
    MovementTotalMagnitudeTZ:=MovementTotalMagnitudeTZ+MovementMagnitudeTZ
}
If (MovementParametrization%MovementParametrization%Dimension = "w")
{
    MovementMagnitudeTW:=MovementParametrization%MovementParametrization%Magnitude
    MovementTotalMagnitudeTW:=MovementTotalMagnitudeTW+MovementMagnitudeTW
}
Return

MovementParametrizatio:
If (MovementParametrizations=0)
{
  MovementTotalMagnitudeTX:=0.000000
  MovementTotalMagnitudeTY:=0.000000
  MovementTotalMagnitudeTZ:=0.000000
  MovementTotalMagnitudeTW:=0.000000
  SetTimer, MovementParametrizatio, off
  Return
}
MovementParametrization:=0
Loop
{
  MovementParametrization:=MovementParametrization+1
  If (MovementParametrization%MovementParametrization%Initialized=0)
  {
    Gosub, MovementParametrizationInitialization
    ;TrayTip,,% MovementParametrization
    MovementParametrization%MovementParametrization%Initialized:=1
  }
  GetKeyState, MovementButtonState, % MovementParametrization%MovementParametrization%Name, P
  If (MovementButtonState="U" and (MovementLockState=0 or (MovementLockState=1 and MovementParametrization%MovementParametrization%UnHoldStep=2)))
  {
    MovementButtonName:=MovementParametrization%MovementParametrization%Name
    MovementButtonDown_%MovementButtonName%:=0
    MovementParametrization%MovementParametrization%Magnitude:=-MovementParametrization%MovementParametrization%Magnitude
    Gosub, MovementParametrizationInitialization

    MovementParametrizationTemp:=MovementParametrization
    MovementParametrizationTempPrev:=MovementParametrization-1
    Loop
    {
      MovementParametrizationTemp:=MovementParametrizationTemp+1
      MovementParametrizationTempPrev:=MovementParametrizationTempPrev+1
      If (MovementParametrizations<MovementParametrizationTemp)
      {
        MovementParametrization%MovementParametrizationTempPrev%Name:=""
        MovementParametrization%MovementParametrizationTempPrev%Dimension:=0
        MovementParametrization%MovementParametrizationTempPrev%Magnitude:=0
        MovementParametrization%MovementParametrizationTempPrev%Initialized:=0
        MovementParametrization%MovementParametrizationTempPrev%UnHoldStep:=0
        Break
      }
      MovementParametrization%MovementParametrizationTempPrev%Name:=MovementParametrization%MovementParametrizationTemp%Name
      MovementParametrization%MovementParametrizationTempPrev%Dimension:=MovementParametrization%MovementParametrizationTemp%Dimension
      MovementParametrization%MovementParametrizationTempPrev%Magnitude:=MovementParametrization%MovementParametrizationTemp%Magnitude
      MovementParametrization%MovementParametrizationTempPrev%Initialized:=MovementParametrization%MovementParametrizationTemp%Initialized
      MovementParametrization%MovementParametrizationTempPrev%UnHoldStep:=MovementParametrization%MovementParametrizationTemp%UnHoldStep
    }
    MovementParametrizations:=MovementParametrizations-1
  }

  If(MovementButtonState="U" and MovementLockState=1 and MovementParametrization%MovementParametrization%UnHoldStep=0)
    MovementParametrization%MovementParametrization%UnHoldStep:=1
  If(MovementButtonState="D" and MovementLockState=1 and MovementParametrization%MovementParametrization%UnHoldStep=1)
    MovementParametrization%MovementParametrization%UnHoldStep:=2

  If (MovementParametrizations<=MovementParametrization)
    Break
}

MouseGetPos, PointerCurrentX, PointerCurrentY
PointerCurrentX:=PointerCurrentX & 0xFFFF

SysGet, ScreenResolutionWidth, 78
SysGet, ScreenResolutionHeight, 79

EquationX:=PointerCurrentX-EquationOriginX
EquationY:=((ScreenResolutionHeight-1)-PointerCurrentY)-EquationOriginY
EquationZ:=GlobalEquationZ
EquationW:=GlobalEquationW

;PEquationNextX:=EquationNextX
;PEquationNextY:=EquationNextY
PEquationNextZ:=EquationNextZ
if (PEquationNextZ == "")
    PEquationNextZ = 0.000000
PEquationNextW:=EquationNextW
if (PEquationNextW == "")
    PEquationNextW = 0.000000

If((Equation%Equation%Inv(EquationX, EquationY, EquationZ, EquationW) <> -1) and MovementRelativeToScreen=1)
{
    EquationNextX:=(EquationX+MovementTotalMagnitudeTX)
    EquationNextY:=(EquationY+MovementTotalMagnitudeTY)
    EquationNextZ:=(EquationZ+MovementTotalMagnitudeTZ)
    EquationNextW:=(EquationW+MovementTotalMagnitudeTW)
}
Else
{
    EquationNextX:=(GlobalEquationX+MovementTotalMagnitudeTX)
    EquationNextY:=(GlobalEquationY+MovementTotalMagnitudeTY)
    EquationNextZ:=(GlobalEquationZ+MovementTotalMagnitudeTZ)
    EquationNextW:=(GlobalEquationW+MovementTotalMagnitudeTW)
}

GlobalEquationX:=EquationNextX
GlobalEquationY:=EquationNextY
GlobalEquationZ:=EquationNextZ
GlobalEquationW:=EquationNextW

Equation%Equation%(EquationNextX, EquationNextY, EquationNextZ, EquationNextW)

EquationNextX:=GlobalQuaternaryRotationX*EquationNextX
EquationNextY:=GlobalQuaternaryRotationY*EquationNextY
EquationNextZ:=GlobalQuaternaryRotationZ*EquationNextZ
EquationNextW:=GlobalQuaternaryRotationW*EquationNextW
If(ShowCoordinatesTooltip = 1)
    Traytip,,% "(" . EquationNextX . "," . EquationNextY . "," . EquationNextZ . "," . EquationNextW ") <" . Floor(GlobalEquationX) . "," . Floor(GlobalEquationY) . "," . Floor(GlobalEquationZ) . "," . Floor(GlobalEquationW) . ">"

ToScreenCoordsCurrentX:=EquationNextX+EquationOriginX
ToScreenCoordsCurrentY:=(ScreenResolutionHeight-1)-(EquationNextY+EquationOriginY)
ToScreenCoordsCurrentZ:=EquationNextZ - PEquationNextZ
ToScreenCoordsCurrentW:=EquationNextW - PEquationNextW

MouseMove, % ToScreenCoordsCurrentX, % ToScreenCoordsCurrentY, 0

If (ToScreenCoordsCurrentZ > 0)
{
    MouseClick, wheelup,,, % ToScreenCoordsCurrentZ, 0, D
}
Else if (ToScreenCoordsCurrentZ < 0)
{
    MouseClick, wheeldown,,, % -ToScreenCoordsCurrentZ, 0, D
}

If (ToScreenCoordsCurrentW > 0)
{
    MouseClick, wheelright,,, % ToScreenCoordsCurrentW, 0, D
}
Else if (ToScreenCoordsCurrentW < 0)
{
    MouseClick, wheelleft,,, % -ToScreenCoordsCurrentW, 0, D
}
Return

ButtonToEquationCurrent:
EquationNextX:=GlobalEquationX
EquationNextY:=GlobalEquationY
EquationNextZ:=GlobalEquationZ
EquationNextW:=GlobalEquationW

Equation%Equation%(EquationNextX,EquationNextY,EquationNextZ,EquationNextW)

EquationNextX:=GlobalQuaternaryRotationX*EquationNextX
EquationNextY:=GlobalQuaternaryRotationY*EquationNextY
EquationNextZ:=GlobalQuaternaryRotationZ*EquationNextZ
EquationNextW:=GlobalQuaternaryRotationW*EquationNextW

ToScreenCoordsCurrentX:=EquationNextX+EquationOriginX
ToScreenCoordsCurrentY:=(ScreenResolutionHeight-1)-(EquationNextY+EquationOriginY)
ToScreenCoordsCurrentZ:=(EquationNextZ-GlobalEquationZ)
ToScreenCoordsCurrentW:=(EquationNextW-GlobalEquationW)

MouseMove, % ToScreenCoordsCurrentX, % ToScreenCoordsCurrentY, 0
ToolTip, % "Moved pointer to parametric equation's current position at: (" . ToScreenCoordsCurrentX . "," . ToScreenCoordsCurrentY . "," . ToScreenCoordsCurrentZ . "," . ToScreenCoordsCurrentW . ")"
SetTimer, RemoveToolTip, 5000
Return

ButtonResetEquation:
SysGet, ScreenResolutionWidth, 78
SysGet, ScreenResolutionHeight, 79

GlobalEquationX:=0
GlobalEquationY:=0
GlobalEquationZ:=0
GlobalEquationW:=0

EquationNextX:=0
EquationNextY:=0
EquationNextZ:=0
EquationNextW:=0

ToolTip, % "All time variables are now set to 0."

SetTimer, RemoveToolTip, 5000
Return

ButtonCentralizeEquation:
MouseGetPos, PointerCurrentX, PointerCurrentY
PointerCurrentX:=PointerCurrentX & 0xFFFF

SysGet, ScreenResolutionWidth, 78
SysGet, ScreenResolutionHeight, 79

EquationOriginX:=PointerCurrentX*1.000000
EquationOriginY:=((ScreenResolutionHeight-1)-PointerCurrentY)*1.000000
EquationOriginZ:=GlobalEquationZ
EquationOriginW:=GlobalEquationW
ToolTip, % "Set parametric equation center at: (" . PointerCurrentX*1.000000 . "," . PointerCurrentY*1.000000 . "," . GlobalEquationZ . "," . GlobalEquationW . ")"
GlobalEquationX:=0
GlobalEquationY:=0
GlobalEquationZ:=0
GlobalEquationW:=0
SetTimer, RemoveToolTip, 5000
Return

ButtonLockClick:
If (ClickLockState = 0)
{
    ClickLockState:=1
}
Else
{
    ClickLockState:=0
}
ToolTip, % "Lock click ctate? (1 = True, 0 = False): " . ClickLockState
SetTimer, RemoveToolTip, 5000
Return

ButtonLockMovement:
If (MovementLockState = 0)
{
    MovementLockState:=1
}
Else
{
    MovementLockState:=0
}
ToolTip, % "Lock movement state? (1 = True, 0 = False): " . MovementLockState
SetTimer, RemoveToolTip, 5000
Return

ButtonUseRelativeSystem:
If (MovementRelativeToScreen = 0)
{
    MovementRelativeToScreen:=1
}
Else
{
    MovementRelativeToScreen:=0
}
ToolTip, % "Movement relative to screen? (1 = True, 0 = False): " . MovementRelativeToScreen
SetTimer, RemoveToolTip, 5000
Return

ButtonShowCoordinatesTooltip:
If (ShowCoordinatesTooltip = 0)
{
    ShowCoordinatesTooltip:=1
}
Else
{
    ShowCoordinatesTooltip:=0
}
ToolTip, % "Show coordinates traytip? (1 = True, 0 = False): " . ShowCoordinatesTooltip
SetTimer, RemoveToolTip, 5000
Return

PageUpHotKey:
  Send {Up 10}
Return

PageDownHotKey:
  Send {Down 10}
Return

ButtonSpeedUp:
    Send {LShift down}
    tXMagnitude:=25.000000
    tYMagnitude:=25.000000
    KeyWait, LShift
    Send {LShift up}
    tXMagnitude = 5.000000
    tYMagnitude = 5.000000
Return

ButtonSpeedDown:
    Send {LCtrl down}
    tXMagnitude:=2.000000
    tYMagnitude:=2.000000
    KeyWait, LCtrl
    Send {LCtrl up}
    tXMagnitude = 5.000000
    tYMagnitude = 5.000000
Return

ButtonRotateEquationAgainstCenterClockwise:
GlobalAngle:=GlobalAngle-2*(PI/180)
ButtonRotateEquationAgainstCenterCounterclockwise:
GlobalAngle:=GlobalAngle+(PI/180)
a:=Cos(GlobalAngle/2)
b:=GlobalRotationVectorX*Sin(GlobalAngle/2)
c:=GlobalRotationVectorY*Sin(GlobalAngle/2)
d:=GlobalRotationVectorZ*Sin(GlobalAngle/2)

GlobalQuaternaryRotationX:=((a**2)+(b**2)-(c**2)-(d**2))+2*((b*c)-(a*d))+2*((b*d)+(a*c))
GlobalQuaternaryRotationY:=2*((b*c)+(a*d))+((a**2)-(b**2)+(c**2)-(d**2))+2*((c*d)-(a*b))
GlobalQuaternaryRotationZ:=2*((b*d)-(a*c))+2*((c*d)+(a*b))+((a**2)-(b**2)-(c**2)+(d**2))

GlobalQuaternaryA:=newa
GlobalQuaternaryB:=newb
GlobalQuaternaryC:=newc
GlobalQuaternaryD:=newd

;ToolTip, % "(" . GlobalQuaternaryRotationX . "," . GlobalQuaternaryRotationY . "," . GlobalQuaternaryRotationZ . ")"
ToolTip, % "Rotated 3D equation " . GlobalAngle*(180/PI) . " degrees along vector: <" . GlobalRotationVectorX . "," . GlobalRotationVectorY . "," . GlobalRotationVectorZ . . "," . GlobalRotationVectorW ">"
SetTimer, RemoveToolTip, 5000
Return

ButtonSetRotationVector:
GlobalRotationVectorX:=GlobalEquationX
GlobalRotationVectorY:=GlobalEquationY
GlobalRotationVectorZ:=GlobalEquationZ
GlobalRotationVectorW:=GlobalEquationW
ToolTip, % "Set rotation vector from center to: <" . GlobalRotationVectorX . "," . GlobalRotationVectorY . "," . GlobalRotationVectorZ . "," . GlobalRotationVectorW ">"
SetTimer, RemoveToolTip, 5000
Return

ButtonSetRotationVectorOpposite:
GlobalRotationVectorX:=-GlobalEquationX
GlobalRotationVectorY:=-GlobalEquationY
GlobalRotationVectorZ:=-GlobalEquationZ
GlobalRotationVectorW:=-GlobalEquationW
ToolTip, % "Set rotation vector from center to: <" . GlobalRotationVectorX . "," . GlobalRotationVectorY . "," . GlobalRotationVectorZ . "," . GlobalRotationVectorW ">"
SetTimer, RemoveToolTip, 5000
Return

ButtonPrevEquation:
    Equation:=Equation-1
    EquationDelta:=-1
Goto SwapEquations
ButtonNextEquation:
    Equation:=Equation+1
    EquationDelta:=1
SwapEquations:
If ((Equation>=0) and (IsFunc("Equation" . Equation) and IsFunc("Equation" . Equation . "Inv")))
{
    ToolTip, % "Swapped to equation: " . Equation%Equation%Name
    SetTimer, RemoveToolTip, 5000
    Return
}
ToolTip, % "Equation with ID '" . Equation . "' doesn't exist."
Equation:=Equation+EquationDelta*-1
SetTimer, RemoveToolTip, 5000
Return

RemoveToolTip:
SetTimer, RemoveToolTip, Off
ToolTip
Return
