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

Menu, Tray, Icon, main.png

SetCapsLockState, AlwaysOff
SetNumlockState, AlwaysOn
SetScrollLockState, AlwaysOff

TEMP_FILE := A_Temp . "\autohotkey.ini"

#include ../ahk-lib/run_as_user.ahk
#include ../ahk-lib/app.ahk
#include ../ahk-lib/cursor.ahk
#include ../ahk-lib/time.ahk
#include ../ahk-lib/windows_mode_dark_light_toggle.ahk
#include ../ahk-lib/explorer.ahk
#include ../ahk-lib/strings.ahk
#include ../ahk-lib/window.ahk
#include ../ahk-lib/volume.ahk
#include ../ahk-lib/tooltip.ahk
#include ../ahk-lib/zoomit.ahk
#include ../ahk-lib/brightness.ahk
#include ../ahk-lib/hibernate.ahk
#include ../ahk-lib/SlottedCopyPaste.ahk
; #include info_bar.ahk

SetTimer, launch_programs, -1
launch_programs() {
    EnvGet, OutputVar, LOCALAPPDATA
    app_launch_if_needed("AltSnap.exe", OutputVar . "\..\Roaming\AltSnap\AltSnap.exe", true)
    app_launch_if_needed("ZoomIt64.exe", A_ScriptDir . "\exec\ZoomIt64.exe")
    app_launch_if_needed("RBTray.exe", A_ScriptDir . "\exec\RBTray.exe")
}

cursor_speed_set() ; reset to default

SetTimer, close_sublime_nag_windows, 250
close_sublime_nag_windows() {
    ControlClick, Abbrechen, This is an unregistered copy
}

CapsLock::return

; CapsLock is UP
#If !GetKeyState("CapsLock", "P")
    
    #0::SlottedCopyPaste.paste(0)
    #1::SlottedCopyPaste.paste(1)
    #2::SlottedCopyPaste.paste(2)
    #3::SlottedCopyPaste.paste(3)
    #4::SlottedCopyPaste.paste(4)
    #5::SlottedCopyPaste.paste(5)
    #6::SlottedCopyPaste.paste(6)
    #7::SlottedCopyPaste.paste(7)
    #8::SlottedCopyPaste.paste(8)
    #9::SlottedCopyPaste.paste(9)

    ; !^+a::Winset, Alwaysontop, , A
    
    !^+d::Send, %A_YYYY%-%A_MM%-%A_DD%
    !^+t::Send, %A_Hour%:%A_Min%
    
    !^+w::strings_enter_random_text(10)
    !^+s::strings_enter_random_number(1)
    
    !^+ä::explorer_restart()
    
    !^+.::windows_mode_dark_light_toggle()
    
    ~!^+r::Reload

    !^+o::Run, explorer.exe "C:\Program Files\AutoHotkey\WindowSpy.ahk"

    #t::
        Run, explorer.exe "C:\Users\rmn\AppData\Local\Microsoft\WindowsApps\wt.exe"
        WinWait, Windows PowerShell
        WinActivate, Windows PowerShell
    return
    
    #q::window_current_minimize()
    
    #w::return ; widgets
    #s::return ; search
    #.::return ; emojis

; CapsLock is DOWN
#If GetKeyState("CapsLock", "P")
    
    Volume_Up::brightness_set("+10")
    Volume_Down::brightness_set("-10")

    #0::SlottedCopyPaste.copy(0)
    #1::SlottedCopyPaste.copy(1)
    #2::SlottedCopyPaste.copy(2)
    #3::SlottedCopyPaste.copy(3)
    #4::SlottedCopyPaste.copy(4)
    #5::SlottedCopyPaste.copy(5)
    #6::SlottedCopyPaste.copy(6)
    #7::SlottedCopyPaste.copy(7)
    #8::SlottedCopyPaste.copy(8)
    #9::SlottedCopyPaste.copy(9)
    
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
        
    WheelUp::zoomit_zoom_in()
    WheelDown::zoomit_zoom_out()

    !^End::hibernate()
    
#If GetKeyState("F14", "P")
    WheelUp::Send, {WheelUp}{WheelUp}{WheelUp}{WheelUp}{WheelUp}{WheelUp}
    WheelDown::Send, {WheelDown}{WheelDown}{WheelDown}{WheelDown}{WheelDown}{WheelDown}
    
#If GetKeyState("F15", "P")
    WheelUp::vol_up_down(1)
    WheelDown::vol_up_down(-1)
    
#If GetKeyState("F16", "P")
    ; nothing yet

#IfWinActive, ahk_class ZoomitClass ahk_exe ZoomIt64.exe
    ~Esc::
        cursor_speed_set()
        ToolTip,
    return
    WheelUp::zoomit_zoom_in()
    WheelDown::zoomit_zoom_out()

#IfWinActive, ahk_class CabinetWClass
    ^+m::explorer_create_new_file()
    F1::return

#IfWinActive, ahk_class PX_WINDOW_CLASS ahk_exe sublime_text.exe
    NumPadDot::Send, .

#IfWinActive, ahk_class Chrome_WidgetWin_1 ahk_exe Code.exe
    NumPadDot::Send, .
    F5::
        WinGet, hwnd
        
        WinActivate, ahk_class MozillaWindowClass ahk_exe firefox.exe
        WinWaitActive, ahk_class MozillaWindowClass ahk_exe firefox.exe
        Send, {F5}
        
        WinActivate, ahk_id %hwnd%
    return

#IfWinActive, ahk_class SWT_Window0 ahk_exe eclipse.exe
    NumPadDot::Send, .
#IfWinActive, ahk_class SunAwtFrame
    NumPadDot::Send, .
#IfWinActive, ahk_exe filezilla.exe
    NumPadDot::Send, .

#IfWinActive, ahk_exe vlc.exe
    F13::WinClose, A

#IfWinActive, ahk_class MediaPlayerClassicW ahk_exe mpc-hc64.exe
    F13::WinClose, A

#If !GetKeyState("CapsLock", "P") and WinActive("ahk_class MozillaWindowClass ahk_exe firefox.exe")
    F13::Send ^w
    
#If !GetKeyState("CapsLock", "P") and WinActive("ahk_class SUMATRA_PDF_FRAME") and window_get_focus_name() == ""
    A::Send {Left}
    D::Send {Right}
    W::Send {Up}
    S::Send {Down}
    F::Send {F5}
    Q::Send {LControl down}{LShift down}{-}{LShift up}{LControl up}
    E::Send {LControl down}{LShift down}{+}{LShift up}{LControl up}
    F13::Send !{f4}
    WheelLeft::Send {Left}
    WheelRight::Send {Right}

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
    F13::Send !{f4}

#if !GetKeyState("CapsLock", "P") and WinActive("Steam ahk_class SDL_app ahk_exe steamwebhelper.exe")
    F13::Send !{f4}

#if !GetKeyState("CapsLock", "P") and WinActive("Freundesliste ahk_class SDL_app ahk_exe steamwebhelper.exe")
    F13::Send !{f4}

#if !GetKeyState("CapsLock", "P") and WinActive("ahk_class TaskManagerWindow ahk_exe Taskmgr.exe")
    ^W::
    F13::Send !{f4}

#if !GetKeyState("CapsLock", "P") and WinActive("ahk_class ConsoleWindowClass ahk_exe cmd.exe")
    F13::Send !{f4}

#if !GetKeyState("CapsLock", "P") and WinActive("ahk_class WorkerW ahk_exe explorer.exe")
    F1::return

#if !GetKeyState("CapsLock", "P") and WinActive("Uhr ahk_class ApplicationFrameWindow ahk_exe ApplicationFrameHost.exe")
    F13::Send !{f4}

#if !GetKeyState("CapsLock", "P") and WinActive("Rechner ahk_class ApplicationFrameWindow ahk_exe ApplicationFrameHost.exe")
    F13::Send !{f4}

#if !GetKeyState("CapsLock", "P") and WinActive("Einstellungen ahk_class ApplicationFrameWindow ahk_exe ApplicationFrameHost.exe")
    F13::Send !{f4}

#if !GetKeyState("CapsLock", "P") and WinActive("Microsoft Store ahk_class ApplicationFrameWindow ahk_exe ApplicationFrameHost.exe")
    F13::Send !{f4}
    
#if !GetKeyState("CapsLock", "P") and WinActive("Windows-Sicherheit ahk_class ApplicationFrameWindow ahk_exe ApplicationFrameHost.exe")
    F13::Send !{f4}

#if !GetKeyState("CapsLock", "P") and WinActive("ahk_class CASCADIA_HOSTING_WINDOW_CLASS ahk_exe WindowsTerminal.exe")
    F13::Send ^+W

#if !GetKeyState("CapsLock", "P") and WinActive("ahk_class PX_WINDOW_CLASS ahk_exe sublime_merge.exe")
    F13::Send !{f4}
    
#if !GetKeyState("CapsLock", "P") and WinActive("ahk_class Chrome_WidgetWin_1 ahk_exe Qobuz.exe")
    F13::Send !{f4}
    
#if !GetKeyState("CapsLock", "P") and WinActive("Window Spy ahk_exe AutoHotkey.exe")
    F13::Send !{f4}

#if !GetKeyState("CapsLock", "P") and WinActive("ahk_class Chrome_WidgetWin_0 ahk_exe Spotify.exe")
    F13::WinClose

#if !GetKeyState("CapsLock", "P") and WinActive("ahk_class {97E27FAA-C0B3-4b8e-A693-ED7881E99FC1} ahk_exe foobar2000.exe")
    F13::Send !{f4}

#if !GetKeyState("CapsLock", "P") and WinActive("ahk_class MSPaintApp ahk_exe mspaint.exe")
    F13::Send !{f4}

#if !GetKeyState("CapsLock", "P") and WinActive("ahk_class HwndWrapper[DeepL;;dbb0e6c7-c7f0-4c9a-86ab-8ead43f74392] ahk_exe DeepL.exe")
    F13::Send !{f4}

#if !GetKeyState("CapsLock", "P") and WinActive("ahk_class ApplicationFrameWindow ahk_exe ApplicationFrameHost.exe")
    F13::Send !{f4}

#if !GetKeyState("CapsLock", "P") and WinActive("ahk_exe Everything64.exe")
    Esc::Send !{f4}

#if !GetKeyState("CapsLock", "P") and WinActive("ahk_class ConsoleWindowClass ahk_exe powershell.exe")
    F13::
        Send, {Alt down}
        Sleep, 10
        Send, {Space}
        Sleep, 10
        Send, {Alt up}
        Sleep, 10
        Send, S
    return

#if !GetKeyState("CapsLock", "P") and WinActive("ahk_class ConsoleWindowClass ahk_exe ubuntu.exe")
    F13::WinClose
    
#if !GetKeyState("CapsLock", "P") and WinActive("Medienwiedergabe ahk_class ApplicationFrameWindow ahk_exe ApplicationFrameHost.exe")
    F13::Send !{f4}
    
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

#if !GetKeyState("CapsLock", "P") and WinActive("Clockify ahk_class Chrome_WidgetWin_1 ahk_exe brave.exe")
    F1::
        WinMinimize, A
        Run, C:\ProgramData\Microsoft\Windows\Start Menu\clockify both.lnk
    return
    
#if !GetKeyState("CapsLock", "P") and WinActive("Edge") and WinActive(".pdf ahk_class Chrome_WidgetWin_1 ahk_exe msedge.exe")
    
    ; marker: red
    F1::
        WinGetPos, wx, wy
        MouseGetPos, x, y
            MouseClick, L, wx+100, wy+90
            Sleep, 100
            MouseClick, L, wx+280, wy+162 ; color picking
            MouseClick, L, wx+74, wy+90
            MouseClick, L, wx+74, wy+90
        MouseMove, x, y
    return
    
    ; marker: blue
    F2::
        WinGetPos, wx, wy
        MouseGetPos, x, y
            MouseClick, L, wx+100, wy+90
            Sleep, 100
            MouseClick, L, wx+198, wy+162 ; color picking
            MouseClick, L, wx+74, wy+90
            MouseClick, L, wx+74, wy+90
        MouseMove, x, y
    return

    ; marker: green
    F3::
        WinGetPos, wx, wy
        MouseGetPos, x, y
            MouseClick, L, wx+100, wy+90
            Sleep, 100
            MouseClick, L, wx+158, wy+162 ; color picking
            MouseClick, L, wx+74, wy+90
            MouseClick, L, wx+74, wy+90
        MouseMove, x, y
    return

    ; marker: yellow
    F4::
        WinGetPos, wx, wy
        MouseGetPos, x, y
            MouseClick, L, wx+100, wy+90
            Sleep, 100
            MouseClick, L, wx+118, wy+162 ; color picking
            MouseClick, L, wx+74, wy+90
            MouseClick, L, wx+74, wy+90
        MouseMove, x, y
    return
    
    ; pen: red
    F5::
        WinGetPos, wx, wy
        MouseGetPos, x, y
            MouseClick, L, wx+249, wy+85
            Sleep, 100
            MouseClick, L, wx+304, wy+207
            MouseClick, L, wx+193, wy+87
            MouseClick, L, wx+193, wy+87
        MouseMove, x, y
    return
    
    ; pen: blue
    F6::
        WinGetPos, wx, wy
        MouseGetPos, x, y
            MouseClick, L, wx+249, wy+85
            Sleep, 100
            MouseClick, L, wx+426, wy+245
            MouseClick, L, wx+193, wy+87
            MouseClick, L, wx+193, wy+87
        MouseMove, x, y
    return
    
    ; pen: green
    F7::
        WinGetPos, wx, wy
        MouseGetPos, x, y
            MouseClick, L, wx+249, wy+85
            Sleep, 100
            MouseClick, L, wx+345, wy+245
            MouseClick, L, wx+193, wy+87
            MouseClick, L, wx+193, wy+87
        MouseMove, x, y
    return
    
    ; pen: yellow
    F8::
        WinGetPos, wx, wy
        MouseGetPos, x, y
            MouseClick, L, wx+249, wy+85
            Sleep, 100
            MouseClick, L, wx+465, wy+208
            MouseClick, L, wx+193, wy+87
            MouseClick, L, wx+193, wy+87
        MouseMove, x, y
    return
    
    ; eraser
    F9::
        WinGetPos, wx, wy
        MouseGetPos, x, y
        MouseClick, L, wx+74, wy+90
        MouseClick, L, wx+281, wy+90
        MouseMove, x, y
    return
    
    ; text
    F10::
        WinGetPos, wx, wy
        MouseGetPos, x, y
        MouseClick, L, wx+74, wy+90
        MouseClick, L, wx+326, wy+90
        MouseMove, x, y
    return
    
    
    Esc::
        WinGetPos, wx, wy
        MouseGetPos, x, y
        MouseClick, L, wx+74, wy+90
        MouseClick, L, wx+326, wy+90
        MouseClick, L, wx+326, wy+90
        MouseMove, x, y
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

#If !GetKeyState("CapsLock", "P")
    F13::Send ^w

#IfWinActive