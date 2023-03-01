#SingleInstance Force
#Persistent
if (!A_IsAdmin)
    Run *RunAs "%A_ScriptFullPath%"
#UseHook
#NoEnv
ListLines Off ; Displays the script lines most recently executed.
SetBatchLines -1 ; Determines how fast a script will run (affects CPU utilization).
#MaxHotkeysPerInterval 800
DetectHiddenWindows, Off
CoordMode, Mouse, Screen
SendMode Input
SetTitleMatchMode, 2
SetWorkingDir %A_ScriptDir%
SetWinDelay, 0

Menu, Tray, Icon, icon.png

SetCapsLockState, AlwaysOff
SetNumlockState, AlwaysOn
SetScrollLockState, AlwaysOff

TEMP_FILE := A_Temp . "\autohotkey.ini"





; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; 
;                                                               ; 
;                         Time Functions                        ;
;                                                               ; 
; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; 

time_format(T) { ; based on https://www.autohotkey.com/boards/viewtopic.php?t=77420
    Local H, M, HH, Q:=60, R:=3600
    Return Format("{:02}:{:02}:{:02}", H:=T//R, M:=(T:=T-H*R)//Q, T-M*Q, HH:=H, HH*Q+M)
}

time_diff_sec_abs(a, b:=false) {
    EnvSub, a, %b%, seconds
    return Abs(a)
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
    
    WinGetClass, c, A
    WinGet, x, ProcessName, A
    
    static skip_class := { "HwndWrapper[RetroBar;;7f115ed5-d681-4689-9462-ff7fff349f0f]": true, "HwndWrapper[RetroBar;;295ed828-7f71-4f84-8552-fbf81fe5f314]": true, "MsoCommandBar": true, "WorkerW": true, "Shell_TrayWnd": true, "Windows.UI.Core.CoreWindow": true, "HwndWrapper[RetroBar;;5185c85c-029f-467e-9e82-3a9a0fb5d33d]": true, "HwndWrapper[PowerToys.PowerLauncher;;ad955d97-abcd-4877-b43b-c69f9d4c361c]": true, "Windows.UI.Core.CoreWindow": true, "HwndWrapper[RetroBar;;396f90e1-b93e-44b4-a494-f213f520d04c]": true, "CiceroUIWndFrame": true, "HwndWrapper[RetroBar;;7bbfe7f1-78c1-4bb6-b6ba-0baf6b281b78]": true, "Xaml_WindowedPopupClass": true, "HwndWrapper[RetroBar;;379033f4-3b08-4a70-8d09-7ff3855fd027]": true, "GDI+ Window (RetroBar.exe)": true, "HwndWrapper[PowerToys.PowerLauncher;;4c619480-cfa0-4134-8aec-0cdab9f4a980]": true, "GDI+ Hook Window Class": true, "XamlExplorerHostIslandWindow": true, "SystemTray_Main": true, "ATL:00007FF9CEE2D230": true, "tooltips_class32": true, "ConsoleWindowClass :: 0": true, "TWizardForm": true, "TApplication": true }
    static skip_exe := { "RetroBar.exe": true }
    
    if (skip_class[c] || skip_exe[x]) {
        Critical, Off
        return
    }
    

    if (c == "MozillaWindowClass" && x == "thunderbird.exe") {
        WinMinimize, A
    } else {
        WinSet, Bottom, , A
    }
    
    WinGet, WindowList, List
    loop %WindowList% {
        WinUID := WindowList%A_Index%
        WinGetTitle, WinTitle, ahk_id %WinUID%
        WinGetClass, WinClass, ahk_id %WinUID%
        WinGet mm, MinMax, ahk_id %WinUID%
        WinGet, WinExe, ProcessName, ahk_id %WinUID%
        
        
        if (mm == -1)
            continue
        
        if (trim(WinTitle) == "")
            continue
        
        if (skip_class[WinClass])
            continue
        
        if (skip_exe[WinExe])
            continue
        
        Break
    }
    
    WinActivate, ahk_id %WinUID% 
    WinWaitActive, ahk_id %WinUID% 
    
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





; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; 
;                                                               ; 
;                             Volume                            ;
;                                                               ; 
; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; 

vol_show_shown := false
vol_hide() {
    global vol_show_shown
    SetTimer, vol_hide, Off
    Critical, On
        RunWait, "C:\Program Files (x86)\HideVolumeOSD\HideVolumeOSD.exe" -hide
        vol_show_shown := false
    Critical, Off
}

vol_show() {
    global vol_show_shown
    SetTimer, vol_hide, Off
    if (!vol_show_shown) {
        Critical, On
            vol_show_shown := true
            RunWait, "C:\Program Files (x86)\HideVolumeOSD\HideVolumeOSD.exe" -show
        Critical, Off
    }
    SetTimer, vol_hide, 300
}

vol_up(){
    vol_show()
    Send, {Volume_Up}
    SetCapsLockState, AlwaysOff
}

vol_down() {
    vol_show()
    Send, {Volume_Down}
    SetCapsLockState, AlwaysOff
}





; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; 
;                                                               ; 
;                            Startup                            ;
;                                                               ; 
; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; 

SetTimer, restart_programs, -1
restart_programs() {
    Process, Close, AltDrag.exe
    ; Process, Close, RBTray.exe
    ; Process, Close, RetroBar.exe
    
    Process, Close, HideVolumeOSD.exe
    vol_hide()

    ; www.autohotkey.com/board/topic/33849-refreshtray/?p=410313
    DetectHiddenWindows, On
    ControlGetPos,,,w,h,ToolbarWindow321, AHK_class NotifyIconOverflowWindow
    width:=w, hight:=h
    While % ((h:=h-5)>0 and w:=width){
        While % ((w:=w-5)>0){
            PostMessage, 0x200,0,% ((hight-h) >> 16)+width-w,ToolbarWindow321, AHK_class NotifyIconOverflowWindow
        }
    }
    DetectHiddenWindows, Off

    ; Run, explorer.exe C:\dev\rbtray\x64\RBTray.exe

    EnvGet, OutputVar, LOCALAPPDATA
    Run, % OutputVar . "\..\Roaming\AltDrag\AltDrag.exe -multi"

    ; Run, explorer.exe C:\Program Files\RetroBar\RetroBar.exe
}





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
;                           TurboPaste                          ;
;                                                               ; 
; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; 

class TurboPaste {
    static buffer := {}
    
    copy(key) {
        Critical, On
            tmp := Clipboard
                Send, {Ctrl down}c{Ctrl up}
                Sleep, 50
                TurboPaste.buffer[key] := Clipboard
            Clipboard := tmp
        Critical, Off
        
        copied := TurboPaste.buffer[key]
        TrayTip , TurboPaste: Copy into Buffer [ %key% ], %copied%, 1, 17
    }
    
    paste(key) {
        Critical, On
            tmp := Clipboard
                Clipboard := TurboPaste.buffer[key]
                Send, {Ctrl down}v{Ctrl up}
                Sleep, 50
            Clipboard := tmp
        Critical, Off
        
        pasted := TurboPaste.buffer[key]
        TrayTip , TurboPaste: Paste from Buffer [ %key% ], %pasted%, 1, 17
    }
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
    
    ; ~LButton::
    ;     MouseGetPos, x, y, id
    ;     WinGet, exe, ProcessName, ahk_id %id%
    ;     if (exe != "RetroBar.exe" || x < 3838) {
    ;         return
    ;     }
    ;     Send, {RWin down}d{RWin up}
    ; return

    #1::TurboPaste.paste(1)
    #2::TurboPaste.paste(2)
    #3::TurboPaste.paste(3)
    #4::TurboPaste.paste(4)
    #5::TurboPaste.paste(5)
    #6::TurboPaste.paste(6)
    #7::TurboPaste.paste(7)
    #8::TurboPaste.paste(8)
    #9::TurboPaste.paste(9)
    #0::TurboPaste.paste(0)

    !^+a::Winset, Alwaysontop, , A
    
    !^+d::Send, %A_YYYY%-%A_MM%-%A_DD%
    !^+t::Send, %A_Hour%:%A_Min%
    
    !^+w::enter_random_string(10)

    !^+ä::explorer_restart()
    
    ~!^+r::
        ; screen_time_periodic(true)
        Reload
    Return

    !^+o::Run, explorer.exe "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\AutoHotkey\Window Spy.lnk"

    ; #t::Run, explorer.exe "C:\Program Files\WindowsApps\Microsoft.WindowsTerminal_1.15.2875.0_x64__8wekyb3d8bbwe\wt.exe"
    #t::
        path := "C:\Users\" . A_UserName
        Run, PowerShell.exe -noexit -command Set-Location -literalPath '%path%'
    Return
    
    #q::window_to_bottom_and_activate_topmost()
    #w::return
    ; #w::minimize_current_window()
    ; #^d::restore_all_windows()
    ~#d::
        Critical, On
        DetectHiddenWindows, On
        WinSet, Top,, ahk_exe RetroBar.exe
        DetectHiddenWindows, Off
        Critical, Off
    return
    
    #c::return
    #.::return

; CapsLock is DOWN
#If GetKeyState("CapsLock", "P")
    
    #1::TurboPaste.copy(1)
    #2::TurboPaste.copy(2)
    #3::TurboPaste.copy(3)
    #4::TurboPaste.copy(4)
    #5::TurboPaste.copy(5)
    #6::TurboPaste.copy(6)
    #7::TurboPaste.copy(7)
    #8::TurboPaste.copy(8)
    #9::TurboPaste.copy(9)
    #0::TurboPaste.copy(0)
    
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

    WheelUp::vol_up()
    WheelDown::vol_down()

#If GetKeyState("ScrollLock", "P")
    WheelUp::Send, {WheelUp}{WheelUp}{WheelUp}{WheelUp}{WheelUp}{WheelUp}
    WheelDown::Send, {WheelDown}{WheelDown}{WheelDown}{WheelDown}{WheelDown}{WheelDown}
    
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
    Esc::Send !{f4}
    ^W::Send !{f4}

#if !GetKeyState("CapsLock", "P") and WinActive("ahk_class ConsoleWindowClass ahk_exe cmd.exe")
    ^W::Send !{f4}

#if !GetKeyState("CapsLock", "P") and WinActive("ahk_class WorkerW ahk_exe explorer.exe")
    F1::Return

#if !GetKeyState("CapsLock", "P") and WinActive("Uhr ahk_class ApplicationFrameWindow ahk_exe ApplicationFrameHost.exe")
    ^W::Send !{f4}

#if !GetKeyState("CapsLock", "P") and WinActive("Rechner ahk_class ApplicationFrameWindow ahk_exe ApplicationFrameHost.exe")
    ^W::Send !{f4}

#if !GetKeyState("CapsLock", "P") and WinActive("Einstellungen ahk_class ApplicationFrameWindow ahk_exe ApplicationFrameHost.exe")
    ^W::Send !{f4}

#if !GetKeyState("CapsLock", "P") and WinActive("Microsoft Store ahk_class ApplicationFrameWindow ahk_exe ApplicationFrameHost.exe")
    ^W::Send !{f4}
    
#if !GetKeyState("CapsLock", "P") and WinActive("Windows-Sicherheit ahk_class ApplicationFrameWindow ahk_exe ApplicationFrameHost.exe")
    ^W::Send !{f4}

#if !GetKeyState("CapsLock", "P") and WinActive("ahk_class CASCADIA_HOSTING_WINDOW_CLASS ahk_exe WindowsTerminal.exe")
    ^W::Send ^+W

#if !GetKeyState("CapsLock", "P") and WinActive("ahk_class PX_WINDOW_CLASS ahk_exe sublime_merge.exe")
    ^W::Send !{f4}
    
#if !GetKeyState("CapsLock", "P") and WinActive("ahk_class Chrome_WidgetWin_1 ahk_exe Qobuz.exe")
    ^W::Send !{f4}
    
#if !GetKeyState("CapsLock", "P") and WinActive("Window Spy ahk_exe AutoHotkey.exe")
    ^W::Send !{f4}

#if !GetKeyState("CapsLock", "P") and WinActive("ahk_class Chrome_WidgetWin_0 ahk_exe Spotify.exe")
    ^W::Send !{f4}

#if !GetKeyState("CapsLock", "P") and WinActive("ahk_class {97E27FAA-C0B3-4b8e-A693-ED7881E99FC1} ahk_exe foobar2000.exe")
    ^W::Send !{f4}

#if !GetKeyState("CapsLock", "P") and WinActive("ahk_class MSPaintApp ahk_exe mspaint.exe")
    ^W::Send !{f4}

#if !GetKeyState("CapsLock", "P") and WinActive("ahk_class MozillaWindowClass ahk_exe thunderbird.exe")
    ^W::window_to_bottom_and_activate_topmost()

#if !GetKeyState("CapsLock", "P") and WinActive("ahk_class ConsoleWindowClass ahk_exe powershell.exe")
    ^W::
        Send, {Alt down}
        Sleep, 10
        Send, {Space}
        Sleep, 10
        Send, {Alt up}
        Sleep, 10
        Send, S
    Return
    
#if !GetKeyState("CapsLock", "P") and WinActive("Medienwiedergabe ahk_class ApplicationFrameWindow ahk_exe ApplicationFrameHost.exe")
    ^W::Send !{f4}
    
    j::
        Send, {Ctrl down}{Shift down}j{Shift up}{Ctrl up}
        TrayTip, Media Playback [ 1x ], 1x, 1, 17
    return
    
    k::
        Send, {Ctrl down}{Shift down}k{Shift up}{Ctrl up}
        TrayTip, Media Playback [ 1.5x ], 1.5x, 1, 17
    return
    
    l::
        Send, {Ctrl down}{Shift down}l{Shift up}{Ctrl up}
        TrayTip, Media Playback [ 2x ], 2x, 1, 17
    return
    
    f::Send, {F11}
    
    A::
    Left::
        Send, {Ctrl down}{Left}{Ctrl up}
    return
    
    D::
    Right::
        Send, {Ctrl down}{Right}{Ctrl up}
    return

#If !GetKeyState("CapsLock", "P")

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
    
#IfWinActive