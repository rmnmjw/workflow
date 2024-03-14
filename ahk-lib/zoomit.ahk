zoomit_zoom := 0

zoomit_zoom_in() {
    global zoomit_zoom
    Critical, On
    if (zoomit_zoom < 0) {
        zoomit_zoom := 0
        cursor_speed_set()
        ToolTip,
    }
    if (WinActive("Zoomit Zoom Window ahk_class ZoomitClass ahk_exe ZoomIt64.exe")) {
        Send, {WheelUp}
        zoomit_zoom := zoomit_zoom + 1
    } else {
        zoomit_zoom := 1
        Send, {Ctrl down}{Shift down}{Alt down}z{Alt up}{Shift up}{Ctrl up}
        Sleep, 100
    }
    z := Min(6, Max(1, 6-Round(Abs(zoomit_zoom+1)/1.25)))
    cursor_speed_set(z)
    Critical, Off
}

zoomit_zoom_out() {
    global zoomit_zoom
    Critical, On
    
    if (WinActive("Zoomit Zoom Window ahk_class ZoomitClass ahk_exe ZoomIt64.exe")) {
        Send, {WheelDown}
        zoomit_zoom := zoomit_zoom - 1
        if (zoomit_zoom <= 0) {
            ToolTip, z: %zoomit_zoom%
        }
        z := Min(6, Max(1, 6-Round(Abs(zoomit_zoom+1)/1.25)))
        cursor_speed_set(z)
        if (zoomit_zoom <= -5) {
            cursor_speed_set()
            ToolTip,
            Send, {Ctrl down}{Shift down}{Alt down}z{Alt up}{Shift up}{Ctrl up}
        }
    }
    Critical, Off
}
