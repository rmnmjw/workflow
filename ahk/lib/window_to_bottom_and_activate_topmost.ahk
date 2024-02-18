window_to_bottom_and_activate_topmost() {
    Critical, On
    
    WinGetClass, c, A
    WinGet, x, ProcessName, A
    
    static skip_class := { "HwndWrapper[RetroBar;;7f115ed5-d681-4689-9462-ff7fff349f0f]": true, "HwndWrapper[RetroBar;;295ed828-7f71-4f84-8552-fbf81fe5f314]": true, "MsoCommandBar": true, "WorkerW": true, "Shell_TrayWnd": true, "Shell_SecondaryTrayWnd": true, "Windows.UI.Core.CoreWindow": true, "HwndWrapper[RetroBar;;5185c85c-029f-467e-9e82-3a9a0fb5d33d]": true, "HwndWrapper[PowerToys.PowerLauncher;;ad955d97-abcd-4877-b43b-c69f9d4c361c]": true, "Windows.UI.Core.CoreWindow": true, "HwndWrapper[RetroBar;;396f90e1-b93e-44b4-a494-f213f520d04c]": true, "CiceroUIWndFrame": true, "HwndWrapper[RetroBar;;7bbfe7f1-78c1-4bb6-b6ba-0baf6b281b78]": true, "Xaml_WindowedPopupClass": true, "HwndWrapper[RetroBar;;379033f4-3b08-4a70-8d09-7ff3855fd027]": true, "GDI+ Window (RetroBar.exe)": true, "HwndWrapper[PowerToys.PowerLauncher;;4c619480-cfa0-4134-8aec-0cdab9f4a980]": true, "GDI+ Hook Window Class": true, "XamlExplorerHostIslandWindow": true, "SystemTray_Main": true, "ATL:00007FF9CEE2D230": true, "tooltips_class32": true, "ConsoleWindowClass :: 0": true, "TWizardForm": true, "TApplication": true }
    static skip_exe := { "RetroBar.exe": true }

    if (skip_class[c] || skip_exe[x]) {
        Critical, Off
        return
    }
    
    if (c == "MozillaWindowClass" && x == "thunderbird.exe") {
        WinMinimize, A
    } else if (c == "Chrome_WidgetWin_0" && x == "Spotify.exe") {
        WinClose, A 
    } else {
        WinSet, Bottom, , A
    }
    Sleep, 40
    
    WinGet, WindowList, List
    loop %WindowList% {
        WinUID := WindowList%A_Index%
        WinGetTitle, WinTitle, ahk_id %WinUID%
        WinGetClass, WinClass, ahk_id %WinUID%
        ; WinGet mm, MinMax, ahk_id %WinUID%
        WinGet, WinExe, ProcessName, ahk_id %WinUID%
        
        ; if (mm == -1) {
        ;     continue
        ; }
        
        if (trim(WinTitle) == "") {
            continue
        }
        
        if (skip_class[WinClass]) {
            continue
        }
        
        if (skip_exe[WinExe]) {
            continue
        }
        
        Break
    }
    
    WinActivate, ahk_id %WinUID% 
    WinWaitActive, ahk_id %WinUID% 
    
    Critical, Off
}