app_is_running(exe) {
    dhw := A_DetectHiddenWindows
    DetectHiddenWindows, On
    WinGet, exists, PID, ahk_exe %exe%
    DetectHiddenWindows, %dhw%
    return !!exists
}

app_launch_if_needed(exe, path:="", admin:=false) {
    if (path == "")
        path := exe
    if (!app_is_running(exe)) {
        if (admin)
            Run, %path%
        else
            run_as_user(path, "", 0)
    }
}
