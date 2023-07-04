#SingleInstance Force
#Persistent
#UseHook
#NoEnv
ListLines Off ; Displays the script lines most recently executed.
SetBatchLines -1 ; Determines how fast a script will run (affects CPU utilization).
#MaxHotkeysPerInterval 800
DetectHiddenWindows, On
CoordMode, Mouse, Screen
SendMode Input
SetTitleMatchMode, 2
SetWorkingDir %A_ScriptDir%
SetWinDelay, 0

OnExit("ExitFunc")

Menu, Tray, Icon, clockify.png
Menu, Tray, Click, 1
; Menu, Tray, NoStandard
Menu, Tray, Add, Open Clockify, Clockify.toggle
Menu, Tray, Default, Open Clockify

class Clockify {
    
    static TO_TRAY := false
    
    static running := False
    static counter := 0
    static last_title := ""
    
    static init := True
    
    open() {
        WinRestore, Clockify ahk_class Chrome_WidgetWin_1 ahk_exe brave.exe
        if (Clockify.TO_TRAY) {
            WinShow, Clockify ahk_class Chrome_WidgetWin_1 ahk_exe brave.exe
        }
        WinActivate, Clockify ahk_class Chrome_WidgetWin_1 ahk_exe brave.exe
    }
    
    close() {
        WinMinimize, Clockify ahk_class Chrome_WidgetWin_1 ahk_exe brave.exe
        if (Clockify.TO_TRAY) {
            WinHide, Clockify ahk_class Chrome_WidgetWin_1 ahk_exe brave.exe
        }
    }
    
    toggle() {
        WinGet, hwnd, ID, Clockify ahk_class Chrome_WidgetWin_1 ahk_exe brave.exe
        if (hwnd == "") {
            return Clockify.launch()
        }
        
        WinGet WinState, MinMax, Clockify ahk_class Chrome_WidgetWin_1 ahk_exe brave.exe
        if (WinState == -1) {
            Clockify.open()
        } else {
            Clockify.close()
        }
    }
    
    launch() {
        if (Clockify.counter > 0) {
            Clockify.counter -= 1
            return
        }
        Clockify.counter := 3
        Clockify.init := true
        Run, "C:\Program Files\BraveSoftware\Brave-Browser\Application\chrome_proxy.exe"  --profile-directory=Default --app-id=lajdaimcbbobmkjbgilfjekkpnhmekoi
        if (Clockify.init) {
            Clockify.init := false
            WinWait, Clockify
            Sleep, 1000
            Clockify.toggle()
        }
    }
    
    update() {
        WinGet, hwnd, ID, Clockify ahk_class Chrome_WidgetWin_1 ahk_exe brave.exe
        if (hwnd == "") {
            return Clockify.launch()
        }
        
        WinGetTitle, t, Clockify ahk_class Chrome_WidgetWin_1 ahk_exe brave.exe
        
        active := RegExMatch(t, ".*[0-9].*") != 0
        
        if (active) {
            if (!Clockify.running) {
                Clockify.running := true
                Menu, Tray, Icon, clockify_on.png
            }
        } else {
            if (Clockify.running) {
                Clockify.running := false
                Menu, Tray, Icon, clockify.png
            }
        }
        
        if (t != Clockify.last_title) {
            Menu, Tray, Tip , %t%
            Clockify.last_title := t
        }
        
        if (Clockify.TO_TRAY) {
            WinGet WinState, MinMax, Clockify ahk_class Chrome_WidgetWin_1 ahk_exe brave.exe
            if (WinState == -1) {
                WinHide, Clockify ahk_class Chrome_WidgetWin_1 ahk_exe brave.exe
            }
        }
    }
    
}

Clockify.update()

SetTimer, timer, 1000
timer() {
    global Clockify
    Clockify.update()
}

~!^+r::
    SetTimer, timer, 99999999
    
    WinGet, WinState, MinMax, Clockify ahk_class Chrome_WidgetWin_1 ahk_exe brave.exe
    if (WinState == -1) {
        WinRestore, Clockify ahk_class Chrome_WidgetWin_1 ahk_exe brave.exe
        Sleep, 100
        WinMinimize, Clockify ahk_class Chrome_WidgetWin_1 ahk_exe brave.exe
    }
    if (Clockify.TO_TRAY) {
        WinShow, Clockify ahk_class Chrome_WidgetWin_1 ahk_exe brave.exe
    }
    Reload
Return


ExitFunc(ExitReason, ExitCode) {
    if (Clockify.TO_TRAY) {
        WinRestore, Clockify ahk_class Chrome_WidgetWin_1 ahk_exe brave.exe
    }
    Sleep, 100
}

#if !GetKeyState("CapsLock", "P") and WinActive("Clockify ahk_class Chrome_WidgetWin_1 ahk_exe brave.exe")
    ; ^W::Clockify.close()
    
#IfWinActive