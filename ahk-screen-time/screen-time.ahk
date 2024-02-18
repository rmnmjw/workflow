#SingleInstance Force
#Persistent
#UseHook
#NoEnv
ListLines Off ; Displays the script lines most recently executed.
DetectHiddenWindows, Off
CoordMode, Mouse, Screen
SendMode Input
SetTitleMatchMode, 2
SetWorkingDir %A_ScriptDir%
SetWinDelay, 0

Menu, Tray, Icon, icon.png

TEMP_FILE := A_Temp . "\autohotkey.ini"


Gui, screen_time:+AlwaysOnTop +ToolWindow -Caption +LastFound
Gui, screen_time:Font, s10L q4, Segoe UI
Gui, screen_time:+E0x02000000 +E0x00080000
Gui, screen_time:Margin, 32, 16
Gui, screen_time:Add, Text, vScreenTime cFFFFFF, 99:99:99
Gui, screen_time:Add, Text, vScreenTime2 cFFFFFF w49, xxxxxxxx
Gui, screen_time:Color, 211F23
WinSet, TransColor, 211F23
Gui, screen_time:Show, x0 y1600 h80 NoActivate

Gui, screen_time_bg:+ToolWindow -Caption +LastFound
Gui, screen_time_bg:Color, d20000

randft(f, t) {
    Random, val, f, t
    return val
}

time_format(T) { ; based on https://www.autohotkey.com/boards/viewtopic.php?t=77420
    Local H, M, HH, Q:=60, R:=3600
    Return Format("{:02}:{:02}:{:02}", H:=T//R, M:=(T:=T-H*R)//Q, T-M*Q, HH:=H, HH*Q+M)
}

not_fs_or_fs_idle() {
    static fs := 0, wx := -1, wy := -1, ww := -1, wh := -1
    static same_col := false, toggle := false, col := -1
    static rx := -1, ry := -1
    static counter := 30
    
    if (!toggle) {
        rx := Floor((randft(1, 3839) + randft(1, 3839))/2)
        ry := Floor((randft(1, 2159) + randft(1, 1600))/2)
        PixelGetColor, col, rx, ry
        toggle := true
    } else {
        PixelGetColor, col_second, rx, ry
        same_col := col == col_second
        toggle := false
        if (!same_col) {
            counter := 30
        }
    }
    
    counter := Max(0, counter - 1)
    changed := counter > 0
    
    return counter == 0
}

last := A_TickCount

total := 0
IniRead, total, %TEMP_FILE%, screen_time, %A_YYYY%%A_MM%%A_DD%, 0
MsgBox, %total%
added := 0

save_counter := 5
SetTimer, main_loop, 1000
main_loop(save_force:=false) {
    global last, total, TEMP_FILE, added, save_counter
    time_now := A_TickCount
    delta    := time_now - last
    last     := time_now
    idle     := A_TimeIdle
    idle_fs  := not_fs_or_fs_idle()
    
    if (delta > 3000) {
        return ; delta too big
    }
    if (idle > 30000 && idle_fs) {
        return ; user is idle
    }
    
    Critical, On
        added += delta
        current_total := (total + added) // 1000
    Critical, Off
    
    formatted := time_format(current_total)
    
    GuiControl, screen_time:, ScreenTime, %formatted%
    Gui, screen_time:+AlwaysOnTop
    
    save_counter -= 1
    if (save_counter <= 0 || save_force) {
        save_counter := 5
        
        date := A_YYYY . A_MM . A_DD
        
        ; self
        Critical, On
            total := total + added
            added := 0
        Critical, Off
        IniWrite, %total_new%, %TEMP_FILE%, screen_time, %date%
        
        ; external
        path := A_Temp . "\external_timer.txt"
        FileRead, s, %path%
        s := Trim(s)
        GuiControl, screen_time:, ScreenTime2, %s%
    }
}
main_loop(true)

~!^+r::
    main_loop(true)
    Reload
Return