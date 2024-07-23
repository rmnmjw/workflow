; #include ../ahk-lib/VD.ahk
; VD.init()

Gui, screen_time:+AlwaysOnTop +ToolWindow -Caption +LastFound

if (A_ScreenDPI == 96) {
    Gui, screen_time:Font, s10L q5, Segoe UI
} else {
    Gui, screen_time:Font, s9L q5, Segoe UI
}

Gui, screen_time:+E0x02000000 +E0x00080000 +E0x20

RegRead, is_light_mode, HKCU, Software\Microsoft\Windows\CurrentVersion\Themes\Personalize, SystemUsesLightTheme

if (is_light_mode) {
    COLOR_FONT := "18191A"
    COLOR_BG   := "E3EEF9"
} else {
    COLOR_FONT := "FFFFFF"
    COLOR_BG   := "202020"
}

; # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
; Gui, screen_time:Add, Text, vScreenTime c%COLOR_FONT% x40 y0 w220 left, YOYOYOYO

Gui, screen_time:Add, Text, vTop        c%COLOR_FONT% x0 y0  w220 left, XXXXX
Gui, screen_time:Add, Text, vBottom     c%COLOR_FONT% x0 y18 w220 left, XXXXX
; # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

Gui, screen_time:Color, %COLOR_BG%
WinSet, TransColor, %COLOR_BG%

if (192 == A_ScreenDPI) {
    ; Gui, screen_time:Show, x80 y0 h80 w500 NoActivate ; 200%
    ; y := (1080 / 96 * A_ScreenDPI) - 76
    ; Gui, screen_time:Show, x100 y%y% h80 w500 NoActivate ; 200%
    
    y := A_ScreenHeight - 82
    Gui, screen_time:Show, x16 y%y% h80 w500 NoActivate ; 200%
} else if (144 == A_ScreenDPI) {
    ; y := A_ScreenHeight - 56
    ; y := 3
    ; Gui, screen_time:Show, x100 y%y% h80 w500 NoActivate ; 200%
    
    ; 150% bottom win 11
    y := A_ScreenHeight - 61
    Gui, screen_time:Show, x10 y%y% h80 w500 NoActivate ; 200%
} else {
    Gui, screen_time:Show, x50 y1 h80 w500 NoActivate ; 100%
    ; y := A_ScreenHeight - 40
    ; Gui, screen_time:Show, x10 y%y% h80 w500 NoActivate ; 100%
}


Gui, screen_time:+AlwaysOnTop


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

; get_screen_time() {
;     path := "C:\Users\rmn\AppData\Local\digital-wellbeing\dailylogs\" . A_MM . "-" . A_DD . "-" . A_YYYY . ".log"
;     FileRead, s, %path%
;     oArray := StrSplit(s, "`n", "`r")
;     sum := 0
;     for idx in oArray {
;         sum += StrSplit(oArray[idx], A_Tab)[2]
;     }
;     return timer_secs_to_time(sum)
; }


; refresh_bottom()
; SetTimer, refresh_bottom, 5000
; refresh_bottom() {
; }

refresh_top() {
    static acht = false
    global is_light_mode
    
    ; if (VD.getCurrentDesktopNum() != 1) {
    ;     GuiControl, screen_time:, Top
    ;     GuiControl, screen_time:, Bottom
    ;     return
    ; }
    
    c := get_clockodo()
    
    x := c > "04:48:00" ? "+" : "" ; min work time
    GuiControl, screen_time:, Top, ⏱%c%%x%
    e := get_external_timer_diff()
    GuiControl, screen_time:, Bottom, ⌚%e%
    ; s := get_screen_time()
    ; GuiControl, screen_time:, ScreenTime, 🖥️%s%
    
    RegRead, is_light_mode_new, HKCU, Software\Microsoft\Windows\CurrentVersion\Themes\Personalize, SystemUsesLightTheme
    if (is_light_mode != is_light_mode_new)
        Reload
    
    if (!acht && c > "08:00:00") {
        MsgBox, 8 h überschritten
        acht := true
    }
}
refresh_top()
SetTimer, refresh_top, 1000



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

!^+r::Reload
