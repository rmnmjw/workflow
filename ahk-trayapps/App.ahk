#SingleInstance Force
#Persistent
#UseHook
#NoEnv
ListLines Off ; Displays the script lines most recently executed.
DetectHiddenWindows, On
CoordMode, Mouse, Screen
SendMode Input
SetTitleMatchMode, 2
SetWorkingDir %A_ScriptDir%

SetBatchLines -1 ; Determines how fast a script will run (affects CPU utilization).
#MaxHotkeysPerInterval 800
SetWinDelay, 0

is_manual_launch := A_Args[1] == "--launch"

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
        App.launch_if_needed()
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
    
    launch_if_needed() {
        WinGet, hwnd, ID, %APP_SELECTOR%
        if (hwnd == "") {
            return App.launch()
        }
    }
    
    update() {
        WinGetTitle, t, %APP_SELECTOR%
        if (APP_NAME == "Spotify") {
            a := RegExMatch(t, ".*Webplayer.*")
            b := RegExMatch(t, ".* playlist by .*")
            c := RegExMatch(t, ".* Spotify$")
            ; ToolTip, %a% - %b% - %c%
            active := a == 0 && b == 0 && c == 0
        } else {
            active := RegExMatch(t, ".*[0-9].*") != 0
        }
        
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
        App.to_tray_if_needed()
    }
    
    to_tray_if_needed() {
        if (App.TO_TRAY) {
            WinGet WinState, MinMax, %APP_SELECTOR%
            if (WinState == -1) {
                WinHide, %APP_SELECTOR%
            }
        }
    }
    
}

App.update()
if (is_manual_launch) {
    App.open()
} else {
    App.to_tray_if_needed()
}

SetTimer, timer2, 5000
timer2() {
    Global App
    App.launch_if_needed()
}
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


#if !GetKeyState("CapsLock", "P") and WinActive(APP_SELECTOR)
    #Q::App.close()
    
    LButton::
        CoordMode, Mouse, Screen
        MouseGetPos, vPosX, vPosY, hWnd

        WinGetClass, vWinClass, ahk_id %hWnd%
        
        ; https://stackoverflow.com/questions/39882844/is-it-possible-to-catch-the-close-button-and-minimize-the-window-instead-autoho
        if vWinClass not in BaseBar,#32768,Shell_TrayWnd,WorkerW,Progman,DV2ControlHost
        {
            SendMessage, 0x84, 0, vPosX|(vPosY<<16), , ahk_id %hWnd% ;WM_NCHITTEST
            vNCHITTEST := ErrorLevel ;(8 min, 9 max, 20 close)
            
            if (APP_NAME == "Threema") {
                MouseGetPos, x, y
                WinGetPos, wx, wy, ww, wh
                q := (wx + ww - x) <= 220 && (wx + ww - x) >= 152
                if (q && (vNCHITTEST == 2 || vNCHITTEST == 8)) {
                    App.close()
                    Return
                }
            } else {
                if (vNCHITTEST == 8) {
                    App.close()
                    Return
                }
            }
            
        }
        SendInput {LButton Down}
        KeyWait, LButton
        SendInput {LButton Up}
    Return
    
#IfWinActive
