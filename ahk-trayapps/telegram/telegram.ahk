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

APP_NAME     := "Telegram"
APP_SELECTOR := "Telegram ahk_class Chrome_WidgetWin_1 ahk_exe brave.exe"

global APP_NAME, global APP_SELECTOR

Menu, Tray, Icon, %APP_NAME%.png
Menu, Tray, Click, 1
; Menu, Tray, NoStandard
Menu, Tray, Add, Open %APP_NAME%, App.toggle
Menu, Tray, Default, Open %APP_NAME%

class App {
    
    static TO_TRAY := true
    
    static running := False
    static counter := 0
    static last_title := ""
    
    static init := True
    
    open() {
        WinRestore, %APP_SELECTOR%
        if (App.TO_TRAY) {
            WinShow, %APP_SELECTOR%
        }
        WinActivate, %APP_SELECTOR%
    }
    
    close() {
        WinMinimize, %APP_SELECTOR%
        if (App.TO_TRAY) {
            WinHide, %APP_SELECTOR%
        }
    }
    
    toggle() {
        WinGet, hwnd, ID, %APP_SELECTOR%
        if (hwnd == "") {
            return App.launch()
        }
        
        WinGet WinState, MinMax, %APP_SELECTOR%
        if (WinState == -1) {
            App.open()
        } else {
            App.close()
        }
    }
    
    launch() {
        if (App.counter > 0) {
            App.counter -= 1
            return
        }
        App.counter := 3
        App.init := true
        Run, "C:\Program Files\BraveSoftware\Brave-Browser\Application\chrome_proxy.exe"  --profile-directory=Default --app-id=ibblmnobmgdmpoeblocemifbpglakpoi
        if (App.init) {
            App.init := false
            WinWait, App
            Sleep, 1000
            App.toggle()
        }
    }
    
    update() {
        WinGet, hwnd, ID, %APP_SELECTOR%
        if (hwnd == "") {
            return App.launch()
        }
        
        WinGetTitle, t, %APP_SELECTOR%
        
        active := RegExMatch(t, ".*[0-9].*") != 0
        asd := App.running
        
        if (active) {
            if (!App.running) {
                App.running := true
                Menu, Tray, Icon, %APP_NAME%_on.png
            }
        } else {
            if (App.running) {
                App.running := false
                Menu, Tray, Icon, %APP_NAME%.png
            }
        }
        
        if (t != App.last_title) {
            Menu, Tray, Tip , %t%
            App.last_title := t
        }
        
        if (App.TO_TRAY) {
            WinGet WinState, MinMax, %APP_SELECTOR%
            if (WinState == -1) {
                WinHide, %APP_SELECTOR%
            }
        }
    }
    
}

App.update()

SetTimer, timer, 1000
timer() {
    global App
    App.update()
}

~!^+r::
    SetTimer, timer, 99999999
    
    WinGet, WinState, MinMax, %APP_SELECTOR%
    if (WinState == -1) {
        WinRestore, %APP_SELECTOR%
        Sleep, 100
        WinMinimize, %APP_SELECTOR%
    }
    if (App.TO_TRAY) {
        WinShow, %APP_SELECTOR%
    }
    Reload
Return


ExitFunc(ExitReason, ExitCode) {
    if (App.TO_TRAY) {
        WinRestore, %APP_SELECTOR%
    }
    Sleep, 100
}

#if !GetKeyState("CapsLock", "P") and WinActive("%APP_SELECTOR%")
    ; ^W::Clockify.close()
    
#IfWinActive