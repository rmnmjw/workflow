#SingleInstance Force
#Persistent
if (!A_IsAdmin)
    Run *RunAs "%A_ScriptFullPath%"
#UseHook
#NoEnv
ListLines Off ; Displays the script lines most recently executed.
SetBatchLines -1 ; Determines how fast a script will run (affects CPU utilization).
#MaxHotkeysPerInterval 800
CoordMode, Mouse, Screen
SendMode Input
SetTitleMatchMode, 2
SetWorkingDir %A_ScriptDir%
SetWinDelay, 0

Menu, Tray, Icon, icon.ico

SetCapsLockState, AlwaysOff
SetNumlockState, AlwaysOn
SetScrollLockState, AlwaysOff

TEMP_FILE := A_Temp . "\autohotkey.ini"

; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; 
;                                                               ; 
;                          Screen Time                          ;
;                                                               ; 
; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; 

format_time(T) { ; based on https://www.autohotkey.com/boards/viewtopic.php?t=77420
    Local H, M, HH, Q:=60, R:=3600
    Return Format("{:02}:{:02}:{:02}", H:=T//R, M:=(T:=T-H*R)//Q, T-M*Q, HH:=H, HH*Q+M)
}

screen_time_varname := A_YYYY . A_MM . A_DD

IniRead, screen_time_total, %TEMP_FILE%, screen_time, %screen_time_varname%, 0
screen_time_start := -1
screen_time_last_change := -1

Gui, +AlwaysOnTop +ToolWindow -Caption +LastFound
Gui, Font, s8L q4, Segoe UI
Gui, +E0x02000000 +E0x00080000
Gui, Add, Text, vScreenTime cFFFFFF, y200 x0 w100 h100
Gui, Color, 211F23
WinSet, TransColor, 211F23
Gui, Show, x10 y2125 NoActivate
Gui, Margin, 0, 0

SetTimer, screen_time_periodic, 1000
screen_time_periodic()
screen_time_periodic(force_save:=false) {
    global TEMP_FILE
    global screen_time_total, screen_time_start, screen_time_last_change, screen_time_varname
    static changes := false, counter := 0
    
    if (A_TimeIdlePhysical < 2000) {
        if (screen_time_start == -1) {
            screen_time_start := A_Now
        }
        screen_time_last_change := A_Now
        changes := true
    } else {
        afk_delta := screen_time_last_change
        EnvSub, afk_delta, %A_Now%, seconds
        afk_delta := afk_delta * -1
        
        if (afk_delta >= 28 && screen_time_start != -1) {
            EnvSub, screen_time_start, %A_Now%, seconds
            screen_time_total += screen_time_start * -1
            screen_time_start := -1
            changes := true
        }
    }

    if (screen_time_start != -1) {
        current := screen_time_start
        EnvSub, current, %A_Now%, seconds
        current *= -1
    } else {
        current := 0
    }
 
    counter := Mod(counter + 1, 5)
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
    
    formatted := format_time(current_total)
    GuiControl,, ScreenTime, %formatted%
    Gui, +AlwaysOnTop
}

; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; 
;                                                               ; 
;                            Startup                            ;
;                                                               ; 
; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; 

startup_restart_alt_drag() {
    Process, Close, AltDrag.exe
    EnvGet, OutputVar, LOCALAPPDATA
    Run, % OutputVar . "\..\Roaming\AltDrag\AltDrag.exe -multi"
}

startup_restart_rbtray() {
    Process, Close, RBTray.exe
    Run, explorer.exe C:\dev\rbtray\x64\RBTray.exe
}

startup_refresh_taskbar_icons() {
    ; www.autohotkey.com/board/topic/33849-refreshtray/?p=410313
    tmp_DetectHiddenWindows := A_DetectHiddenWindows
    DetectHiddenWindows, On
    ControlGetPos,,,w,h,ToolbarWindow321, AHK_class NotifyIconOverflowWindow
    width:=w, hight:=h
    While % ((h:=h-5)>0 and w:=width){
        While % ((w:=w-5)>0){
            PostMessage, 0x200,0,% ((hight-h) >> 16)+width-w,ToolbarWindow321, AHK_class NotifyIconOverflowWindow
        }
    }
    DetectHiddenWindows, %A_DetectHiddenWindows%
}

startup_restart_alt_drag()
startup_restart_rbtray()
startup_refresh_taskbar_icons()

; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; 
;                                                               ; 
;                             Timers                            ;
;                                                               ; 
; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; 

SetTimer, close_sublime_nag_windows, 250
close_sublime_nag_windows() { 
    ControlClick, Abbrechen, This is an unregistered copy
}

; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; 
;                                                               ; 
;                        Window Functions                       ;
;                                                               ; 
; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; 

restore_all_windows() {
    WinGet, WindowList, List
    loop %WindowList% {
        WinUID := WindowList%A_Index%
        WinGetTitle, WinTitle, ahk_id %WinUID%
        WinGetClass, WinClass, ahk_id %WinUID%
        WinGet mm, MinMax, ahk_id %WinUID%
        if (trim(WinTitle) <> "" and WinClass <> "tooltips_class32" and mm != -1 and mm != 0) {
            Continue
        }
        WinActivate, ahk_id %WinUID% 
    }
}

get_focus_name() {
    ControlGetFocus currentFocus
    return currentFocus
}

minimize_current_window() {
    WinGetClass, t, A
    if (t == "WorkerW" || t == "AutoHotkeyGUI" || t == "Shell_TrayWnd")
        return
    WinMinimize, A   
}

window_to_bottom_and_activate_topmost() {
    Critical, On
    
    static skip := {"MsoCommandBar": true, "WorkerW": true, "Shell_TrayWnd": true, "Windows.UI.Core.CoreWindow": true, "HwndWrapper[RetroBar;;5185c85c-029f-467e-9e82-3a9a0fb5d33d]": true}
    WinGetClass, c, A
    if (skip[c]) {
        Critical, Off
        return
    }
    
    WinSet, Bottom, , A
    
    WinGet, WindowList, List
    loop %WindowList% {
        WinUID := WindowList%A_Index%
        WinGetTitle, WinTitle, ahk_id %WinUID%
        WinGetClass, WinClass, ahk_id %WinUID%
        WinGet mm, MinMax, ahk_id %WinUID%
        if (trim(WinTitle) <> "" and WinClass <> "tooltips_class32" and mm != -1) {
            Break
        }
    }
    
    WinActivate, ahk_id %WinUID% 
    Critical, Off
}

; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; 
;                                                               ; 
;                         Text Functions                        ;
;                                                               ; 
; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; 

; https://www.autohotkey.com/boards/viewtopic.php?t=76052
enter_random_string(len) {
    symbols := "0123456789abcdefghijklmnopqrstuvwxyz"
    output  := ""
    loop, %len% {
        Random, r, 1, StrLen(symbols)
        output .= SubStr(symbols, r, 1)
    }
    Send, %output%
}

; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; 
;                                                               ; 
;                       Explorer Functions                      ;
;                                                               ; 
; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; 

explorer_restart() {
    RunWait taskkill /F /IM explorer.exe 
    Run explorer.exe
}

; https://github.com/GorvGoyl/Autohotkey-Scripts-Windows/blob/master/create_file_here.ahk
explorer_create_new_file() {
    WinHWND := WinActive()
    for win in ComObjCreate("Shell.Application").Windows {
        if (win.HWND == WinHWND) {
            dir := SubStr(win.LocationURL, 9) ; remove "file:///"
            dir := RegExReplace(dir, "%20", " ")
            break
        }
    }
    
    InputBox, file_name, New File, Name of the new file
    file_name := Trim(file_name)
    if (file_name == "") {
        return
    }
    
    file := dir . "/" . file_name
    if (FileExist(file)) {
        MsgBox, %file_name% already exists
        return
    }
    FileAppend,, %file% 
}

; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;
; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;
; ;                                                               ; ;
; ;                          Key Bindings                         ; ;
; ;                                                               ; ;
; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;
; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ;

#^Tab::Send, {LWin down}{Tab}{LWin up}
#Tab::Return
CapsLock::return

; CapsLock is UP
#If !GetKeyState("CapsLock", "P")
    !^+a::Winset, Alwaysontop, , A
    
    !^+d::Send, %A_YYYY%-%A_MM%-%A_DD%
    !^+t::Send, %A_Hour%:%A_Min%
    
    !^+w::enter_random_string(10)

    !^+ä::explorer_restart()
    
    #^Up::Run nircmd-x64/nircmd.exe changebrightness +10
    #^Down::Run nircmd-x64/nircmd.exe changebrightness -10
    
    ~!^+r::
        screen_time_periodic(true)
        Reload
    Return

    !^+o::Run, explorer.exe "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\AutoHotkey\Window Spy.lnk"

    #t::Run, explorer.exe "C:\Program Files\WindowsApps\Microsoft.WindowsTerminal_1.15.2875.0_x64__8wekyb3d8bbwe\wt.exe"
    
    #q::window_to_bottom_and_activate_topmost()
    #w::minimize_current_window()
    #^d::restore_all_windows()
    
    #c::return
    
    <^>!a::Send, α
    <^>!b::Send, β
    <^>!g::Send, γ
    <^>!d::Send, δ
    <^>!e::Send, ε
    <^>!z::Send, ζ
    <^>!ä::Send, η
    <^>!f::Send, θ
    <^>!k::Send, κ
    <^>!l::Send, λ
    <^>!m::Send, μ
    <^>!n::Send, ν
    <^>!x::Send, ξ
    <^>!p::Send, π
    <^>!r::Send, ρ
    <^>!s::Send, σ
    <^>!t::Send, τ
    <^>!y::Send, υ
    <^>!v::Send, φ
    <^>!h::Send, χ
    <^>!i::Send, ψ
    <^>!o::Send, ω

    +<^>!a::Send, Α
    +<^>!b::Send, Β
    +<^>!g::Send, Γ
    +<^>!d::Send, Δ
    +<^>!e::Send, Ε
    +<^>!z::Send, Ζ
    +<^>!ä::Send, Η
    +<^>!f::Send, Θ
    +<^>!k::Send, Κ
    +<^>!l::Send, Λ
    +<^>!m::Send, Μ
    +<^>!n::Send, Ν
    +<^>!x::Send, Ξ
    +<^>!p::Send, Π
    +<^>!r::Send, Ρ
    +<^>!s::Send, Σ
    +<^>!t::Send, Τ
    +<^>!y::Send, Υ
    +<^>!v::Send, Φ
    +<^>!h::Send, Χ
    +<^>!i::Send, Ψ
    +<^>!o::Send, Ω
    
    <^>!Numpad0::Send, │
    <^>!Numpad1::Send, └
    <^>!Numpad2::Send, ┴
    <^>!Numpad3::Send, ┘
    <^>!Numpad4::Send, ├
    <^>!Numpad5::Send, ┼
    <^>!Numpad6::Send, ┤
    <^>!Numpad7::Send, ┌
    <^>!Numpad8::Send, ┬
    <^>!Numpad9::Send, ┐
    <^>!NumpadSub::Send, ─
    
#If GetKeyState("ScrollLock", "P")
    WheelUp::Send, {WheelUp}{WheelUp}{WheelUp}{WheelUp}{WheelUp}{WheelUp}
    WheelDown::Send, {WheelDown}{WheelDown}{WheelDown}{WheelDown}{WheelDown}{WheelDown}

; CapsLock is DOWN
#If GetKeyState("CapsLock", "P")
    q::Send, @
    7::Send, {{}
    8::Send, [
    9::Send, ]
    0::Send, {}}
    ,::Send, <
    .::Send, >
    ß::Send, \
    +::Send, ~
    PrintScreen::Send, {PrintScreen}
    NumPadDot::Send, .

    WheelUp::
        Critical, On
        Send, {Volume_Up}
        SetCapsLockState, AlwaysOff
        Critical, Off
    return
    WheelDown::
        Critical, On
        Send, {Volume_Down}
        SetCapsLockState, AlwaysOff
        Critical, Off
    return

#IfWinActive, ahk_class CabinetWClass
    ^+m::explorer_create_new_file()

#IfWinActive, ahk_class PX_WINDOW_CLASS ahk_exe sublime_text.exe
    NumPadDot::Send, .

    :*:cosnt::const
    :*:costn::const
    :*:cosnst::const 
    :*:cosn t::const 
    :*:cson t::const 

    :*:elt::let
    :*:wheil::while
    :*:whiel::while

#IfWinActive, ahk_class Chrome_WidgetWin_1 ahk_exe Code.exe
    NumPadDot::Send, .
    
    :*:cosnt::const
    :*:costn::const
    :*:cosnst::const 
    :*:cosn t::const 
    :*:cson t::const 
    
    :*:elt::let
    :*:wheil::while
    :*:whiel::while
    
#IfWinActive, ahk_class SWT_Window0 ahk_exe eclipse.exe
    NumPadDot::Send, .
#IfWinActive, ahk_class SunAwtFrame
    NumPadDot::Send, .
#IfWinActive, ahk_exe filezilla.exe
    NumPadDot::Send, .

#IfWinActive, ahk_exe vlc.exe
    ^W::WinClose, A
    
#If !GetKeyState("CapsLock", "P") and WinActive("ahk_class SUMATRA_PDF_FRAME") and get_focus_name() == ""
    A::Send {Left}
    D::Send {Right}
    W::Send {Up}
    S::Send {Down}
    F::Send {F5}
    Q::Send {LControl down}{LShift down}{-}{LShift up}{LControl up}
    E::Send {LControl down}{LShift down}{+}{LShift up}{LControl up}
    ^W::Send !{f4}
    XButton1::Send {Left}
    XButton2::Send {Right}

#If !GetKeyState("CapsLock", "P") and WinActive("ahk_class Photo_Lightweight_Viewer")
    A::Send {Left}
    D::Send {Right}
    Q::Send {LControl down},{LControl up}
    E::Send {LControl down}.{LControl up}
    F::Send {F11}
    R::Send {LControl down}{LAlt down}0{LAlt up}{LControl up}
    T::Send {LControl down}0{LControl up}

#if !GetKeyState("CapsLock", "P") and (WinActive("ahk_exe 7zFM.exe")
 or WinActive("ahk_exe Taskmgr.exe")
 or WinActive("ahk_class Photo_Lightweight_Viewer"))
    Esc::
    ^W::
        Send !{f4}
    return

#if !GetKeyState("CapsLock", "P") and WinActive("ahk_class ConsoleWindowClass ahk_exe cmd.exe")
    ^W::
        Send !{f4}
    return

#if !GetKeyState("CapsLock", "P") and WinActive("ahk_class WorkerW ahk_exe explorer.exe")
    F1::Return

#IfWinActive
