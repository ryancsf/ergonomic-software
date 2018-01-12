#MaxHotkeysPerInterval 200

Capslock::Backspace
+RButton::Send, ^w
+WheelUp::Send, ^+{TAB}
+WheelDown::Send, ^{TAB}

;; For Pen Mouse

;; For YumQua
RButton::MButton

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;		Logitech T650 mappings for Windows 7.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; 3 finger swipe down --> Task View	
;;<#d::
;;	Send, ^w
;;	Return

;; 4 finger swipe right left only becomes tabs when numpad is OFF
;; 4 finger swipe down
;; <#NumpadUp::
;;	Send, {LWin down}{Tab down}{LWin up}{Tab up}
;;	Return

;; Wheel Scroll Tabs for Google Chrome

;; For Ace Jump Shortcut
Ins:: Send, ^+{PgDn}

;; Disable lctrl
F1::Send, #1
F2::Send, #2
F3::Send, ^{a}
F4::Send, ^{s}
F6::Send, ^!{g}
F7::Send, ^t


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