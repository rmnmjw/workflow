#include lib/info_bar_sources_and_helpers.ahk

SHOW_AT_TOP      := true
COLOR_BACKGROUND := "213841"
COLOR_FONT       := "E3E3E3"

Gui, Color, %COLOR_BACKGROUND%, %COLOR_FONT%
Gui, Font, s11L, Courier Prime BC
placeholder := "" ;"~" . space_fill("", l:=293, f:="X") . "~"
WinGetPos, , , margin_left, , ahk_class Shell_TrayWnd ahk_exe explorer.exe
window_width := A_ScreenWidth - margin_left
gw := A_ScreenWidth / (A_ScreenDPI / 96) - margin_left / (A_ScreenDPI / 96) ; screen width must be scaled to fit width
gh := 25
gyy := -1

if (SHOW_AT_TOP) {
    gy := 0
    reserve_space_on_bottom(0)
    reserve_space_on_top(gh)
} else {
    gy := A_ScreenHeight - gh
    reserve_space_on_top(0)
    reserve_space_on_bottom(gh)
}

Gui, add, text, left   vTheInfoLeft   y%gyy% x0 w%gw% c%COLOR_FONT%, %placeholder%
Gui, add, text, center vTheInfoCenter y%gyy% x6 w%gw% c%COLOR_FONT%, %placeholder%
Gui, add, text, right  vTheInfoRight  y%gyy% x0 w%gw% c%COLOR_FONT%, %placeholder%

GuiControl, +BackgroundTrans, TheInfoLeft
GuiControl, +BackgroundTrans, TheInfoCenter
GuiControl, +BackgroundTrans, TheInfoRight

Gui, +Resize +AlwaysOnTop +ToolWindow -Caption +LastFound
; https://www.autohotkey.com/boards/viewtopic.php?t=77668
Gui, +E0x02000000 +E0x00080000 ; WS_EX_COMPOSITED & WS_EX_LAYERED => Double Buffer
Gui, show, x1414 y%gy% w500 h24 NoActivate


hwnd_info_bar := WinExist()
WinMove, ahk_id %hwnd_info_bar%, , margin_left, gy, %window_width%, gh
WinMove, WinTitle, WinText, X, Y, [Width, Height, ExcludeTitle, ExcludeText]
WinSet, Style, -0xC40000, ahk_id %hwnd_info_bar%


; https://www.autohotkey.com/board/topic/57067-restrict-the-mouse-move-to-area/
; https://www.autohotkey.com/boards/viewtopic.php?t=66966
ClipCursor(x1, y1, x2, y2) {
    VarSetCapacity(R, 16, 0)
    NumPut(x1, &R+0)
    NumPut(y1, &R+4)
    NumPut(x2, &R+8)
    NumPut(y2, &R+12)
    DllCall("ClipCursor", UInt, &R)
}

; https://www.autohotkey.com/board/topic/30503-turn-any-application-into-an-appbar/
reserve_space_on_top(height) {
    VarSetCapacity( APPBARDATA, (cbAPPBARDATA := A_PtrSize == 8 ? 48 : 36), 0 )
    Off := NumPut(  cbAPPBARDATA, APPBARDATA, "Ptr"  )
    Off := NumPut(           hAB,      Off+0, "Ptr"  )
    Off := NumPut(           ABM,      Off+0, "UInt" )
    Off := NumPut(             1,      Off+0, "UInt" ) 
    Off := NumPut(             0,      Off+0, "Int"  ) 
    Off := NumPut(             0,      Off+0, "Int"  ) 
    Off := NumPut(             0,      Off+0, "Int"  ) 
    Off := NumPut(        height,      Off+0, "Int"  )
    Off := NumPut(             1,      Off+0, "Ptr"  )

    DllCall("Shell32.dll\SHAppBarMessage", UInt, (ABM_NEW      := 0x0), Ptr, &APPBARDATA)
    DllCall("Shell32.dll\SHAppBarMessage", UInt, (ABM_QUERYPOS := 0x2), Ptr, &APPBARDATA)
    DllCall("Shell32.dll\SHAppBarMessage", UInt, (ABM_SETPOS   := 0x3), Ptr, &APPBARDATA)
}
reserve_space_on_bottom(height) {
    VarSetCapacity( APPBARDATA, (cbAPPBARDATA := A_PtrSize == 8 ? 48 : 36), 0 )
    Off := NumPut(  cbAPPBARDATA, APPBARDATA, "Ptr"  )
    Off := NumPut(                     0, Off+0, "Ptr"  )
    Off := NumPut(                     0, Off+0, "UInt" )
    Off := NumPut(                     3, Off+0, "UInt" ) 
    Off := NumPut(                     0, Off+0, "Int"  ) 
    Off := NumPut( A_ScreenHeight-height, Off+0, "Int"  ) 
    Off := NumPut(                     0, Off+0, "Int"  ) 
    Off := NumPut(                height, Off+0, "Int"  )
    Off := NumPut(                     1, Off+0, "Ptr"  )

    DllCall("Shell32.dll\SHAppBarMessage", UInt, (ABM_NEW      :=0x0), Ptr, &APPBARDATA)
    DllCall("Shell32.dll\SHAppBarMessage", UInt, (ABM_QUERYPOS :=0x2), Ptr, &APPBARDATA)
    DllCall("Shell32.dll\SHAppBarMessage", UInt, (ABM_SETPOS   :=0x3), Ptr, &APPBARDATA)
}




SetTimer, update_info_fs, 250
update_info_fs() {
    global hwnd_info_bar, gy, gh
    
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
            ClipCursor(0, 0, A_ScreenWidth, A_ScreenHeight)
        }
    } else {
        if (winy < 0) {
            WinMove, ahk_id %hwnd_info_bar%, , , %gy%
        }
        ClipCursor(0, gh, A_ScreenWidth, A_ScreenHeight) ; top
        ; ClipCursor(0, 0, A_ScreenWidth, gy) ; bottom
    }
}





ib_str_weather := ""
SetTimer, id_update_async, 1000
id_update_async() {
    global ib_str_weather := get_weather() ; needs to be in its own timer or it might block the rendering
}

SetTimer, ib_update_instable, 500
ib_update_instable() {
    global ib_str_weather
    
    static sp_current, sp_current_playing, ib_str_time, sp_last := false
    sp_song := get_spotify_song()
    if (sp_song) {
        sp_last := sp_song
        sp_current := "▶ " . sp_last
        sp_current_playing := true
    } else if (sp_last) {
        sp_current := "⏸ " . sp_last
        sp_current_playing := false
    } else {
        sp_current := "No latest song found ..."
        sp_current_playing := false
    }
    
    info_left := " [ " . get_desktop() . " ]    [ " . sp_current . " ] " . get_dancing(sp_current_playing)
    GuiControl,, TheInfoLeft, %info_left%
    
    info_center_left  := space_fill("[ " . get_date() . "  |  " . get_time_icon() . " " . get_time() . " ]", 40)
    info_center_right := space_fill_right("[ " . get_clockodo() . "  |  " . get_external_timer_diff() . " ]", 40)
    info_center := info_center_left . "  🏃‍♂️  " . info_center_right
    GuiControl,, TheInfoCenter, %info_center%
    
    info_right := "[ " . ib_str_weather . " ]    [ " . get_disk_space_free_gb("C") . "  |  " . get_ram_usage() . "  |  " . get_cpu_time() . " ]    [ " . get_volume() . " ] "
    GuiControl,, TheInfoRight, %info_right%
    
    Winset, Alwaysontop, ahk_id %hwnd_info_bar%, A
}

~#^Left::
~#^Right::
    Sleep, 100
    ib_update_instable()
Return
