; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; 
;                                                               ; 
;                        Window Functions                       ;
;                                                               ; 
; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; 

restore_all_windows() {
    WinGet, WindowList, List
    loop %WindowList% {
        WinUID := WindowList%A_Index%
        WinGetTitle, WinTitle, ahk_id %WinUID%
        WinGetClass, WinClass, ahk_id %WinUID%
        WinGet mm, MinMax, ahk_id %WinUID%
        if (trim(WinTitle) <> "" and WinClass <> "tooltips_class32" and mm != -1 and mm != 0) {
            Continue
        }
        WinActivate, ahk_id %WinUID% 
    }
}

get_focus_name() {
    ControlGetFocus currentFocus
    return currentFocus
}

minimize_current_window() {
    WinGetClass, t, A
    if (t == "WorkerW" || t == "AutoHotkeyGUI" || t == "Shell_TrayWnd")
        return
    WinMinimize, A   
}

window_to_bottom_and_activate_topmost() {
    Critical, On
    
    static skip := {"MsoCommandBar": true, "WorkerW": true, "Shell_TrayWnd": true, "Windows.UI.Core.CoreWindow": true, "HwndWrapper[RetroBar;;5185c85c-029f-467e-9e82-3a9a0fb5d33d]": true}
    WinGetClass, c, A
    if (skip[c]) {
        Critical, Off
        return
    }
    
    WinSet, Bottom, , A
    
    WinGet, WindowList, List
    loop %WindowList% {
        WinUID := WindowList%A_Index%
        WinGetTitle, WinTitle, ahk_id %WinUID%
        WinGetClass, WinClass, ahk_id %WinUID%
        WinGet mm, MinMax, ahk_id %WinUID%
        if (trim(WinTitle) <> "" and WinClass <> "tooltips_class32" and mm != -1) {
            Break
        }
    }
    
    WinActivate, ahk_id %WinUID% 
    Critical, Off
}
