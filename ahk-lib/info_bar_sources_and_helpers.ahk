; #include ../ahk-lib/change_any_tray_icon.ahk

space_fill(t, l:=3, f:=" ") {
    r := l-StrLen(t)
    loop, %r% {
        t := f . t
    }
    return t
}
space_fill_right(t, l:=3, f:=" ") {
    r := l-StrLen(t)
    loop, %r% {
        t := t . f
    }
    return t
}






; # # # # # BATTERY # # # # # BATTERY # # # # # BATTERY # # # # # BATTERY # # # # # BATTERY # # # # # BATTERY # # # # #
; BATTERY # # # # # BATTERY # # # # # BATTERY # # # # # BATTERY # # # # # BATTERY # # # # # BATTERY # # # # # BATTERY #
; # # # # # BATTERY # # # # # BATTERY # # # # # BATTERY # # # # # BATTERY # # # # # BATTERY # # # # # BATTERY # # # # #
; BATTERY # # # # # BATTERY # # # # # BATTERY # # # # # BATTERY # # # # # BATTERY # # # # # BATTERY # # # # # BATTERY #
; # # # # # BATTERY # # # # # BATTERY # # # # # BATTERY # # # # # BATTERY # # # # # BATTERY # # # # # BATTERY # # # # #


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







; # # # # # CPU TIME # # # # # CPU TIME # # # # # CPU TIME # # # # # CPU TIME # # # # # CPU TIME # # # # # CPU TIME # # # # #
; CPU TIME # # # # # CPU TIME # # # # # CPU TIME # # # # # CPU TIME # # # # # CPU TIME # # # # # CPU TIME # # # # # CPU TIME #
; # # # # # CPU TIME # # # # # CPU TIME # # # # # CPU TIME # # # # # CPU TIME # # # # # CPU TIME # # # # # CPU TIME # # # # #
; CPU TIME # # # # # CPU TIME # # # # # CPU TIME # # # # # CPU TIME # # # # # CPU TIME # # # # # CPU TIME # # # # # CPU TIME #
; # # # # # CPU TIME # # # # # CPU TIME # # # # # CPU TIME # # # # # CPU TIME # # # # # CPU TIME # # # # # CPU TIME # # # # #

; https://www.reddit.com/r/AutoHotkey/comments/liicqk/real_total_system_cpu_usage_from_within_an/gn4881q/?context=3
GetSystemTimes(ByRef IdleTime) {
   DllCall("GetSystemTimes", "Int64P", IdleTime, "Int64P", KernelTime, "Int64P", UserTime)
   Return KernelTime + UserTime
}

get_cpu_time() {
    static cpu_total_a, cpu_total_b, cpu_idle_a, cpu_idle_b
    static next := -1, last := ""
    if (A_TickCount < next) {
        return last
    }
    next := A_TickCount + 1000
    cpu_total_b     := GetSystemTimes(cpu_idle_b)
    cpu_time        := round(100*(1 - (cpu_idle_b - cpu_idle_a)/(cpu_total_b - cpu_total_a)))
    cpu_total_a     := cpu_total_b
    cpu_idle_a      := cpu_idle_b
    return last := "🧠" . space_fill(cpu_time, 3) . "%"
}







; # # # # # RAM USAGE # # # # # RAM USAGE # # # # # RAM USAGE # # # # # RAM USAGE # # # # # RAM USAGE # # # # # RAM USAGE # # # # # #
; RAM USAGE # # # # # RAM USAGE # # # # # RAM USAGE # # # # # RAM USAGE # # # # # RAM USAGE # # # # # RAM USAGE # # # # # RAM USAGE #
; # # # # # RAM USAGE # # # # # RAM USAGE # # # # # RAM USAGE # # # # # RAM USAGE # # # # # RAM USAGE # # # # # RAM USAGE # # # # # #
; RAM USAGE # # # # # RAM USAGE # # # # # RAM USAGE # # # # # RAM USAGE # # # # # RAM USAGE # # # # # RAM USAGE # # # # # RAM USAGE #
; # # # # # RAM USAGE # # # # # RAM USAGE # # # # # RAM USAGE # # # # # RAM USAGE # # # # # RAM USAGE # # # # # RAM USAGE # # # # # #

; https://autohotkey.com/board/topic/35785-find-system-memory-ram/?p=225248
get_ram_usage() {
    VarSetCapacity(memorystatus, 4+4+4+4+4+4+4+4)
    DllCall("kernel32.dll\GlobalMemoryStatus", "uint", &memorystatus)
    value = 0 
    loop, 4
        value := value+( *( ( &memorystatus+4 )+( a_Index-1 ) ) << ( 8* ( a_Index-1 ) ) )
    return "💾" . space_fill(value) . "%"
}






; # # # # # DATE & TIME # # # # # DATE & TIME # # # # # DATE & TIME # # # # # DATE & TIME # # # # # DATE & TIME # # # # # DATE & TIME # # # # # # #
; DATE & TIME # # # # # DATE & TIME # # # # # DATE & TIME # # # # # DATE & TIME # # # # # DATE & TIME # # # # # DATE & TIME # # # # # DATE & TIME #
; # # # # # DATE & TIME # # # # # DATE & TIME # # # # # DATE & TIME # # # # # DATE & TIME # # # # # DATE & TIME # # # # # DATE & TIME # # # # # # #
; DATE & TIME # # # # # DATE & TIME # # # # # DATE & TIME # # # # # DATE & TIME # # # # # DATE & TIME # # # # # DATE & TIME # # # # # DATE & TIME #
; # # # # # DATE & TIME # # # # # DATE & TIME # # # # # DATE & TIME # # # # # DATE & TIME # # # # # DATE & TIME # # # # # DATE & TIME # # # # # # #

get_date() {
    global get_date_time_clocks
    static w := {1: "So", 2: "Mo", 3: "Di", 4: "Mi", 5: "Do", 6: "Fr", 7: "Sa"}
    FormatTime, d,, yyyy-MM-dd
    return "📅 " w[A_WDay] . " " . d
}

get_time_icon() {
    static e := ["🕛", "🕧", "🕐", "🕜", "🕑", "🕝", "🕒", "🕞", "🕓", "🕟", "🕔", "🕠", "🕕", "🕡", "🕖", "🕢", "🕗", "🕣", "🕘", "🕤", "🕙", "🕥", "🕚", "🕦", "🕛", "🕧", "🕐"]
    FormatTime, h,, h
    FormatTime, m,, m
    c := 1 + 2 * h + round(m / 30)
    return e[c]
}

get_time() {
    FormatTime, s,, ss
    if (Mod(s, 2)) {
        FormatTime, t,, HH:mm:ss
    } else {
        FormatTime, t,, HH mm ss
    }
    return t
}






; # # # # VOLUME # # # # VOLUME # # # # VOLUME # # # # VOLUME # # # # VOLUME # # # # VOLUME # # # #
; VOLUME # # # # VOLUME # # # # VOLUME # # # # VOLUME # # # # VOLUME # # # # VOLUME # # # # VOLUME #
; # # # # VOLUME # # # # VOLUME # # # # VOLUME # # # # VOLUME # # # # VOLUME # # # # VOLUME # # # #
; VOLUME # # # # VOLUME # # # # VOLUME # # # # VOLUME # # # # VOLUME # # # # VOLUME # # # # VOLUME #
; # # # # VOLUME # # # # VOLUME # # # # VOLUME # # # # VOLUME # # # # VOLUME # # # # VOLUME # # # #

get_volume() {
    static next = -1, vol, muted
    if (A_TickCount >= next) {
        next := A_TickCount + 5
        SoundGet, vol
        SoundGet, muted, , MUTE
    }
    
    if (muted = "On") {
        emoji := "🔇"
    } else if (vol < 10) {
        emoji := "🔈"
    } else if (vol < 30) {
        emoji := "🔉"
    } else {
        emoji := "🔊"
    }
    return emoji . space_fill(round(vol), 3) . "%"
}





; # # # # # # DISK SPACE # # # # # # DISK SPACE # # # # # # DISK SPACE # # # # # # DISK SPACE # # # # # # DISK SPACE # # # # # # DISK SPACE #
; DISK SPACE # # # # # # DISK SPACE # # # # # # DISK SPACE # # # # # # DISK SPACE # # # # # # DISK SPACE # # # # # # DISK SPACE # # # # # # #
; # # # # # # DISK SPACE # # # # # # DISK SPACE # # # # # # DISK SPACE # # # # # # DISK SPACE # # # # # # DISK SPACE # # # # # # DISK SPACE #
; DISK SPACE # # # # # # DISK SPACE # # # # # # DISK SPACE # # # # # # DISK SPACE # # # # # # DISK SPACE # # # # # # DISK SPACE # # # # # # #
; # # # # # # DISK SPACE # # # # # # DISK SPACE # # # # # # DISK SPACE # # # # # # DISK SPACE # # # # # # DISK SPACE # # # # # # DISK SPACE #

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







; # # # # WEATHER # # # # WEATHER # # # # WEATHER # # # # WEATHER # # # # WEATHER # # # # WEATHER # # # # #
; WEATHER # # # # WEATHER # # # # WEATHER # # # # WEATHER # # # # WEATHER # # # # WEATHER # # # # WEATHER #
; # # # # WEATHER # # # # WEATHER # # # # WEATHER # # # # WEATHER # # # # WEATHER # # # # WEATHER # # # # #
; WEATHER # # # # WEATHER # # # # WEATHER # # # # WEATHER # # # # WEATHER # # # # WEATHER # # # # WEATHER #
; # # # # WEATHER # # # # WEATHER # # # # WEATHER # # # # WEATHER # # # # WEATHER # # # # WEATHER # # # # #

http_get(url) {
    whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
    whr.SetTimeouts(2000, 2000, 2000, 2000)
    w.SetRequestHeader("Content-Type", "application/x-www-form-urlencoded; charset=UTF-8")
    whr.Open("GET", url, true)
    whr.Send()
    whr.WaitForResponse()
    return whr.ResponseText
}

get_weather() {
    static weather := "", next := -1
    if (A_TickCount < next) {
        return weather
    }
    try {
        weather := http_get("https://wttr.in/?format=2")
        weather := StrSplit(weather, "km/h")[1]
        weather := StrReplace(StrReplace(StrReplace(weather, "  ", " "), "   ", " "), " ", "  ")
        weather := StrReplace(StrReplace(weather, "🌡", "|  🌡 "), "🌬", "|  🌬 ")
        next := A_TickCount + 1000 * 60 * 15
        return weather
    } catch {
        next := A_TickCount + 1000 * 60
        return " wttr.in down :< "
    }
}





; # # # # DESKTOP # # # # DESKTOP # # # # DESKTOP # # # # DESKTOP # # # # DESKTOP # # # # DESKTOP # # # # #
; DESKTOP # # # # DESKTOP # # # # DESKTOP # # # # DESKTOP # # # # DESKTOP # # # # DESKTOP # # # # DESKTOP #
; # # # # DESKTOP # # # # DESKTOP # # # # DESKTOP # # # # DESKTOP # # # # DESKTOP # # # # DESKTOP # # # # #
; DESKTOP # # # # DESKTOP # # # # DESKTOP # # # # DESKTOP # # # # DESKTOP # # # # DESKTOP # # # # DESKTOP #
; # # # # DESKTOP # # # # DESKTOP # # # # DESKTOP # # # # DESKTOP # # # # DESKTOP # # # # DESKTOP # # # # #

get_desktop() {
    RegRead, cur, HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\SessionInfo\1\VirtualDesktops, CurrentVirtualDesktop
    RegRead, all, HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VirtualDesktops, VirtualDesktopIDs
    desk := floor(InStr(all,cur) / strlen(cur))
    return "🖥️ " . desk
}





; # # # # TIMERS # # # # TIMERS # # # # TIMERS # # # # TIMERS # # # # TIMERS # # # # TIMERS # # # #
; TIMERS # # # # TIMERS # # # # TIMERS # # # # TIMERS # # # # TIMERS # # # # TIMERS # # # # TIMERS #
; # # # # TIMERS # # # # TIMERS # # # # TIMERS # # # # TIMERS # # # # TIMERS # # # # TIMERS # # # #
; TIMERS # # # # TIMERS # # # # TIMERS # # # # TIMERS # # # # TIMERS # # # # TIMERS # # # # TIMERS #
; # # # # TIMERS # # # # TIMERS # # # # TIMERS # # # # TIMERS # # # # TIMERS # # # # TIMERS # # # #

get_external_timer_diff() {
    static path := A_Temp . "\external_timer_diff.txt"
    FileRead, s, %path%
    return "⌚ " . Trim(s)
}

get_external_timer_today() {
    static path := A_Temp . "\external_timer_today.txt"
    FileRead, s, %path%
    return Trim(s)
}

timer_time_to_secs(t) {
    h := 0
    m := 0
    s := 0
    for i, p in StrSplit(t, ":") {
        if (i == 1) {
            h := p
        }
        if (i == 2) {
            m := p
        }
        if (i == 3) {
            s := p
        }
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
    
    return "⏱ " . weird . timer_secs_to_time(total)
}




; # # # # MUSIC # # # # MUSIC # # # # MUSIC # # # # MUSIC # # # # MUSIC # # # # MUSIC # # # #
; MUSIC # # # # MUSIC # # # # MUSIC # # # # MUSIC # # # # MUSIC # # # # MUSIC # # # # MUSIC #
; # # # # MUSIC # # # # MUSIC # # # # MUSIC # # # # MUSIC # # # # MUSIC # # # # MUSIC # # # #
; MUSIC # # # # MUSIC # # # # MUSIC # # # # MUSIC # # # # MUSIC # # # # MUSIC # # # # MUSIC #
; # # # # MUSIC # # # # MUSIC # # # # MUSIC # # # # MUSIC # # # # MUSIC # # # # MUSIC # # # #

get_spotify_song() {
    static hwnd := false, force := true
    static TITLE_LEN_MAX := 65
    
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
                WinGet, exe, ProcessName, ahk_id %this_ID%
                if (exe == "Spotify.exe") {
                    WinGetClass, clazz, ahk_id %this_ID%
                    if ((clazz == "Chrome_WidgetWin_0" || clazz == "Chrome_WidgetWin_1")) {
                        WinGetTitle, tmp, ahk_id %this_ID%
                        tmp := Trim(tmp)
                        if (tmp != "" && !InStr(tmp, "Default IME")) {
                            t := tmp
                            hwnd := this_ID
                            force := false
                        }
                    }
                }
            }
        }
    DetectHiddenWindows, Off
    
    if (t != "Spotify Premium" && t != "Spotify Free" && t != "Spotify") {
        spotify_title := t
        if (StrLen(spotify_title) > TITLE_LEN_MAX) {
            spotify_title := SubStr(spotify_title, 1, TITLE_LEN_MAX) . " ..."
        }
        spotify_is_playing := true
    } else {
        return false
    }
    if (t == "" || spotify_title == "") {
        return false
    }
    return spotify_title
}

get_dancing(dance) {
    static dancer := {0: "┏( ^‿^)┛", 1: " ┏(^‿^)┓", 2: "┗(^‿^ )┓", 3: "┏(^‿^)┓"}
    if (!dance)
        return " ┏(＞︿＜)┓ "
    return last := dancer[Mod(Floor(A_TickCount / 1000), 4)]
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
