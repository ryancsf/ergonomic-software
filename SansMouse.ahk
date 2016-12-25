;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; File: SansMouse.ahk
; Original Author: Shane Norris
; Description:  AutoHotKey script to act as a mouse replacement using the configured keys to
;               make alternating column and row selections in order to narrow in on target.
; Requirements: AutoHotKey version 1.0.47.01 or later, tested on Windows XP Tablet Edition SP2
; History:
;          Monday 16 July 2007 4:45AM Initial version completed.
;                              5:30PM Set Esc to call ResetSelection.
;                                     Moved ResetSelection from OnActivateKey to _RunOnce so last
;                                     selection is retained between activations.
;                 17 July 2007 11:45AM Added OnCommandKey() for keys that do a definate action that
;                                      should deactivate script afterwards such as double click.
;                                      Added a new key ';' to single click then call OnCommandKey().
;                                      Added OnLeftDown/Up(), OnRightDown/Up() so that when toggling
;                                      the held down position can be resumed when reactivated.
;                 17 July 2007 12:45PM Added OnLeft/RightToggle() and rmapped LALT to use OnLeftToggle()
;                                      Also another key '"' for single right click followed by OnCommandKey().
;                               3:00PM Added shift modifiers to mouse buttons so they stay open
;                               5:55PM Added lines to labels of to the side when the selection area is to
;                                      small for drawing directly inside.
;                              11:30PM Redesigned the DrawLabels method, line drawing has been removed for
;                                      the time being - thinking its time to move to C++ if I want to do
;                                      anything other than tweaks in the future!
;                 18 July 2007  8:10AM One last change to re add the line drawing then its code freeze time!
;                              11:10AM CODE FREEZE!!!!! ok lines are added, all the constants needed for
;                                      tweeking are up the top and most of the curft is gone so unless
;                                      something happens to be broken I am done here.

; Constants
k_StartMode := "ltr" ; option is "ltr" or "ttb" selection first
k_TransColor := 0x000099FF ; used for background transparency color - only needs changing if it clashes below
k_PaintBehindKeys := "true"
k_BehindKeysColor := 0x00000001 ; used to paint behind, all zero doesn't work
k_GridColor := 0x00FF0000 ; color of grid outlines specified as Ox00BBGGRR
k_KeysColor := 0x000000FF ; color of key labels specified using blue, green, red as above
k_LinesColor := 0x00000001 ; lines between labels and grid
k_Divisions := 26 ; number of columns and rows screen is divided into during subsequent selections
k_FullDivisions := 26 ; number of division lines to draw on normal grid
k_SmallDivisions := 1 ; number of divisions to show on small grid
k_KeyLabels := "ABCDEFGHIJKLMNOPQRSTUVWXYZ" ; character label for each column/row in order

; jump to the _RunOnce sub to initialize display count and setup overlay window - anything that happens
; before a key is pressed is triggered from there.
GoSub _RunOnce

;Register activate / deactivate hotkeys
~CapsLock UP::
    GetKeyState, CapsState, CapsLock, T
    if CapsState = D
       OnActivateKey()
    else
        OnDeactivateKey()
    return

;Register interaction keys
#IfWinExist overlay_window_title
; started with homkeys below which is a little more intuative but prefer the speed of using all 26
;a::ResizeSelection(0)
;s::ResizeSelection(1)
;d::ResizeSelection(2)
;f::ResizeSelection(3)
;g::ResizeSelection(4)
;h::ResizeSelection(5)
;j::ResizeSelection(6)
;k::ResizeSelection(7)
;l::ResizeSelection(8)
;`;::ResizeSelection(9)

; full alphabet mapping gets close enough to click after the first iteration through columns and rows
a::ResizeSelection(0)
b::ResizeSelection(1)
c::ResizeSelection(2)
d::ResizeSelection(3)
e::ResizeSelection(4)
f::ResizeSelection(5)
g::ResizeSelection(6)
h::ResizeSelection(7)
i::ResizeSelection(8)
j::ResizeSelection(9)
k::ResizeSelection(10)
l::ResizeSelection(11)
m::ResizeSelection(12)
n::ResizeSelection(13)
o::ResizeSelection(14)
p::ResizeSelection(15)
q::ResizeSelection(16)
r::ResizeSelection(17)
s::ResizeSelection(18)
t::ResizeSelection(19)
u::ResizeSelection(20)
v::ResizeSelection(21)
w::ResizeSelection(22)
x::ResizeSelection(23)
y::ResizeSelection(24)
z::ResizeSelection(25)

ESC::ResetSelection() ; Reset the selection back to full screen
BACKSPACE::BackPedal() ; BackPedal a single selection
Space::ToggleMode() ; Toggle between row and column selection
F1::ShowHelp() ; Show a help message - remember to update with any key mapping changes!
;LAlt::OnLeftDown() ; Left mouse button down
;LAlt UP::OnLeftUp() ; Left mouse button up
LAlt::OnLeftToggle() ; Should make dragging more managable
;RAlt::OnRightDown() ; Right mouse button down
;RAlt UP::OnRightUp() ; Right mouse button up
RALT::OnRightToggle() ; individual clicks may infact be better but for now I want symetry with left
TAB::NextDisplay() ; Cycle through detected displays, one per press.
+SC028:: ; (; scan code)Right click then disable SansMouse
    Click right
    OnCommandKey()
    return
+SC027:: ; (' scan code)Single left click then disable SansMouse
    Click
    OnCommandKey()
    return
+ENTER:: ; Double left click then disable SansMouse
    Click 2
    OnCommandKey()
    return
SC028::Click right
SC027::Click
ENTER::Click 2
#IfWinExist

; _RunOnce - as name suggests is run once at script startup
_RunOnce:
    FindDisplays()
    SetupOverlay()
    FirstDisplay()
    ResetSelection()
    ;ShowHelp()
    return

; ShowHelp - called at startup from _RunOnce then any time from hotkey
ShowHelp()
{
    msg =
    ( Ltrim
        Toggle between SansMouse and normal keyboard mode use the CAPSLOCK.
        Choose target columns and rows with the indicated keyboard characters in SansMouse mode.
        Swap between column and row selection mode use SPACE bar.
        To back a step in the selection use BACKSPACE.
        To back up to the first selection step use ESC.
        The `;,`', ENTER keys perform click, right click and double click respectivly.
        If you hold down a SHIFT key while pressing either of the above three keys then SansMouse will return you to keyboard mode after the action.
        LEFT and RIGHT ALT keys toggle there respective mouse keys up and down.
        If you have multiple monitors the TAB key cycles through them.
        To view this help message again press the F1 key while SansMouse is activated.
        `n`tGood luck and enjoy
        `t`t-regards Shane Norris
        `t`tdoctus@gmail.com
    )
    MsgBox, %msg%
}
; FindDisplays - called once from _RunOnce sub to enumerate the displays on the system
FindDisplays()
{
    global g_DisplayCount := 0
    callback := RegisterCallback("_MonitorCallbackProc","", 4)
    DllCall("EnumDisplayMonitors", "UInt", 0, "UInt", 0, "UInt", callback, "UInt", 0)
}

; _MonitorCallbackProc - registered by FindDisplays() to enumerate each display on the sytem
_MonitorCallbackProc(p_hMonitor, p_hdcMonitor, p_lprcMonitor, p_dwData)
{
    global

    g_DisplayCount ++

    VarSetCapacity(info, 40) ; sizeof(MONITORINFO) == 40 according to visual studio
    NumPut(40, info, 0, "Int") ; set cbSize
    DllCall("GetMonitorInfo", "UInt", p_hMonitor, "UInt", &info)
    g_Display%g_DisplayCount%_X := NumGet(&info, 4, "Int")
    g_Display%g_DisplayCount%_Y := NumGet(&info, 8, "Int")
    g_Display%g_DisplayCount%_Width := NumGet(&info, 12, "Int") - g_Display%g_DisplayCount%_X
    g_Display%g_DisplayCount%_Height := NumGet(&info, 16, "Int") - g_Display%g_DisplayCount%_Y
    info := "" ; lets just pretend this variable didn't polute global namespace
    return 1
}
; SetupOverlay - from _RunOnce to initialize the overlay window (same window does all screens)
SetupOverlay()
{
    global g_hWnd
    global k_TransColor
    Gui, +LastFound +ToolWindow -Caption +AlwaysOnTop
    Gui, Color, k_TransColor
    WinSet, TransColor, k_TransColor
    WM_PAINT := 0xF
    OnMessage(WM_PAINT, "OnPaint")
    Gui, Show, H1 W1 X-1 Y-1 NoActivate , temporary_title
    WinGet, g_hWnd, id, temporary_title
}
; FirstDisplay - called from _RunOnce to setup the variables in the display list.
FirstDisplay()
{
    global
    g_CurrentDisplay := 1
    g_DisplayX := g_Display1_X
    g_DisplayY := g_Display1_Y
    g_DisplayHeight := g_Display1_Height
    g_DisplayWidth := g_Display1_Width
    ;ResetSelection()
    ;ShowOverlay()
}
; OnActivateKey - called from hotkey, calls SetupOverlay() to create new Gui which then enables all the
;                 hotkeys as a side effect since they rely on #IfWinExist
OnActivateKey()
{
    ; ResetSelection() removed so grid returns to previous location
    ShowOverlay()
    GoSub, _Topmost ; call once immediately so were not at the mercy of timer for debugging
    SetTimer, _Topmost, 200
}
; NextDisplay - called any time from hotkey to cycle the displays
NextDisplay()
{
    global
    g_CurrentDisplay++
    if % g_CurrentDisplay > g_DisplayCount
       g_CurrentDisplay := 1
    g_DisplayX := g_Display%g_CurrentDisplay%_X
    g_DisplayY := g_Display%g_CurrentDisplay%_Y
    g_DisplayHeight := g_Display%g_CurrentDisplay%_Height
    g_DisplayWidth := g_Display%g_CurrentDisplay%_Width
    ShowOverlay()
}
; ShowOverlay - makes the overlay visible on the current display, called from OnActivateKey() and NextDisplay()
ShowOverlay()
{
    global
    ; overlay_window_title below is important since all the hotkeys rely on that title to activate
    Gui, Show, X%g_DisplayX% Y%g_DisplayY% H%g_DisplayHeight% W%g_DisplayWidth% NoActivate, overlay_window_title
    ;ListVars
    ;Pause
    UpdateOverlay()
}
; _Topmost - timer callback registered in OnActivateKey and unregisted from OnDeactivateKey to make sure
;            the overlay allways remains topmost even when menus are displayed
_Topmost:
    Gui, +AlwaysOntop ; prevent popup menus from drawing ontop of overlay
    return

; OnDeactivateKey - Stops everything by making sure the Gui window no longer exists therby inhibiting keys
;                   called both from deactivate key and from OnCommandKey()
OnDeactivateKey()
{
    SetTimer, _Topmost, Off
    Gui, Show,  X-1 Y-1 W1 H1 NoActivate, not_the_overlay_window_title
}
; OnCommandKey - disables capslock, resets selection then calls OnDeactivateKey()
OnCommandKey()
{
    SetCapsLockState, Off
    ResetSelection()
    global g_LeftState := "up"  ; release mouse button states
    global g_RightState := "up"
    OnDeactivateKey() ; is it bad form to call one key handler from another? - probably should be factored out
    return
}
; ToggleMode - toggles between column and row selection mode, called both from hotkey and ResizeSelection()
ToggleMode()
{
    global
    if % g_Mode = "ltr" AND g_Height > 0
    {
       g_Mode := "ttb"
    }
    else if g_Width > 0
    {
        g_Mode := "ltr"
    }
    UpdateOverlay()
}
; OnLeftDown - does a left mouse down command as long as the button isn't allready down to allow SansMouse
;              active state to be toggled and then resume dragging.
OnLeftDown()
{
    global
    if % g_LeftState != "down"
    {
        g_LeftState := "down"
        Click down GetPointX() GetPointY()
    }
    return
}
; OnLeftUp - does a left mouse up command and updates the state flag to reflect this.
OnLeftUp()
{
    global
    if % g_LeftState != "up"
    {
        g_LeftState := "up"
        Click up GetPointX() GetPointY()
    }
    return
}
; OnLeftToggle - toggles between performing up and down presses each call
OnLeftToggle()
{
    global
    if % g_LeftState = "down"
    {
        g_LeftState := "up"
        click up GetPointX() GetPointY()
    }
    else ; note first call will be down if g_LeftState is undefined
    {
        g_LeftState := "down"
        click down GetPointX() GetPointY()
    }
}
; OnRightDown - does a right mouse down command as long as the button isn't allready down to allow SansMouse
;              active state to be toggled and then resume dragging.
OnRightDown()
{
    global
    if % g_RightState != "down"
    {
        g_RightState := "down"
        Click right down GetPointX() GetPointY()
    }
    return
}
; OnRightUp - does a right mouse up command and updates the state flag to reflect this.
OnRightUp()
{
    global
    if % g_RightState != "up"
    {
        g_RightState := "up"
        Click right up GetPointX() GetPointY()
    }
    return
}
; OnRightToggle - toggles between performing up and down presses each call - allthough theres usually
;                 no need for right dragging this is included for simetry
OnRightToggle()
{
    global
    if % g_RightState = "down"
    {
        g_RightState := "up"
        click right up GetPointX() GetPointY()
    }
    else ; note first call will be down if g_RightState is undefined
    {
        g_RightState := "down"
        click right down GetPointX() GetPointY()
    }
}
; GetPointX - Returns the X value at the center of the currently selected region in either "local" or
;             "desktop" modes.
;             Note: "desktop" is not currently used anywhere because AHK doesn't give any way to make
;             use of virtual desktop coordinates AHK desktop coordinates are only for the active display.
GetPointX(mode="local")
{
    global g_X
    global g_Width
    global g_DisplayX
    if % mode = "local"
       return g_X + g_Width / 2
    else
    {   ; desktop coordinates
        return (g_X + g_Width / 2.0) + g_DisplayX
    }
}
; GetPointY - Returns the Y value at the center of the currently selected region - See GetPointX for remarks
GetPointY(mode="local")
{
    global g_Y
    global g_Height
    global g_DisplayY
    if % mode = "local"
       return g_Y + g_Height / 2
    else
    {   ; desktop coordinates
        return (g_Y + g_Height / 2.0) + g_DisplayY
    }
}
; OnPaint - Updates the overlay onscreen by calling DrawGrid and DrawKeys
OnPaint(p_wParam, p_lParam, p_msg, p_hWnd)
{
    global k_GridColor
    global k_LinesColor
    global k_KeysColor
    global k_BehindKeysColor
    global k_PaintBehindKeys
    global k_TransColor
    global k_Divisions
    global k_Divisions

    global g_X
    global g_Y
    global g_Width
    global g_Height
    global g_hWnd ; ignore p_hWnd because sometimes we get the handle for the main window instead of Gui
    global g_Mode

    Gui, +AlwaysOntop
    PS_SOLID := 0
    VarSetCapacity(ps, 64) ; allocate 64 (checked on compiler) bytes for a PAINTSTRUCT returned from BeginPaint
    hDC := DllCall("BeginPaint", "UInt", g_hWnd, "UInt", &ps)
    hGridPen := DllCall("CreatePen", "UInt", PS_SOLID, "UInt", 1, "UInt", k_GridColor)
    hLinePen := DllCall("CreatePen", "UInt", PS_SOLID, "UInt", 1, "UInt", k_LinesColor)

    DllCall("SetTextColor", "UInt", hDC, "UInt", k_KeysColor)
    if % k_PaintBehindKeys != "true"
    {
        DllCall("SetBkMode", "UInt", hDC, "Int", 1) ; TRANSPARENT
    }
    else
    {
        DllCall("SetBkColor", "UInt", hDC, "UInt", k_BehindKeysColor)
    }

    ; Set a no draw region so the mouse clicks are passed to window underneath
    x := GetPointX("local")
    y := GetPointY("local")
    DllCall("ExcludeClipRect", "UInt", hDC, "Int", x - 2, "Int", y - 2, "Int", x + 2, "Int", y + 2)

    hOldPen := DllCall("SelectObject", "UInt", hDC, "UInt", hLinePen)

    DrawKeys(hDC, g_X, g_Y, g_Width, g_Height, g_Mode, LabelPosition())

    DllCall("SelectObject", "UInt", hDC, "UInt", hGridPen)

    DrawGrid(hDC, g_X, g_Y, g_Width, g_Height, ColumnDrawCount(), RowDrawCount()) ; draw last so is ontop of lines

    DllCall("SelectObject", "UInt", hDC, "UInt", hOldPen)
    DllCall("DeleteObject", "UInt", hGridPen)
    DllCall("DeleteObject", "UInt", hLinePen)
    DllCall("EndPaint", "UInt", g_hWnd, "UInt", &ps)
}
; LabelPosition - decides where abouts on the screen to draw the labels
LabelPosition()
{
    global
    k_FontHeight := 25
    k_FontWidth := 20
    if % g_Mode = "ttb"
    {
        if % g_Width > k_FontWidth AND g_Height > k_FontHeight * k_Divisions
            return "center"
        else if % (g_X + (g_Width / 2)) < (g_DisplayWidth / 2)
            return "right"
        else
            return "left"
    }
    else ; "ltr"
    {
        if % (g_Height > k_FontHeight) AND (g_Width > (k_FontWidth * k_Divisions))
            return "center"
        else if % (g_Y + (g_Height / 2)) > (g_DisplayHeight / 2)
            return "top"
        else
            return "bottom"
    }
}
ColumnDrawCount()
{
    global
    if % g_Mode = "ltr" AND g_Width > k_Divisions * 4
       return k_FullDivisions
    else if % g_Mode = "ttb"
        return 1
    return k_SmallDivisions
}
RowDrawCount()
{
    global
    if % g_Mode = "ttb" AND g_Height > k_Divisions * 4
       return k_FullDivisions
    else if % g_Mode = "ltr"
         return 1
    return k_SmallDivisions
}

; ResizeSelection - reduces the size and position of the current selection according to the passed in
;                   columnOrRow value, which is interpreted based on current value of g_Mode. Also
;                   creates Breadcrumb values to use in backtracking users actions.
ResizeSelection(p_columnOrRow) ; columnOrRow should be a zero based index
{
    global

    if % g_Mode = "ltr"
    {
        if % g_Width < 1 ; imprecisness to guard against float values
           return
        g_Breadcrumbs++
        g_Breadcrumb%g_Breadcrumbs%_Type := "ltr"
        g_Breadcrumb%g_Breadcrumbs%_Width := g_Width
        g_Breadcrumb%g_Breadcrumbs%_X := g_X

        g_Width /= k_Divisions + 0.0 ; force floating point math
        g_X += g_Width * p_columnOrRow
    }
    else ; g_SelectionMode = "ttb"
    {
        if % g_Height < 1
           return
        g_Breadcrumbs++
        g_Breadcrumb%g_Breadcrumbs%_Type := "ttb"
        g_Breadcrumb%g_Breadcrumbs%_Height := g_Height
        g_Breadcrumb%g_Breadcrumbs%_Y := g_Y

        g_Height /= k_Divisions + 0.0 ; force floating point math
        g_Y += g_Height * p_columnOrRow
    }
    ToggleMode()
}
; ResetSelection - resets the selected region to the full bounds of the currently active display.
ResetSelection()
{
    global
    g_Mode := k_StartMode
    g_X := 0
    g_Y := 0
    g_Width := g_DisplayWidth
    g_Height := g_DisplayHeight
    g_Breadcrumbs := 0
    ;ListVars
    ;Pause
    UpdateOverlay()
}
; UpdateOverlay - forces the overlay to be repainted by calling InvalidateRect() and sets the mouse curser
;                 to the center of the current selection.
UpdateOverlay()
{
    global g_hWnd
    ;WinActivate, ahk_pid%g_hWnd% ; make sure we have the rite one!
    DllCall("SetCursorPos", "Int", GetPointX("desktop"), "Int", GetPointY("desktop")) ; multiple monitor aware
    ;MouseMove, GetPointX("local"), GetPointY("local") ; "desktop" wont work because virtual destop coords arent recognized
    DllCall("InvalidateRect", "UInt", g_hWnd, "UInt", 0, "Int", 1)
    ;ListVars
    ;Pause
}
; BackPedal - backtracks the current selection region to the previous size, location and mode.
BackPedal()
{
    global
    if % g_Breadcrumbs = 0
       return
    if % g_Breadcrumb%g_Breadcrumbs%_Type = "ltr"
    {
        g_Width := g_Breadcrumb%g_Breadcrumbs%_Width
        g_X := g_Breadcrumb%g_Breadcrumbs%_X
    }
    else ; "ttb"
    {
        g_Height := g_Breadcrumb%g_Breadcrumbs%_Height
        g_Y := g_Breadcrumb%g_Breadcrumbs%_Y
    }
    g_Mode := g_Breadcrumb%g_Breadcrumbs%_Type
    g_Breadcrumbs --
    UpdateOverlay()
}
; Time for some refactoring, need to draw k * labels either ltr or ttb. Then theres the lines...
; previous - previous bounds
; deltas - values to add to previous bounds to get new bounds
; key - key to draw
_Next(  ByRef p_hDC, ByRef p_rect, p_key
        ,ByRef p_next_left, ByRef p_next_top, ByRef p_next_right, ByRef p_next_bottom
        ,ByRef p_next_x1, ByRef p_next_y1, ByRef p_next_x2, ByRef p_next_y2
        ,ByRef p_delta_left, ByRef p_delta_top, ByRef p_delta_right, ByRef p_delta_bottom
        ,ByRef p_delta_x1, ByRef p_delta_y1,ByRef p_delta_x2, ByRef p_delta_y2)
{
    global
    ;VarSetCapacity(rect, 16) ; set capacity outside so its not repeated
    NumPut( p_next_left, p_rect, 0, "Int") ;left
    NumPut( p_next_top, p_rect, 4, "Int") ;top
    NumPut( p_next_right, p_rect, 8, "Int") ;right
    NumPut( p_next_bottom, p_rect, 12, "Int") ;bottom
    DllCall("DrawText", "UInt", p_hDC, "UInt", &p_key, "Int", 1, "UInt", &p_rect, "UInt", 37) ;DT_VCENTER | DT_CENTER | DT_SINGLELINE = 37
    p_next_left += p_delta_left
    p_next_top += p_delta_top
    p_next_right += p_delta_right
    p_next_bottom += p_delta_bottom
    p_next_x1 += p_delta_x1
    p_next_y1 += p_delta_y1
    p_next_x2 += p_delta_x2
    p_next_y2 += p_delta_y2
}
; DrawLines - draws the connecting lines between the grid and labels off to the side
DrawLines(p_hDC, p_label_position
    ,p_grid_x, p_grid_y, p_grid_width, p_grid_height
    ,p_label_x, p_label_y, p_label_width, p_label_height)
{
    global k_Divisions

    if % p_label_position = "center"
       return

    delta_x1 := 0
    delta_y1 := 0
    delta_x2 := 0
    delta_y2 := 0
    next_x1 := 0
    next_y1 := 0
    next_x2 := 0
    next_y2 := 0

    if % p_label_position = "left" OR p_label_position = "right"
    {

        delta_y1 := p_label_height / k_Divisions
        delta_y2 := p_grid_height / k_Divisions
        next_y1 := p_label_y + delta_y1 / 2
        next_y2 := p_grid_y + delta_y2 / 2
        if % p_label_position = "left" ; p1 on right edge of label, left edge of grid
        {
            ; if right edge of label is after left edge of grid dont draw
            if % (p_label_x + p_label_width) > p_grid_x
                return
            next_x1 := p_label_x + p_label_width
            next_x2 := p_grid_x
        } else ; % p_label_position = "right" ; p1 on left edge of label, right edge of grid
        {
            ; if left edge of label is before left edge of grid dont draw
            if % p_label_x < (p_grid_x + p_grid_width)
                return
            next_x1 := p_label_x
            next_x2 := p_grid_x + p_grid_width
        }
    } else ; "top" or "bottom"
    {
        delta_x1 := p_label_width / k_Divisions
        delta_x2 := p_grid_width / k_Divisions
        next_x1 := p_label_x + delta_x1 / 2
        next_x2 := p_grid_x + delta_x2 / 2

        if % p_label_position = "top" ; point1 on bottom edge of label and 2 on top edge of grid
        {
            ; if the bottom of the label is below the top of the grid dont draw
            if % (p_label_y + p_label_height) > p_grid_y
               return
            next_y1 := p_label_y + p_label_height
            next_y2 := p_grid_y
        } else ; % p_label_position = "bottom" ; p1 on top edge of label, 2 on bottom edge of grid
        {
            ; if the top of the label is above the bottom of the grid dont draw lines
            if % p_label_y < (p_grid_y + p_grid_height)
                return
            next_y1 := p_label_y
            next_y2 := p_grid_y + p_grid_height
        }
    }

    loop % k_Divisions
    {
        DllCall("MoveToEx", "UInt", p_hDC, "Int", next_x1, "Int", next_y1, "UInt", 0)
        DllCall("LineTo", "UInt", p_hDC,"Int", next_x2, "Int", next_y2)
        next_x1 += delta_x1
        next_y1 += delta_y1
        next_x2 += delta_x2
        next_y2 += delta_y2
    }
}
; DrawKeys - draws a row of keys based on those provided in the k_KeyLabels string in either "horizontal"
;            or "vertical" direction (uses current GDI font).
DrawKeys(p_hDC, p_x, p_y, p_width, p_height, p_direction, p_position)
{
    global k_Divisions
    global k_KeyLabels
    global g_DisplayWidth
    global g_DisplayHeight

    delta_left := 0
    delta_top := 0
    delta_right := 0
    delta_bottom := 0

    x := p_x
    y := p_y
    height := p_height
    width := p_width

    if % p_direction = "ltr"
    {
        if % p_position = "top"
        {
            x := 0
            y /= 2
            height := g_DisplayHeight / k_Divisions
            width := g_DisplayWidth
        } else if % p_position = "bottom"
        {
            x := 0
            y := g_DisplayHeight - (g_DisplayHeight - y) / 2
            height := g_DisplayHeight / k_Divisions
            width := g_DisplayWidth
        }
        delta_left := width / k_Divisions
        delta_right := delta_left
        next_right := x + delta_right
        next_bottom := y + height
    } else if % p_direction = "ttb"
    {
        if % p_position = "left"
        {
            x := (x + width) / 2
            y := 0
            height := g_DisplayHeight
            width := g_DisplayWidth / k_Divisions
        } else if % p_position = "right"
        {
            x := g_DisplayWidth - (g_DisplayWidth - x) / 2
            y := 0
            height := g_DisplayHeight
            width := g_DisplayWidth / k_Divisions
        }
        delta_top := height / k_Divisions
        delta_bottom := delta_top
        next_right := x + width
        next_bottom := y + delta_bottom
    }
    next_top := y
    next_left := x

    VarSetCapacity(rect, 16)
    loop, PARSE, k_KeyLabels
    {
        _Next(p_hDC, rect, A_LoopField, next_left, next_top, next_right, next_bottom, next_x1, next_y1, next_x2, next_y2, delta_left, delta_top, delta_right, delta_bottom, delta_x1, delta_y1, delta_x2, delta_y2)
    }
    DrawLines(p_hDC, p_position, p_x, p_y, p_width, p_height, x, y, width, height)
    rect := ""
}
; DrawGrid - draws outline grid with the given number of columns and rows using the currently selected GDI pen
DrawGrid(p_hDC, p_x, p_y, p_width, p_height, p_columns, p_rows)
{
    global g_DisplayWidth ; need to make sure everything is drawnd inside screen
    global g_DisplayHeight

    p_width += 0.0 ; force floating point math
    p_height += 0.0
    columnWidth := p_width / p_columns ; - 1 so the last line falls inside visible region
    rowHeight := p_height / p_rows
    nPoints := (p_columns + 1 + p_rows + 1) * 2 ; 2 points per line

    VarSetCapacity(points, nPoints * 8) ; * 8 bytes per point

    cursorX := GetPointX() ; need to make sure nothing is drawn over this point
    cursorY := GetPointY()
    i = 0
    loop
    {
        if % i = (p_columns + 1)
           break
        arrayOffset := (i * 2) * 8
        x1Idx := arrayOffset
        y1Idx := x1Idx + 4
        x2Idx := y1Idx + 4
        y2Idx := x2Idx + 4

        x1 := p_x + (i * columnWidth)
        y1 := mod(i, 2) = 1 ? p_y : p_y + p_height ; alternate direction of lines
        x2 := x1
        y2 := mod(i, 2) = 1 ? p_y + p_height : p_y

        NumPut(x1, points, x1Idx, "Int")
        NumPut(y1, points, y1Idx, "Int")
        NumPut(x2, points, x2Idx, "Int")
        NumPut(y2, points, y2Idx, "Int")
        i++
    }
    columnsOffset := (p_columns + 1) * 2 * 8 ; offset in array to start of columns points
    i = 0
    loop
    {
        if % i = (p_rows + 1)
           break
        arrayOffset := columnsOffset + (i * 2) * 8
        x1Idx := arrayOffset
        y1Idx := x1Idx + 4
        x2Idx := y1Idx + 4
        y2Idx := x2Idx + 4

        x1 := mod(i, 2) = 1 ? p_x : p_x + p_width
        y1 := p_y + (i * rowHeight)
        x2 := mod(i, 2) = 1 ? p_x + p_width : p_x
        y2 := y1

        NumPut(x1, points, x1Idx, "Int")
        NumPut(y1, points, y1Idx, "Int")
        NumPut(x2, points, x2Idx, "Int")
        NumPut(y2, points, y2Idx, "Int")
        i++
    }
    DllCall("Polyline", "Uint", p_hDC, "UInt", &points, "Int", nPoints)
}