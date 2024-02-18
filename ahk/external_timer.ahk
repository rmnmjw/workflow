; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; 
;                                                               ; 
;                          Screen Time                          ;
;                                                               ; 
; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; 

Gui, screen_time:+AlwaysOnTop +ToolWindow -Caption +LastFound
Gui, screen_time:Font, s9L q5, Segoe UI
Gui, screen_time:+E0x02000000 +E0x00080000 +E0x20
Gui, screen_time:Margin, 32, 16
Gui, screen_time:Add, Text, vScreenTime  cFFFFFF x0 y0 w120 right, XXXXX
Gui, screen_time:Color, 213740
WinSet, TransColor, 213740
; Gui, screen_time:Show, x3506 y10 h80 w113 NoActivate
Gui, screen_time:Show, x3410 y10 h80 w120 NoActivate

Gui, screen_time_bg:+ToolWindow -Caption +LastFound
Gui, screen_time_bg:Color, d20000

string_right := "??:??"

SetTimer, screen_time_hide_on_full_screen, 1000
screen_time_hide_on_full_screen() {
    static is_hidden := false
    
    WinGetClass, clazz, A
    if ("Progman" == clazz || "WorkerW" == clazz) {
        fs := false
    } else {
        WinGetPos, wx, wy, ww, wh, A
        fs := wx == 0 && wy == 0 && ww == 3840 && wh == 2160
    }

    if (fs && !is_hidden) {
        Gui, screen_time:Hide
        is_hidden := true
    } else if (!fs && is_hidden) {
        Gui, screen_time:Show, NoActivate
        is_hidden := false
    }
    Gui, screen_time:+AlwaysOnTop
}

SetTimer, refresh_left, 1000
refresh_left()
refresh_left() {
    global string_right

    DetectHiddenWindows, On
        WinGetTitle, t, Clockodo* ahk_class Chrome_WidgetWin_1 ahk_exe brave.exe
    DetectHiddenWindows, Off

    t := Trim(StrReplace(t, "Clockodo*"))
    if (t == "") {
        t := "00:00:00"
    }
    GuiControl, screen_time:, ScreenTime, [%t% | %string_right%]
}

SetTimer, refresh_right, 10000
refresh_right()
refresh_right() {
    global string_right
    static path := A_Temp . "\external_timer.txt"
    FileRead, s, %path%
    string_right := Trim(s)
}
