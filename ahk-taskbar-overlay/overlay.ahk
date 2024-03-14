; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; 
;                                                               ; 
;                          Screen Time                          ;
;                                                               ; 
; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; 

Gui, screen_time:+AlwaysOnTop +ToolWindow -Caption +LastFound
Gui, screen_time:Font, s10L q5, Segoe UI

Gui, screen_time:+E0x02000000 +E0x00080000 +E0x20

RegRead, is_light_mode, HKCU, Software\Microsoft\Windows\CurrentVersion\Themes\Personalize, AppsUseLightTheme

if (is_light_mode) {
    COLOR_FONT := "18191A"
    COLOR_BG   := "E3EEF9"
} else {
    COLOR_FONT := "FFFFFF"
    COLOR_BG   := "1C212B"
}

Gui, screen_time:Add, Text, vTop c%COLOR_FONT% x0 y0 w220 left, XXXXX
Gui, screen_time:Add, Text, vBottom c%COLOR_FONT% x0 y20 w220 left, XXXXX
Gui, screen_time:Color, %COLOR_BG%
WinSet, TransColor, %COLOR_BG%
; Gui, screen_time:Show, x3506 y10 h80 w113 NoActivate
; Gui, screen_time:Show, x4 y2106 h80 w220 NoActivate
Gui, screen_time:Show, x7 y2074 h80 w220 NoActivate

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

get_clockodo() {
    static counter := 0, ext := 0, last := 0
    static t := "", next := -1
    if (counter == 0) {
        ext := get_external_timer_today()
    }
    counter += 1
    if (counter == 15) {
        counter := 0
    }
    
    if (A_TickCount >= next) {
        DetectHiddenWindows, On
            WinGetTitle, t, Clockodo* ahk_class Chrome_WidgetWin_1 ahk_exe brave.exe
        DetectHiddenWindows, Off
        next := A_TickCount + 100
    }

    t := Trim(StrReplace(t, "Clockodo*"))
    if (t == "") {
        t := "00:00:00"
    }

    total := ext + timer_time_to_secs(t)
    
    weird := ""
    if ((total+2) < last) {
        weird := "*"
    } else {
        last := total
    }
    
    return weird . timer_secs_to_time(total)
}

get_external_timer_diff() {
    static path := A_Temp . "\external_timer_diff.txt"
    FileRead, s, %path%
    return Trim(s)
}

get_external_timer_today() {
    static path := A_Temp . "\external_timer_today.txt"
    FileRead, s, %path%
    return Trim(s)
}

timer_time_to_secs(t) {
    for i, p in StrSplit(t, ":") {
        if (i == 1)
            h := p
        if (i == 2)
            m := p
        if (i == 3)
            s := p
    }
    return (h * 60 + m) * 60 + s
}

leading_zero(i) {
    if (StrLen(i) == 1) {
        return "0" . i
    }
    return "" . i
}

timer_secs_to_time(s) {
    h := floor(s / 3600)
    m := floor((s - h * 3600) / 60)
    s := s - h * 3600 - m * 60
    h := leading_zero(h)
    m := leading_zero(m)
    s := leading_zero(s)
    return h . ":" . m . ":" . s
}



; refresh_bottom()
; SetTimer, refresh_bottom, 5000
; refresh_bottom() {
; }

refresh_top()
SetTimer, refresh_top, 1000
refresh_top() {
    global is_light_mode
    
    c := get_clockodo()
    GuiControl, screen_time:, Top, ⏱ %c%
    e := get_external_timer_diff()
    GuiControl, screen_time:, Bottom, ⌚ %e%
    
    RegRead, is_light_mode_new, HKCU, Software\Microsoft\Windows\CurrentVersion\Themes\Personalize, AppsUseLightTheme
    if (is_light_mode != is_light_mode_new)
        Reload
}


!^+r::Reload
