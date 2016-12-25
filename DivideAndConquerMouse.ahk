;
; AutoHotkey Version: 1.x
; Language:       English
; Platform:       Win9x/NT
; Author:         Petr 'Vorkronor' Stedry (petr.stedry@gmail.com)
; Based upon the 'Mouser' AutoHotkey script by Adam Pash <adam.pash@gmail.com>
;
#SingleInstance,Force 
SetWinDelay,0 

; file name of the configuration file
iniFile = dnc.ini

; initialize the configuration file
Gosub,INI
; generate tray menu
Gosub,TRAYMENU

; why does he just reassign the variables? just to show what are there? strange ... 

; are the overlays enabled?
overlayEnabled := overlayEnabled
; ?? color of the overlays ??
color := Ceil(color)
; degree of transparency of the overlay
transparency := transparency

; CTRL + Enter shortcut clicks ???
^+Enter::
Click
return

START:
; set the mouse mode to work with the whole screen
CoordMode, Mouse, Screen
; store the current mouse position
MouseGetPos, currentMouseX, currentMouseY

; get the monitor resolution
; TODO - repair to work with a multi monitor setup ... by selecting the monitor in the first step?
SysGet, resolution, Monitor

; what to keep track of

; last selected sector
lastSector := 0	

; sector top left corner, width and height
; we default to the whole screen as a sector
sectorTopX := 0
sectorTopY := 0
sectorWidth := resolutionRight
sectorHeight := resolutionBottom

; compute max depth
MAX_DEPTH := calculateMaxDepth(resolutionBottom)
; the depth we're at (0 = desktop, 1 = first sectors covered)
depth := 0

; draw the initial grid
if overlayEnabled {
	GoSub, DrawGrid
}

/*
	What to do in the main loop?
	
	1) get user input
	2) determine what sectors is selected
	3) move the mouse to the new position
	4) draw the new grid
*/
Loop {
	; all ends in the maximum depth
	if (depth >= MAX_DEPTH) {
		; destroy all gui windows
		GoSub, CleanUpGui
		; end the main loop
		break
	}

	; get the mouse position
	MouseGetPos, currentMouseX, currentMouseY

	; get user input, but
	; wait up to 5 seconds (T5) for 1 character (L1) of input and terminate if Escape, NumpadEnter or NumpadInsert occur
	; (all numpad) Left, Right, Up, Down and diagonals are normal sector selectors
	Input, userInput, T5 L1, {NumpadEnter}{Escape}, 0,1,2,3,4,5,6,7,8,9

	; we wait until the user decides to press any key
	if ErrorLevel = Timeout
		continue
	
	; handle keypresses, that terminate further execution (clicks and quit actions)
	if userInput = 0
		; left click
		Gosub,ClickLeft

	IfInString, ErrorLevel, EndKey:NumpadEnter
		; right click
		Gosub,ClickRight

	IfInString, ErrorLevel, EndKey:Escape
		; exit the script
		Gosub,Quit
	
	; handle the valid keypresses
	; default for the last sector is 0
	lastSector := 0
	; determine what sector was selected
	if userInput in 1,2,3,4,5,6,7,8,9
		lastSector := userInput

	; update the new sector size (it's one third of what it was) ... easy ;)
	sectorWidth := Floor(sectorWidth/3)
	sectorHeight := Floor(sectorHeight/3)
	
	; update sector top left corner location
	if userInput in 2,5,8
		sectorTopX := sectorTopX + sectorWidth
	if userInput in 3,6,9
		sectorTopX := sectorTopX + (2*sectorWidth)

	if userInput in 1,2,3
		sectorTopY := sectorTopY + (2*sectorHeight)
	if userInput in 4,5,6
		sectorTopY := sectorTopY + sectorHeight
	
	; move the mouse to the new sector center
	newX := sectorTopX + Floor(sectorWidth/2)
	newY := sectorTopY + Floor(sectorHeight/2)

	; if the user selected a sector, do the strange movements ;)
	if (lastSector != 0) {
		MouseMove, %newX%, %newY%
		; if the overlay is enabled, draw the crosshairs
		if overlayEnabled {
			GoSub, DrawGrid
		}

		; increase the depth
		depth := depth + 1
	}
	
	if ErrorLevel = Max { }

	if ErrorLevel = NewInput
		return
}
return

calculateMaxDepth(screenSize) {
	tmpHeight := screenSize
	; get the size of the grid
	Loop {
		tmpHeight := tmpHeight / 3

		if (tmpHeight <= 3) {
			return %A_Index%
		}
	}
}

DrawGrid:
	; draw the bounding box
	; top line
	drawRect(sectorTopX, sectorTopY, sectorWidth, 1, 1)
	; right line
	drawRect(sectorTopX + sectorWidth - 1, sectorTopY, 1, sectorHeight, 2)
	; bottom line
	drawRect(sectorTopX, sectorTopY + sectorHeight - 1, sectorWidth, 1, 3)
	; left line
	drawRect(sectorTopX, sectorTopY, 1, sectorHeight, 4)

	; inner lines - horizontal
	drawRect(sectorTopX, sectorTopY + Floor(sectorHeight/3), sectorWidth, 1, 5)
	drawRect(sectorTopX, sectorTopY + Ceil(2 * (sectorHeight/3)), sectorWidth, 1, 6)
	
	; inner lines - vertical
	drawRect(sectorTopX + Floor(sectorWidth/3), sectorTopY, 1, sectorHeight, 7)
	drawRect(sectorTopX + Ceil(2 * (sectorWidth/3)), sectorTopY, 1, sectorHeight, 8)
return

drawRect(x, y, width, height, winNo) {
	Gui, %winNo%: +AlwaysOnTop -Caption +LastFound +ToolWindow
	Gui, %winNo%: Color, 666666
	WinSet, TransColor, %color% %transparency%
	Gui, %winNo%: Show, x%x% y%y% w%width% h%height% noactivate
}

; erases the 'crosshair'
CleanUpGui:
	Gui,1: Destroy
	Gui,2: Destroy
	Gui,3: Destroy
	Gui,4: Destroy
	Gui,5: Destroy
	Gui,6: Destroy
	Gui,7: Destroy
	Gui,8: Destroy
return

; exit the current session
Quit:
	if (overlayEnabled) {
		; destroy all gui windows
		GoSub, CleanUpGui
	}
	exit
return

ClickLeft:
	if (overlayEnabled) {
		; destroy all gui windows
		GoSub, CleanUpGui
	}
	click
	exit
return

ClickRight:
	if (overlayEnabled) {
		; destroy all gui windows
		GoSub, CleanUpGui
	}
	Click right
	exit
return

; reads/initializes the configuration file
INI:
	IfNotExist,%iniFile%
	{
		; write the defaults to the configuration file
		IniWrite,^NumpadMult,%iniFile%,Settings,hotkey
		IniWrite,1,%iniFile%,Settings,overlayEnabled
		IniWrite,FF3333,%iniFile%,Settings,color
		IniWrite,70,%iniFile%,Settings,transparency
	}
	; read the configuration
	IniRead,hotkey,%iniFile%,Settings,hotkey
	IniRead,overlayEnabled,%iniFile%,Settings,overlayEnabled
	IniRead,color,%iniFile%,Settings,color
	IniRead,transparency,%iniFile%,Settings,transparency
	HotKey,%hotkey%,START
return

; generate the tray menu
TRAYMENU:
	Menu,Tray,NoStandard 
	Menu,Tray,DeleteAll 
	Menu,Tray,Add,DnC,ABOUT
	Menu,Tray,Add,
	Menu,Tray,Add,&Settings...,SETTINGS
	Menu,Tray,Add,&About...,ABOUT
	Menu,Tray,Add,E&xit,EXIT
	Menu,Tray,Default,DnC
	Menu,Tray,Tip,Divide and Conquer
return

; opens the Settings window
SETTINGS:
	HotKey,%hotkey%,Off
	Gui,9: Destroy
	Gui,9: Add,GroupBox,xm ym w400 h70,&Hotkey
	Gui,9: Add,Hotkey,xp+10 yp+20 w380 vshotkey
	StringReplace,current,hotkey,+,Shift +%A_Space%
	StringReplace,current,current,^,Ctrl +%A_Space%
	StringReplace,current,current,!,Alt +%A_Space%
	Gui,9: Add, Text,,Current hotkey: %current%
	Gui,9: Add, Checkbox, xp yp+32 vsvisualizations_cbox Checked%overlayEnabled%, Show targeting grid
	Gui,9: Add, GroupBox, xm y+10 w400 h55,&Grid transparency (0 to 250; default:70; currently:%transparency%):
	Gui,9: Add, Slider, xp+10 yp+20 w380 vstransparency Range0-250 ToolTipRight TickInterval25, %transparency%
	Gui,9: Add, Button, xm y+30 w75 GSETTINGSOK,&OK
	Gui,9: Add, Button, x+5 w75 GSETTINGSCANCEL,&Cancel
	Gui,9: Show,,Mouser Settings
return

; processes the OK button on the Settings page
SETTINGSOK:
	Gui,9: Submit
	If shotkey<>
	{
	  hotkey:=shotkey
	  HotKey,%hotkey%,START
	}
	HotKey,%hotkey%,On
	If stransparency<>
	  transparency:=stransparency
	if svisualizations_cbox<>
	  overlayEnabled := svisualizations_cbox
	IniWrite,%hotkey%,%iniFile%,Settings,hotkey
	IniWrite,%overlayEnabled%,%iniFile%,Settings,overlayEnabled
	IniWrite,%transparency%,%iniFile%,Settings,transparency
	IniWrite,%checkbox%, %iniFile%, Settings,checkbox
	Gui,9: Destroy
	
	if (!overlayEnabled) {
		; destroy all gui windows
		GoSub, CleanUpGui
	}
return

; processes the CANCEL button on the Settings page
SETTINGSCANCEL:
	HotKey,%hotkey%,START,On
	HotKey,%hotkey%,On
	Gui,9: Destroy
return


ABOUT:
	Gui,Destroy
	Gui,Font,Bold,Lucida Console
	Gui,Add,Text,,DnC (Divide and Conquer)
	Gui,Font,Norm Italic
	Gui,Add,Text,xm,mouse replacement utility
	Gui,Font,Norm
	Gui,Add,Text,xm yp+25,Press Ctrl+* to start. Escape to exit.
	Gui,Add,Text,xm,Numbers (1-9) select the sector in the grid.
	Gui,Add,Text,xm,Right click the tray icon to change settings.
	Gui,Add,Text,xm yp+25,Created using
	Gui,Font,underline
	Gui,Add,Text,xp+97 yp cBlue gAutohotkeyHome,AutoHotkey
	Gui,Font,norm
	Gui,Add,Text,xm yp+25,Inspired by
	Gui,Font,underline
	Gui,Add,Text,xp+83 cBlue gMouserHome,'Mouser' by Adam Pash
	Gui,Show,,About DnC
return

; used to close the about window
GuiEscape:
	Gui,Destroy
return

; launches the AutoHotkey homepage in the default browser
AutohotkeyHome:
	run http://www.autohotkey.com
return

; launches the Mouser lifehacker post in the default browser
MouserHome:
	run http://lifehacker.com/software/mouser/hack-attack-operate-your-mouse-with-your-keyboard-212816.php
return

EXIT:
	ExitApp
