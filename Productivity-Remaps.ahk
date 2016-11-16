Capslock::Backspace
Rwin::LShift

WheelLeft::
    if(  not GetKeyState("WheelLeft")  )
        sleep 200

    Send, {Browser_Back}
return

WheelRight::
    if(  not GetKeyState("WheelRight")  )
        sleep 200

    Send, {Browser_Forward}
return

XButton1::^w

<+WheelUp::Send, ^+{TAB}
<+WheelDown::Send, ^{TAB}

;; Wheel Scroll Tabs for Google Chrome

#IfWinActive ahk_class Chrome_WidgetWin_1
 ~$WheelDown::
 ~$WheelUp::
    MouseGetPos,, yaxis
    IfGreater,yaxis,23, Return
    IfEqual,A_ThisHotkey,~$WheelDown, Send ^{PgDn}
                                 Else Send ^{PgUp}
Return
#IfWinActive
