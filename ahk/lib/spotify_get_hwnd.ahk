spotify_get_hwnd(find_hidden:=true) {
    static next := -1, last := false
    if (A_TickCount < next) {
        return last
    }
    next := A_TickCount + 1000
    dhw := A_DetectHiddenWindows
    DetectHiddenWindows, %find_hidden%
        WinGet, id, list
        Loop, %id% {
            this_ID := id%A_Index%
            WinGet, exe, ProcessName, ahk_id %this_ID%
            if (exe == "Spotify.exe") {
                WinGetClass, clazz, ahk_id %this_ID%
                if ((clazz == "Chrome_WidgetWin_0" || clazz == "Chrome_WidgetWin_1")) {
                    DetectHiddenWindows, %dhw%
                    last := this_ID
                    return this_ID
                }
            }
        }
    DetectHiddenWindows, %dhw%
    last := false
    return false
}
