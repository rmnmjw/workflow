; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; 
;                                                               ; 
;                          Screen Time                          ;
;                                                               ; 
; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; 

Gui, screen_time:+AlwaysOnTop +ToolWindow -Caption +LastFound
Gui, screen_time:Font, s9L q5, Segoe UI
Gui, screen_time:+E0x02000000 +E0x00080000
Gui, screen_time:Margin, 32, 16
Gui, screen_time:Add, Text, vScreenTime  cFFFFFF x0 y0 w75 center, xxxxxxxxxxxx
Gui, screen_time:Add, Text, vScreenTime2 cFFFFFF x0 y18 w75 center, xxxxxxxxxxxx
Gui, screen_time:Color, 213740
WinSet, TransColor, 213740
; Gui, screen_time:Show, x0 y1650 h80 w113 NoActivate
Gui, screen_time:Show, x3000 y2085 h80 w113 NoActivate

Gui, screen_time_bg:+ToolWindow -Caption +LastFound
Gui, screen_time_bg:Color, d20000

SetTimer, screen_time_hide_on_full_screen, 1000
screen_time_hide_on_full_screen() {
    static is_hidden := falsen
    
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
}

randft(f, t) {
    Random, val, f, t
    return val
}

not_fs_or_fs_idle() {
    static fs := 0, wx := -1, wy := -1, ww := -1, wh := -1
    static same_col := false, toggle := false, col := -1
    static rx := -1, ry := -1
    static counter := 15
    
    if (!toggle) {
        rx := Floor((randft(1, 3839) + randft(1, 3839))/2)
        ry := Floor((randft(1, 2159) + randft(1, 1600))/2)
        ; ToolTip, %rx% --- %ry%
        ; MouseMove, rx, ry
        PixelGetColor, col, rx, ry
        toggle := true
    } else {
        PixelGetColor, col_second, rx, ry
        same_col := col == col_second
        toggle := false
        if (!same_col) {
            counter := 15
        }
    }
    
    counter := Max(0, counter - 1)
    changed := counter > 0
    
    ; WinGetPos, wx, wy, ww, wh, A
    ; fs := wx == 0 && wy == 0 && ww == 3840 && wh == 2160
    
    ; if (!fs) {
    ;     return true
    ; }
    
    return counter == 0
}

screen_time_periodic()
SetTimer, screen_time_periodic, 1000
screen_time_periodic(force_save:=false) {
    global TEMP_FILE
    static changes := false, counter := 0, screen_time_start := -1
    
    screen_time_varname := A_YYYY . A_MM . A_DD
    IniRead, screen_time_total, %TEMP_FILE%, screen_time, %screen_time_varname%, 0
    
    other_idle_check := not_fs_or_fs_idle()
    
    if (A_TimeIdlePhysical < 2000) {
        if (screen_time_start == -1) {
            screen_time_start := A_Now
        }
        changes := true
    } else if (A_TimeIdlePhysical >= 30000 && other_idle_check) {
        if (screen_time_start != -1) {
            screen_time_total += time_diff_sec_abs(screen_time_start, A_Now)
            screen_time_start := -1
            changes := true
        }
    }

    if (screen_time_start != -1) {
        current := time_diff_sec_abs(screen_time_start, A_Now)
        if (current >= 40) {
            current := 15
        }
    } else {
        current := 0
    }
 
    counter := Mod(counter + 1, 15)
    if (changes && counter == 0 || force_save) {
        screen_time_total += current
        current := 0
        if (screen_time_start != -1) {
            screen_time_start := A_Now
        }
        
        IniWrite, %screen_time_total%, %TEMP_FILE%, screen_time, %screen_time_varname%
        changes := false
    }
    
    current_total := current + screen_time_total
    
    hours_today := current_total / 3600
    if (hours_today > 10) {
        if (Mod(current_total, 2) == 0) {
            Gui, screen_time:Font, vScreenTime +c000000
            Gui, screen_time:Font, vScreenTime2 +c000000
            Gui, screen_time:Color, d20000
            WinSet, TransColor, f92472
            Gui, screen_time_bg:Show, x0 y1700 h47 w113 NoActivate
        } else {
            Gui, screen_time:Color, 211F23
            WinSet, TransColor, 211F23
        }
    }
    
    formatted := time_format(current_total)
    GuiControl, screen_time:, ScreenTime, %formatted%
    Gui, screen_time:+AlwaysOnTop
}


SetTimer, external_refresh, 30000
external_refresh()
external_refresh() {
    path := A_Temp . "\external_timer.txt"
    FileRead, s, %path%
    s := Trim(s)
    GuiControl, screen_time:, ScreenTime2, %s%
}
