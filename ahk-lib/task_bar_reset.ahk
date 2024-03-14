task_bar_reset() {
    WinExist("ahk_class Shell_TrayWnd")
    SysGet, s, Monitor
    
    WM_ENTERSIZEMOVE := 0x0231
    WM_EXITSIZEMOVE  := 0x0232
    
    SendMessage, WM_ENTERSIZEMOVE
        WinMove, , , sLeft, sTop, sRight, 0
    SendMessage, WM_EXITSIZEMOVE
    SendMessage, WM_ENTERSIZEMOVE
        WinMove, , , sLeft, sBottom, sRight, 0
    SendMessage, WM_EXITSIZEMOVE
}
