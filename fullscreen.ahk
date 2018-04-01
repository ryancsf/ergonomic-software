#SingleInstance, Force
#NoTrayIcon
SetTitleMatchMode, 2

Run, "C:\Program Files\Microsoft VS Code\Code.exe"

#IfWinActive Code
    sleep 2000
    Send, {F11}
#IfWinActive

ExitApp