#SingleInstance Force
#Persistent
#UseHook
#NoEnv
ListLines Off ; Displays the script lines most recently executed.
SetBatchLines -1 ; Determines how fast a script will run (affects CPU utilization).
#MaxHotkeysPerInterval 100
DetectHiddenWindows, On
CoordMode, Mouse, Screen
SendMode Input
SetTitleMatchMode, 2
SetWorkingDir %A_ScriptDir%
SetWinDelay, 0

global APP_NAME, global APP_SELECTOR, global APP_RUN

Menu, Tray, Icon, %APP_NAME%.png
Menu, Tray, Click, 1
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
        if (!APP_RUN) {
            MsgBox, Please launch %APP_NAME%
            return
        }
        if (App.counter > 0) {
            App.counter -= 1
            return
        }
        App.counter := 3
        App.init := true
        Run, %APP_RUN%
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

OnExit("ExitFunc")
ExitFunc(ExitReason, ExitCode) {
    if (App.TO_TRAY) {
        WinRestore, %APP_SELECTOR%
    }
    Sleep, 100
}