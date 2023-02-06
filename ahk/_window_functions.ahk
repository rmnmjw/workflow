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
    
    static skip := { "HwndWrapper[RetroBar;;295ed828-7f71-4f84-8552-fbf81fe5f314]": true, "MsoCommandBar": true, "WorkerW": true, "Shell_TrayWnd": true, "Windows.UI.Core.CoreWindow": true, "HwndWrapper[RetroBar;;5185c85c-029f-467e-9e82-3a9a0fb5d33d]": true, "ApplicationFrameWindow": true, "HwndWrapper[PowerToys.PowerLauncher;;ad955d97-abcd-4877-b43b-c69f9d4c361c]": true, "Windows.UI.Core.CoreWindow": true, "HwndWrapper[RetroBar;;396f90e1-b93e-44b4-a494-f213f520d04c]": true, "CiceroUIWndFrame": true, "HwndWrapper[RetroBar;;7bbfe7f1-78c1-4bb6-b6ba-0baf6b281b78]": true, "Xaml_WindowedPopupClass": true, "HwndWrapper[RetroBar;;379033f4-3b08-4a70-8d09-7ff3855fd027]": true, "GDI+ Window (RetroBar.exe)": true, "HwndWrapper[PowerToys.PowerLauncher;;4c619480-cfa0-4134-8aec-0cdab9f4a980]": true, "GDI+ Hook Window Class": true, "XamlExplorerHostIslandWindow": true, "SystemTray_Main": true, "ATL:00007FF9CEE2D230": true, "tooltips_class32": true, "ConsoleWindowClass :: 0": true, "TWizardForm": true, "TApplication": true }
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
        
        
        if (mm == -1)
            continue
        
        if (trim(WinTitle) == "")
            continue
        
        if (skip[WinClass]) {
            continue
        }
        
        Break
    }
    
    WinActivate, ahk_id %WinUID% 
    Critical, Off
}
