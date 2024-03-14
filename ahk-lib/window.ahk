window_current_minimize() {
    WinGetClass, t, A
    if (t == "WorkerW" || t == "AutoHotkeyGUI" || t == "Shell_TrayWnd" || t == "Shell_SecondaryTrayWnd")
        return
    WinMinimize, A   
}

window_get_focus_name() {
    ControlGetFocus currentFocus
    return currentFocus
}