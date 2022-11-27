; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; 
;                                                               ; 
;                          Screen Time                          ;
;                                                               ; 
; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; 

screen_time_varname := A_YYYY . A_MM . A_DD
if (A_Hour < 4) {
    screen_time_varname -= 1
}

IniRead, screen_time_total, %TEMP_FILE%, screen_time, %screen_time_varname%, 0

Gui, +AlwaysOnTop +ToolWindow -Caption +LastFound
Gui, Font, s8L q4, Segoe UI
Gui, +E0x02000000 +E0x00080000
Gui, Margin, 32, 16
Gui, Add, Text, vScreenTime cFFFFFF, x100 y30
Gui, Color, 211F23
WinSet, TransColor, 211F23
Gui, Show, x0 y2113 h47 NoActivate

SetTimer, screen_time_hide_on_full_screen, 1000
screen_time_hide_on_full_screen() {
    static is_hidden := false
    
    WinGetPos, wx, wy, ww, wh, A
    fs := wx == 0 && wy == 0 && ww == 3840 && wh == 2160

    if (fs && !is_hidden) {
        Gui, Hide
        is_hidden := true
    } else if (!fs && is_hidden) {
        Gui, Show, NoActivate
        is_hidden := false
    }
}

SetTimer, screen_time_periodic, 1000
screen_time_periodic()
screen_time_periodic(force_save:=false) {
    global TEMP_FILE
    global screen_time_total, screen_time_varname
    static changes := false, counter := 0, screen_time_start := -1
    
    if (A_TimeIdlePhysical < 2000) {
        if (screen_time_start == -1) {
            screen_time_start := A_Now
        }
        changes := true
    } else if (A_TimeIdlePhysical >= 30000 && screen_time_start != -1) {
        screen_time_total += time_diff_sec_abs(screen_time_start, A_Now)
        screen_time_start := -1
        changes := true
    }

    if (screen_time_start != -1) {
        current := time_diff_sec_abs(screen_time_start, A_Now)
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
            Gui, Font, vScreenTime +c000000
            Gui, Color, d20000
            WinSet, TransColor, f92472
        } else {
            Gui, Color, 211F23
            WinSet, TransColor, 211F23
        }
    }
    
    formatted := time_format(current_total)
    GuiControl,, ScreenTime, %formatted%
    Gui, +AlwaysOnTop
}
