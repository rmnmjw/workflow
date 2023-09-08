#MaxHotkeysPerInterval 200
CoordMode, Mouse, Screen


; #include WebSocket.ahk



; NETWORK DATA VIA WEBSOCKET
; ib_network_counter := 0
; ib_network_data_default := "? 🔽   ?.?b 🔼   ?.?b"
; ib_network_data    := ib_network_data_default
; ib_network_data_get() {
;     global ib_network_data
;     return ib_network_data
; }
; class NetworkViaWebsocket extends WebSocket {
    
;     OnMessage(Event) {
;         global ib_network_data, ib_network_counter
;         ib_network_counter := 10
;         ib_network_data := Event.data
;     }
    
;     OnClose(Event) {
;         global ib_network_data, ib_network_counter, ib_network_data_default
;         ib_network_counter := 3
;         this.Disconnect()
;         ib_network_data := ib_network_data_default
;         ; MsgBox, WebSocket connection closed
;     }
    
;     OnError(Event) {
;         global ib_network_data, ib_network_counter, ib_network_data_default
;         ib_network_counter := 3
;         ib_network_data := ib_network_data_default
;         ; MsgBox, WebSocket connection error
;     }
; }





; WEATHER DATA VIA WEBSOCKET
; ib_weather_counter := 0
; ib_weather_data_default := "❓ +??°C ??km/h ❓?.?mm ❓????hPa"
; ib_weather_data := ib_weather_data_default
; ib_weather_data_sunrise_default := "☀ ??:?? 🌙 ??:??"
; ib_weather_data_sunrise := ib_weather_data_sunrise_default
; ib_weather_data_sunrise_get()
; {
;     global ib_weather_data_sunrise
;     return ib_weather_data_sunrise
; }
; ib_weather_data_get() {
;     global ib_weather_data
;     return ib_weather_data
; }
; class WeatherViaWebsocket extends WebSocket {
    
;     OnMessage(Event) {
;         global ib_weather_data, ib_weather_data_sunrise, ib_weather_counter
        
;         ib_weather_counter := 10 * 60
        
;         parts := StrSplit(Event.data, "|||")
                
;         ib_weather_data         := parts[1]
;         ib_weather_data_sunrise := parts[2]
;     }
    
;     OnClose(Event) {
;         global ib_weather_data, ib_weather_data_sunrise, ib_weather_counter, ib_weather_data_sunrise_default, ib_weather_data_default
;         this.Disconnect()
;         ib_weather_counter := 3
;         ib_weather_data := ib_weather_data_default
;         ib_weather_data_sunrise := ib_weather_data_sunrise_default
;         ; MsgBox, WebSocket connection closed
;     }
    
;     OnError(Event) {
;         global ib_weather_data, ib_weather_data_sunrise, ib_weather_counter, ib_weather_data_sunrise_default, ib_weather_data_default
;         ib_weather_counter := 3
;         ib_weather_data := ib_weather_data_default
;         ib_weather_data_sunrise := ib_weather_data_sunrise_default
;         ; MsgBox, WebSocket connection error
;     }
; }




; websocket_reconnector()
; {
;     global ib_network_counter, ib_network_data, ib_network_data_default
;     global ib_weather_counter, ib_weather_data, ib_weather_data_sunrise, ib_weather_data_default
    
    
;     ib_network_counter -= 1
;     ib_weather_counter -= 1
    
;     ; ToolTip, %ib_network_counter% -- %ib_weather_counter%
    
    
;     if (ib_network_counter <= 0 && ib_network_data == ib_network_data_default)
;     {
;         ib_network_counter := 10
;         new NetworkViaWebsocket("ws://localhost:13254")
;     }
    
;     if (ib_weather_counter <= 0 && ib_weather_data == ib_weather_data_default)
;     {
;         ib_weather_counter := 10
;         new WeatherViaWebsocket("ws://localhost:13255")
;     }
; }
; websocket_reconnector()
; SetTimer, websocket_reconnector, 1000



















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

get_cpu_time() {
    static cpu_total_a, cpu_total_b, cpu_idle_a, cpu_idle_b
    cpu_total_b := GetSystemTimes(cpu_idle_b)
    cpu_time    := round(100*(1 - (cpu_idle_b - cpu_idle_a)/(cpu_total_b - cpu_total_a)))
    cpu_time    := "🧠" . space_fill(cpu_time, 3) . "%"
    cpu_total_a := cpu_total_b
    cpu_idle_a  := cpu_idle_b
    return cpu_time
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

set_volume(v) {
    static last_value  := 0
    static last_time   := A_TickCount
    static value_count := 0
    
    SoundGetWaveVolume, volume
    
    if (last_value != v || (last_time + 200) < A_TickCount)
        value_count := 0
    value_count := Min(value_count+1, 7)
    vol := v * Min(2 ** (value_count**2), 32) * Max(volume/100, 0.1)
    
    if (v > 0)
        vol := "+" . vol
    vol := vol . "%"

    SoundSetWaveVolume, %vol%
    SetTimer, update_info, Off
    update_info()
    SetTimer, update_info, 1000
    
    last_value := v
    last_time  := A_TickCount
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
ib_foobar_window_id = false
get_foobar_id_runner() {
    global ib_foobar_window_id
    DetectHiddenWindows, On
    WinGet, hwnd, id, ahk_class {97E27FAA-C0B3-4b8e-A693-ED7881E99FC1} ahk_exe foobar2000.exe
    DetectHiddenWindows, Off
    if (hwnd == "") {
        ib_foobar_window_id := false
    } else {
        ib_foobar_window_id := hwnd
    }
}
; get_foobar_id_runner()

SetTimer, get_foobar_id_runner, 5000
get_foobar_song() {
    global ib_foobar_window_id
    if (!ib_foobar_window_id) {
        return "  |  🟩 [  :  /  :  ] -"
    }
    DetectHiddenWindows, On
    WinGetTitle, t, ahk_id %ib_foobar_window_id%
    DetectHiddenWindows, Off
    
    t := Trim(t)
    if (SubStr(t, 1, 10) == "foobar2000")
        return ""
    if (t == "")
        return ""
    l := StrLen(t)
    t := SubStr(t, 1, l-12)
    return "  |  " . t
}

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


; get_weather_data := ""
; get_weather_data_sun := ""
; get_sunrise_sunset() {
;     global get_weather_data_sun
;     return get_weather_data_sun
; }
; get_weather() {
;     global get_weather_data
;     return get_weather_data
; }
; ib_refresh_weather() {
;     global get_weather_data, get_weather_data_sun
;     WEATHER_TEMP_FILE := A_Temp . "\infobar_weather.ini"
;     IniRead, wu, %WEATHER_TEMP_FILE%, wttr, updated, Default
    
;     IniRead, ww, %WEATHER_TEMP_FILE%, wttr, weather, Default
;     IniRead, st, %WEATHER_TEMP_FILE%, wttr, sunrise_sunset, Default
;     if (wu == 0) {
;         ww := "?" . ww
;     } else {
;         wu -= 1
;         IniWrite, %wu%, %WEATHER_TEMP_FILE%, wttr, updated
;     }
;     get_weather_data := ww
;     get_weather_data_sun := st
; }
; ib_refresh_weather()
; SetTimer, ib_refresh_weather, 300000 ; 5 minutes

SCREEN_SCALE_FACTOR := A_ScreenDPI / 96
SCREEN_WIDTH  :=  A_ScreenWidth / SCREEN_SCALE_FACTOR
SCREEN_HEIGHT := A_ScreenHeight / SCREEN_SCALE_FACTOR

Gui, Color, 101010, white
Gui, Font, s11L, Fira Code
placeholder := "~" . space_fill("", l:=272, f:="X") . "~"
gw := SCREEN_WIDTH
gh := 24
gy := A_ScreenHeight-gh
ToolTip,  %w%
Gui, add, text, vTheInfo cFFFFFF y-2 x2 w%gw%, %placeholder%
GuiControl, +Center, TheInfo
Gui, +Resize +AlwaysOnTop +ToolWindow -Caption +LastFound
; https://www.autohotkey.com/boards/viewtopic.php?t=77668
Gui, +E0x02000000 +E0x00080000 ; WS_EX_COMPOSITED & WS_EX_LAYERED => Double Buffer
Gui, show, x1414 y%gy% w500 h24 NoActivate

hwnd_info_bar := WinExist()
WinMove, ahk_id %hwnd_info_bar%, , 0, gy, %A_ScreenWidth%, 15

WinSet, Style, -0xC40000, ahk_id %hwnd_info_bar%

; https://www.autohotkey.com/board/topic/30503-turn-any-application-into-an-appbar/
reserve_space_on_bottom(height) {
    VarSetCapacity( APPBARDATA , (cbAPPBARDATA := A_PtrSize == 8 ? 48 : 36), 0 )
    Off :=  NumPut(  cbAPPBARDATA, APPBARDATA, "Ptr" )
    Off :=  NumPut( hAB, Off+0, "Ptr" )
    Off :=  NumPut( ABM, Off+0, "UInt" )
    Off :=  NumPut(   3, Off+0, "UInt" ) 
    Off :=  NumPut(  GX, Off+0, "Int" ) 
    Off :=  NumPut(  A_ScreenHeight-height, Off+0, "Int" ) 
    Off :=  NumPut(  GW, Off+0, "Int" ) 
    Off :=  NumPut(  height, Off+0, "Int" )
    ;MsgBox % Off - &APPBARDATA
    Off :=  NumPut(   1, Off+0, "Ptr" )

    DllCall("Shell32.dll\SHAppBarMessage", UInt,(ABM_NEW:=0x0)     , Ptr,&APPBARDATA )
    DllCall("Shell32.dll\SHAppBarMessage", UInt,(ABM_QUERYPOS:=0x2), Ptr,&APPBARDATA )
    DllCall("Shell32.dll\SHAppBarMessage", UInt,(ABM_SETPOS:=0x3)  , Ptr,&APPBARDATA )
}
reserve_space_on_bottom(0)

; SetTimer, update_info_top, 250
; update_info_top() {
;     global hwnd_info_bar
;     WinSet, alwaysontop, on, ahk_id %hwnd_info_bar%
; }

SetTimer, update_info_fs, 250
update_info_fs() {
    global hwnd_info_bar, SCREEN_WIDTH, SCREEN_HEIGHT
    
    
    WinGetClass, clazz, A
    if (clazz == "WorkerW")
        return
    if (clazz == "Progman")
        return
    

    WinGetPos x, y, w, h, A
    if (x == -12 && y == 40 && w == 3864 && h == 2108) {
        WinGetPos, , winy, , , ahk_id %hwnd_info_bar%
        if (winy >= 0) {
            ToolTip, "HIDE"
            info_visibility("hide")
        }
    } else {
        WinGetPos, , winy, , , ahk_id %hwnd_info_bar%
        if (winy < 0) {
            ToolTip, "SHOW"
            info_visibility("show")
        }
    }
    
}

get_desktop() {
    global desktop_current
    desk := desktop_current + 1
    return "🖥️ " . space_fill(desk, 2)
}

seconds_to_minutes_and_hours(secs) {
    hours := floor(secs / 60 / 60)
    mins := floor(secs / 60) - hours * 60
    secs := secs - hours * 60 * 60 - mins * 60
    
    if (hours < 10) {
        hours := "0" . hours
    }
    
    hours := hours . ":"
    
    if (mins < 10) {
        mins := "0" . mins
    }
    mins := mins . ":"
    
    if (secs < 10) {
        secs := "0" . secs
    }
    
    return hours . mins . secs
}

ib_start_alarm_set := 0
ib_alarm_toggle := true
get_alarm() {
    global ib_start_alarm_set, ib_alarm_toggle
    if (!ib_start_alarm_set) {
        return "  |  ⏰   :  :  "
    }
    rem_secs := floor(ib_start_alarm_set - A_TickCount / 1000)
    
    if (rem_secs <= 0) {
        if (ib_alarm_toggle) {
            Gui, Color, red, white
        } else {
            Gui, Color, 101010, white
        }
        ib_alarm_toggle := !ib_alarm_toggle
        rem_secs := 0
        
        if (ib_alarm_toggle) {
            return "  |  ⏰ XX:XX:XX"
        } else {
            return "  |  ⏰   :  :  "
        }
    } else {
        return "  |  ⏰ " . seconds_to_minutes_and_hours(rem_secs)
    }
}
ib_start_alarm() {
    global ib_start_alarm_set, ib_alarm_toggle
    InputBox, minute_input, Start Alarm, Minutes:, , 300, 150
    ib_alarm_toggle := true
    if (minute_input == "") {
        ib_start_alarm_set := 0
    } else {
        ib_start_alarm_set := floor(A_TickCount / 1000 + minute_input * 60)
    }
    Gui, Color, 101010, white
    update_info()
}

info_alert  := false
info_stable := ""


update_info() {
    global info_alert, info_stable, hwnd_info_bar
    
    
    
    if (info_alert) {
        info := "*** " . info_alert . " ***"
        GuiControl,, TheInfo, %info%
    } else {
        info_stable := ""
        info_stable .= get_alarm()
        info_stable .= "  |  " . get_date()
        info_stable .= "  |  " . get_time()
        ; info_stable .= "  |  " . ib_weather_data_sunrise_get()
        info_stable .= "  |  " . get_cpu_time()
        info_stable .= "  |  " . get_ram_usage()
        info_stable .= "  |  " . get_disk_space_free_gb("C")
        ; info_stable .= "  |  " . get_disk_space_free_gb("D")
        ; info_stable .= "  |  " . get_battery_status()
        ; info_stable .= "  |  " . ib_weather_data_get()
        ; info_stable .= "  |  " . ib_network_data_get()
        
        
        update_info_unstable()
    }
    
    Winset, Alwaysontop, ahk_id %hwnd_info_bar%, A
}
update_info()
SetTimer, update_info, 1000

update_info_unstable_2() {
    global info_stable
    info := ""
    ; info .= get_desktop()
    info .= info_stable
    info .= "  |  " . get_volume()
    ; info .= get_foobar_song()
    GuiControl,, TheInfo, %info%
}

update_info_unstable(slow:=0) {
    if (slow != 0) {
        Sleep, %slow%
    }
    update_info_unstable_2()
}

info_visibility(mode:="toggle") {
    global hwnd_info_bar, gy
    
    if (mode == "toggle") {
        WinGetPos, , y, , , ahk_id %hwnd_info_bar%
        y := y == -1337 ? 1065 : -1337
    } else if (mode == "show") {
        y := 1065
    } else if (mode == "hide") {
        y := -1337
    }
    
    WinMove, ahk_id %hwnd_info_bar%, , , %gy%
}









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














; !^+ö::ib_start_alarm()

; Volume_Up::
;     Critical, On
;     SoundSet, +2
;     update_info_unstable()
;     Critical, Off
; return

; Volume_Down::
;     Critical, On
;     SoundSet, -2
;     update_info_unstable()
;     Critical, Off
; return

; Volume_Mute::
;     Critical, On
;     Send, {Volume_Mute}
;     update_info_unstable()
;     Critical, Off
; return

; Media_Play_Pause::
; #<::
;     Critical, On
;     Send, {Media_Play_Pause}
;     update_info_unstable()
;     Critical, Off
; return

; Media_Next::
;     Critical, On
;     Send, {Media_Next}
;     update_info_unstable()
;     Critical, Off
; return

; Media_Prev::
;     Critical, On
;     Send, {Media_Prev}
;     update_info_unstable()
;     Critical, Off
; return

; Media_Stop::
;     Critical, On
;     Send, {Media_Stop}
;     update_info_unstable()
;     Critical, Off
; return

info_bar_mouse_move(button) {
    global hwnd_info_bar
    MouseGetPos, x, y, hwnd_m
    if(hwnd_m != hwnd_info_bar){
        return
    }
    MouseClick, %button%, , , , 1, U
    MouseClick, %button%, x, 16, , 1, D
}


; ~LButton::info_bar_mouse_move("L")
; ~MButton::info_bar_mouse_move("M")
; ~RButton::info_bar_mouse_move("R")


; # # # # # # # # # # # # # # # # # # # # # #
; #                                         #
; #      Volume control via mouse wheel     #
; #                                         #
; # # # # # # # # # # # # # # # # # # # # # #

ib_volume_scroll(dir) {
    Critical, On
        global hwnd_info_bar, get_volume_volume_virtual_delta, get_volume_volume
        MouseGetPos, , , id, control
        WinGetClass, clazz, ahk_id %id%
        if (id == hwnd_info_bar || clazz == "Shell_TrayWnd") {
            if (dir > 0) {
                SoundSet, +2
                get_volume_volume_virtual_delta += 2
                if (get_volume_volume_virtual_delta + get_volume_volume > 100) {
                    get_volume_volume_virtual_delta := 0
                    get_volume_volume := 100
                }
            } else if (dir < 0) {
                SoundSet, -2
                get_volume_volume_virtual_delta -= 2
                if (get_volume_volume_virtual_delta + get_volume_volume < 0) {
                    get_volume_volume_virtual_delta := 0
                    get_volume_volume := 0
                }
            }
            update_info_unstable()
        }
    Critical, Off
}

~WheelDown::ib_volume_scroll(-1)
~WheelUp::ib_volume_scroll(1)

~!^+Up::update_info_unstable()
~!^+Down::update_info_unstable()

#If GetKeyState("CapsLock", "P")
    ~WheelUp::
        update_info_unstable(20)
    return
    ~WheelDown::
        update_info_unstable(20)
    return

#If WinActive("ahk_class Windows.UI.Core.CoreWindow ahk_exe ShellExperienceHost.exe")
    ~WheelDown::
        Critical, On
            update_info_unstable()
        Critical, Off
    Return
    ~WheelUp::
        Critical, On
            update_info_unstable()
        Critical, Off
    Return
#If
