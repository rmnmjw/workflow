space_fill(t, l:=3, f:=" ") {
    r := l-StrLen(t)
    loop, %r% {
        t := f . t
    }
    return t
}

; https://www.autohotkey.com/boards/viewtopic.php?t=48211
; https://autohotkey.com/board/topic/7022-acbattery-status/
read_int(p_address, p_offset, p_size, p_hex=true) {
    value = 0
    old_FormatInteger := a_FormatInteger
    if (p_hex)
        SetFormat, integer, hex
    else
        SetFormat, integer, dec
    loop %p_size%
        value := value+( *( ( p_address+p_offset )+( a_Index-1 ) ) << ( 8* ( a_Index-1 ) ) )
    SetFormat, integer, %old_FormatInteger%
    return value
}

get_battery_status_raw() {
    VarSetCapacity(powerStatus, 1+1+1+1+4+4)
    success := DllCall("GetSystemPowerStatus", "UInt", &powerStatus)
    
    acLineStatus        := read_int(&powerstatus,0,1,false)
    batteryFlag         := read_int(&powerstatus,1,1,false)
    batteryLifePercent  := read_int(&powerstatus,2,1,false)
    batteryLifeTime     := read_int(&powerstatus,4,4,false)
    batteryFullLifeTime := read_int(&powerstatus,8,4,false)
    
    output                     := {}
    output.acLineStatus        := acLineStatus
    output.batteryFlag         := batteryFlag
    output.batteryLifePercent  := batteryLifePercent
    output.batteryLifeTime     := batteryLifeTime
    output.batteryFullLifeTime := batteryFullLifeTime
    
    Return output
}

get_battery_status() {
    BatteryStatus := get_battery_status_raw()
    charging      := ""
    if (BatteryStatus.acLineStatus != 0)
        charging := "⚡"


    battery := BatteryStatus.batteryLifePercent
    if (battery == 255)
        battery := "?"

    return "🔋" . charging . " " . battery . "%" 
}

; https://www.reddit.com/r/AutoHotkey/comments/liicqk/real_total_system_cpu_usage_from_within_an/gn4881q/?context=3
GetSystemTimes(ByRef IdleTime) {
   DllCall("GetSystemTimes", "Int64P", IdleTime, "Int64P", KernelTime, "Int64P", UserTime)
   Return KernelTime + UserTime
}

string_cpu_time := "🧠 999%"
refresh_cpu_time()
SetTimer, refresh_cpu_time, 1000
refresh_cpu_time() {
    global string_cpu_time
    static cpu_total_a, cpu_total_b, cpu_idle_a, cpu_idle_b
    cpu_total_b     := GetSystemTimes(cpu_idle_b)
    cpu_time        := round(100*(1 - (cpu_idle_b - cpu_idle_a)/(cpu_total_b - cpu_total_a)))
    string_cpu_time := "🧠" . space_fill(cpu_time, 3) . "%"
    cpu_total_a     := cpu_total_b
    cpu_idle_a      := cpu_idle_b
}

; https://autohotkey.com/board/topic/35785-find-system-memory-ram/?p=225248
get_ram_usage() {
    VarSetCapacity(memorystatus, 4+4+4+4+4+4+4+4)
    DllCall("kernel32.dll\GlobalMemoryStatus", "uint", &memorystatus)
    value = 0 
    loop, 4
        value := value+( *( ( &memorystatus+4 )+( a_Index-1 ) ) << ( 8* ( a_Index-1 ) ) )
    return "💾" . space_fill(value) . "%"
}

get_date() {
    global get_date_time_clocks
    static w := {1: "So", 2: "Mo", 3: "Di", 4: "Mi", 5: "Do", 6: "Fr", 7: "Sa"}
    FormatTime, d,, yyyy-MM-dd
    return "📅 " w[A_WDay] . " " . d
}
get_time() {
    static e := ["🕛", "🕧", "🕐", "🕜", "🕑", "🕝", "🕒", "🕞", "🕓", "🕟", "🕔", "🕠", "🕕", "🕡", "🕖", "🕢", "🕗", "🕣", "🕘", "🕤", "🕙", "🕥", "🕚", "🕦", "🕛", "🕧", "🕐"]
    FormatTime, t,, HH:mm:ss
    FormatTime, h,, h
    FormatTime, m,, m
    c := 1 + 2 * h + round(m / 30)
    
    return e[c] . " " . t
}

get_volume_volume_virtual_delta := 0
get_volume_volume := 0
get_volume_muted := 0
get_volume() {
    global get_volume_volume_virtual_delta, get_volume_volume, get_volume_muted

    if (get_volume_volume_virtual_delta == 0) {
        SoundGet, get_volume_volume
        SoundGet, get_volume_muted, , MUTE
    } else {
        get_volume_volume += get_volume_volume_virtual_delta
        get_volume_volume_virtual_delta := 0
    }
    
    if (get_volume_muted = "On") {
        emoji := "🔇"
    } else if (get_volume_volume < 10) {
        emoji := "🔈"
    } else if (get_volume_volume < 30) {
        emoji := "🔉"
    } else {
        emoji := "🔊"
    }
    return emoji . space_fill(round(get_volume_volume), 3) . "%"
}

; window title: $if(%isplaying%, $if(%ispaused%,⏸️,🎵) '['%playback_time%[/%length%]']',⏹️) [%artist% -] %title%
; ib_foobar_window_id = false
; get_foobar_id_runner() {
;     global ib_foobar_window_id
;     DetectHiddenWindows, On
;     WinGet, hwnd, id, ahk_class {97E27FAA-C0B3-4b8e-A693-ED7881E99FC1} ahk_exe foobar2000.exe
;     DetectHiddenWindows, Off
;     if (hwnd == "") {
;         ib_foobar_window_id := false
;     } else {
;         ib_foobar_window_id := hwnd
;     }
; }
; ; get_foobar_id_runner()

; SetTimer, get_foobar_id_runner, 5000
; get_foobar_song() {
;     global ib_foobar_window_id
;     if (!ib_foobar_window_id) {
;         return "  |  🟩 [  :  /  :  ] -"
;     }
;     DetectHiddenWindows, On
;     WinGetTitle, t, ahk_id %ib_foobar_window_id%
;     DetectHiddenWindows, Off
    
;     t := Trim(t)
;     if (SubStr(t, 1, 10) == "foobar2000")
;         return ""
;     if (t == "")
;         return ""
;     l := StrLen(t)
;     t := SubStr(t, 1, l-12)
;     return "  |  " . t
; }

get_disk_space(n) {
    d := n . ":\"
    DriveGet, t, Capacity, %d%
    DriveSpaceFree, f, %d%
    return "💿 " . n . " " . round(100 - f/t * 100) . "%"
}

get_disk_space_free_gb(n) {
    d := n . ":\"
    DriveSpaceFree, f, %d%
    f := round(f / 1024)
    return "💿 " . n . " " . f . "G"
}


string_weather := ""
string_weather_refresh()
SetTimer, string_weather_refresh, 900000
string_weather_refresh() {
    global string_weather
    whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
    w.SetRequestHeader("Content-Type", "application/x-www-form-urlencoded; charset=UTF-8")
    whr.Open("GET", "https://wttr.in/?format=2", true)
    whr.Send()
    whr.WaitForResponse()
    tmp := StrSplit(whr.ResponseText, "km/h")[1]
    tmp := StrReplace(StrReplace(tmp, "   ", " "), " ", "  ")
    tmp := StrReplace(StrReplace(tmp, "🌡", "|  🌡 "), "🌬", "|  🌬 ")
    string_weather := "[ " . tmp . " ]"
}

SCREEN_SCALE_FACTOR := A_ScreenDPI / 96
SCREEN_WIDTH  :=  A_ScreenWidth / SCREEN_SCALE_FACTOR
SCREEN_HEIGHT := A_ScreenHeight / SCREEN_SCALE_FACTOR

Gui, Color, 101010, white
Gui, Font, s11L, Courier Prime BC
placeholder := "~" . space_fill("", l:=272, f:="X") . "~"
gw := SCREEN_WIDTH
gh := 24
gy := 0 ;A_ScreenHeight-gh
Gui, add, text, vTheInfoLeft cE3E3E3 y-2 x0 w%gw% left, %placeholder%
Gui, add, text, vTheInfoCenter cE3E3E3 y-2 x0 w%gw% center, %placeholder%
Gui, add, text, vTheInfoRight cE3E3E3 y-2 x0 w%gw% right, %placeholder%
GuiControl, +BackgroundTrans, TheInfoLeft
GuiControl, +BackgroundTrans, TheInfoRight
GuiControl, +BackgroundTrans, TheInfoCenter
Gui, +Resize +AlwaysOnTop +ToolWindow -Caption +LastFound
; https://www.autohotkey.com/boards/viewtopic.php?t=77668
Gui, +E0x02000000 +E0x00080000 ; WS_EX_COMPOSITED & WS_EX_LAYERED => Double Buffer
Gui, show, x1414 y%gy% w500 h24 NoActivate
            

hwnd_info_bar := WinExist()
WinMove, ahk_id %hwnd_info_bar%, , 0, gy, %A_ScreenWidth%, gh
WinMove, WinTitle, WinText, X, Y, [Width, Height, ExcludeTitle, ExcludeText]

WinSet, Style, -0xC40000, ahk_id %hwnd_info_bar%

; https://www.autohotkey.com/board/topic/30503-turn-any-application-into-an-appbar/
reserve_space_on_top(height) {
    VarSetCapacity( APPBARDATA , (cbAPPBARDATA := A_PtrSize == 8 ? 48 : 36), 0 )
    Off := NumPut(  cbAPPBARDATA, APPBARDATA, "Ptr"  )
    Off := NumPut(           hAB,      Off+0, "Ptr"  )
    Off := NumPut(           ABM,      Off+0, "UInt" )
    Off := NumPut(             1,      Off+0, "UInt" ) 
    Off := NumPut(             0,      Off+0, "Int"  ) 
    Off := NumPut(             0,      Off+0, "Int"  ) 
    Off := NumPut(             0,      Off+0, "Int"  ) 
    Off := NumPut(        height,      Off+0, "Int"  )
    Off := NumPut(             1,      Off+0, "Ptr"  )

    DllCall("Shell32.dll\SHAppBarMessage", UInt,(ABM_NEW:=0x0)     , Ptr,&APPBARDATA )
    DllCall("Shell32.dll\SHAppBarMessage", UInt,(ABM_QUERYPOS:=0x2), Ptr,&APPBARDATA )
    DllCall("Shell32.dll\SHAppBarMessage", UInt,(ABM_SETPOS:=0x3)  , Ptr,&APPBARDATA )
}
reserve_space_on_top(gh)

SetTimer, update_info_fs, 250
update_info_fs() {
    global hwnd_info_bar, SCREEN_WIDTH, SCREEN_HEIGHT
    
    WinGetClass, clazz, A
    if (clazz == "WorkerW")
        return
    if (clazz == "Progman")
        return

    WinGetPos x, y, w, h, A
    WinGetPos, , winy, , , ahk_id %hwnd_info_bar%
    if (x == 0 && y == 0 && w == 3840 && h == 2160) {
        if (winy >= 0) {
            WinMove, ahk_id %hwnd_info_bar%, , , -1337
        }
    } else {
        if (winy < 0) {
            WinMove, ahk_id %hwnd_info_bar%, , , 0
        }
    }
    
}

get_desktop() {
    RegRead, cur, HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\SessionInfo\1\VirtualDesktops, CurrentVirtualDesktop
    RegRead, all, HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VirtualDesktops, VirtualDesktopIDs
    desk := floor(InStr(all,cur) / strlen(cur))
    return "🖥️ " . desk
}

get_clockodo() {
    DetectHiddenWindows, On
        WinGetTitle, t, Clockodo* ahk_class Chrome_WidgetWin_1 ahk_exe brave.exe
    DetectHiddenWindows, Off

    t := Trim(StrReplace(t, "Clockodo*"))
    if (t == "") {
        t := "00:00:00"
    }
    return "⏱ " . t
}

string_external_timer := ""
SetTimer, refresh_external_timer, 10000
refresh_external_timer()
refresh_external_timer() {
    global string_external_timer
    static path := A_Temp . "\external_timer.txt"
    FileRead, s, %path%
    string_external_timer := "⌚ " . Trim(s)
}




get_spotify_song() {
    static title, hwnd := false, force := true
    mode := "⏸"
    
    DetectHiddenWindows, On
        t := ""
        if (hwnd) {
            WinGetTitle, t, ahk_id %hwnd%
            t := Trim(t)
            if (t == "") {
                force := true
            }
        }
        if (force) {
            WinGet, id, list
            Loop, %id% {
                this_ID := id%A_Index%
                WinGetTitle, tmp, ahk_id %this_ID%
                tmp := Trim(tmp)
                WinGetClass, clazz, ahk_id %this_ID%
                if (clazz == "Chrome_WidgetWin_0" && tmp != "" && !InStr(tmp, "Default IME")) {
                    t := tmp
                    hwnd := this_ID
                    force := false
                }
            }
        }
    DetectHiddenWindows, Off
    
    if (t != "Spotify Premium" && t != "Spotify") {
        title := t
        if (StrLen(title) > 80) {
            title := SubStr(title, 1, 80) . " ..."
        }
        mode := "▶"
    }
    if (t == "") {
        return "🎶 Spotify not found 🎵"
    }
    if (title == "") {
        title := "No recent song"
    }
    return mode . " " . title
}


update_info() {
    global string_external_timer, string_weather, string_cpu_time
    
    info_left := " [ " . get_desktop() . " ]    [ " . get_spotify_song() . " ]"
    GuiControl,, TheInfoLeft, %info_left%

    info_center := "[ " . get_date() . "  |  " . get_time() . " ]  🏃‍♂️  [ " . get_clockodo() . "  |  " . string_external_timer . " ]         "
    GuiControl,, TheInfoCenter, %info_center%
    
    info_right := string_weather . "    [ " . get_disk_space_free_gb("C") . "  |  " . get_ram_usage() . "  |  " . string_cpu_time . " ]    [ " . get_volume() . " ] "
    GuiControl,, TheInfoRight, %info_right%
    
    Winset, Alwaysontop, ahk_id %hwnd_info_bar%, A
}
update_info()
SetTimer, update_info, 1000

info_bar_mouse_move(button) {
    global hwnd_info_bar
    MouseGetPos, x, y, hwnd_m
    if (hwnd_m != hwnd_info_bar) {
        return
    }
    MouseClick, %button%, , , , 1, U
    MouseClick, %button%, x, 25, , 1, D
}

~LButton::info_bar_mouse_move("L")
~MButton::info_bar_mouse_move("M")
~RButton::info_bar_mouse_move("R")

~#^Left::
~#^Right::
    Sleep, 100
    update_info()
Return

; #######################
; #      BENCHMARK      #
; #######################
; Critical, On
; i := 0
; ROUNDS := 1
; s := ""
; START := A_TickCount
; while true {
;     ; SoundGet, volume
;     ; SoundGet, muted, , MUTE
;     update_info()
    
;     i++
;     if (i > ROUNDS) {
;         break
;     }
; }
; total := A_TickCount - START
; one := total / ROUNDS

; MsgBox, DONE.      %total% ms;      %one% ms
; Critical, Off

