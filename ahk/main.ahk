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

Menu, Tray, Icon, icon.ico

SetCapsLockState, AlwaysOff
SetNumlockState, AlwaysOn
SetScrollLockState, AlwaysOff

TEMP_FILE := A_Temp . "\autohotkey.ini"

#include _time_functions.ahk
#include _window_functions.ahk
#include _text_functions.ahk
#include _explorer_functions.ahk

; #include screen_time.ahk
; #include mouse_find.ahk
#include startup_actions.ahk
#include timers.ahk

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
    ; !^+a::Winset, Alwaysontop, , A
    
    !^+d::Send, %A_YYYY%-%A_MM%-%A_DD%
    !^+t::Send, %A_Hour%:%A_Min%
    
    !^+w::enter_random_string(10)

    !^+ä::explorer_restart()
    
    ~!^+r::
        ; screen_time_periodic(true)
        Reload
    Return

    !^+o::Run, explorer.exe "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\AutoHotkey\Window Spy.lnk"

    #t::Run, explorer.exe "C:\Program Files\WindowsApps\Microsoft.WindowsTerminal_1.15.2875.0_x64__8wekyb3d8bbwe\wt.exe"
    
    #q::window_to_bottom_and_activate_topmost()
    #w::return
    ; #w::minimize_current_window()
    ; #^d::restore_all_windows()
    ~#d::
        WinSet, Top,, ahk_class HwndWrapper[RetroBar;;295ed828-7f71-4f84-8552-fbf81fe5f314]
    return
    
    #c::return
    #.::return
    
    
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
    Esc::Send !{f4}
    ^W::Send !{f4}

#if !GetKeyState("CapsLock", "P") and WinActive("ahk_class ConsoleWindowClass ahk_exe cmd.exe")
    ^W::Send !{f4}

#if !GetKeyState("CapsLock", "P") and WinActive("ahk_class WorkerW ahk_exe explorer.exe")
    F1::Return

#if !GetKeyState("CapsLock", "P") and WinActive("Uhr ahk_class ApplicationFrameWindow ahk_exe ApplicationFrameHost.exe")
    ^W::Send !{f4}

#if !GetKeyState("CapsLock", "P") and WinActive("Einstellungen ahk_class ApplicationFrameWindow ahk_exe ApplicationFrameHost.exe")
    ^W::Send !{f4}

#if !GetKeyState("CapsLock", "P") and WinActive("Microsoft Store ahk_class ApplicationFrameWindow ahk_exe ApplicationFrameHost.exe")
    ^W::Send !{f4}

#if !GetKeyState("CapsLock", "P") and WinActive("ahk_class CASCADIA_HOSTING_WINDOW_CLASS ahk_exe WindowsTerminal.exe")
    ^W::Send ^+W

#IfWinActive
