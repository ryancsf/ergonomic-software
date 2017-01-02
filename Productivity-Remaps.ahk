Capslock::Backspace
+RButton::Send, ^w
+WheelUp::Send, ^+{TAB}
+WheelDown::Send, ^{TAB}

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

;; Commented out until further use
;; RControl::Capslock
;; #If GetKeyState("CapsLock", "T")
;;  s::Home
;;  f::End
;;  e::PgUp
;;  d::PgDn
;;  i::Up
;;  k::Down
;;  j::Left
;;  l::Right
;; #If