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


; SysGet, MonitorCount, MonitorCount
; SysGet, MonitorPrimary, MonitorPrimary
; SysGet, Monitor, Monitor, 1
; m_xmin := MonitorLeft
; m_ymin := MonitorTop
; m_xmax := MonitorRight
; m_ymax := MonitorBottom
; SetTimer, check_monitor, 1000
; check_monitor() {
;     global m_xmin, m_ymin, m_xmax, m_ymax
;     SysGet, Monitor, Monitor, 1
;     if (m_xmin != MonitorLeft || m_ymin != MonitorTop || m_xmax != MonitorRight || m_ymax != MonitorBottom) {
;         Reload
;     }
; }

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

WALLPAPER_LIGHT := "C:\Users\rmn\Pictures\wallpaper\crxb103kq5.jpg"
WALLPAPER_DARK  := "C:\Users\rmn\Pictures\wallpaper\night.png"
wallpaper_set(light) {
    global WALLPAPER_LIGHT, WALLPAPER_DARK
    if (light) {
        path := WALLPAPER_LIGHT
    } else {
        path := WALLPAPER_DARK
    }
    RegWrite, REG_SZ, HKEY_CURRENT_USER, Control Panel\Desktop, Wallpaper, %path%
    
    loop, 8 {
        RunWait, %A_WinDir%\System32\RUNDLL32.EXE user32.dll`,UpdatePerUserSystemParameters
        Sleep, 250
    }    
}


; https://www.autohotkey.com/boards/viewtopic.php?f=6&t=62701
window_toggle_app_mode() {
    RegRead, appMode, HKCU, Software\Microsoft\Windows\CurrentVersion\Themes\Personalize, AppsUseLightTheme
    RegWrite, REG_DWORD, HKCU, Software\Microsoft\Windows\CurrentVersion\Themes\Personalize, AppsUseLightTheme, % !appMode
    wallpaper_set(!appMode)
}

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
    Sleep, 40
    
    WinGet, WindowList, List
    loop %WindowList% {
        WinUID := WindowList%A_Index%
        WinGetTitle, WinTitle, ahk_id %WinUID%
        WinGetClass, WinClass, ahk_id %WinUID%
        ; WinGet mm, MinMax, ahk_id %WinUID%
        WinGet, WinExe, ProcessName, ahk_id %WinUID%
        
        ; if (mm == -1) {
        ;     continue
        ; }
        
        if (trim(WinTitle) == "") {
            continue
        }
        
        if (skip_class[WinClass]) {
            continue
        }
        
        if (skip_exe[WinExe]) {
            continue
        }
        
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
generate_random_of(chars, len) {
    output  := ""
    loop, %len% {
        Random, r, 1, StrLen(chars)
        output .= SubStr(chars, r, 1)
    }
    return output
}

enter_random_string(len) {
    output  := generate_random_of("0123456789abcdefghijklmnopqrstuvwxyz", len)
    Send, %output%
}

enter_random_number(len) {
    output := generate_random_of("0123456789", len)
    Send, %output%
}

; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; 
;                                                               ; 
;                       Explorer Functions                      ;
;                                                               ; 
; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; ; 

explorer_restart() {
    RunWait taskkill /F /IM explorer.exe
    RunWait explorer.exe
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


vol_up(){
    Send, {Volume_Up}
    SetCapsLockState, AlwaysOff
}

vol_down() {
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
    Process, Close, AltSnap.exe
    

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

    EnvGet, OutputVar, LOCALAPPDATA
    Run, % OutputVar . "\..\Roaming\AltSnap\AltSnap.exe"
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
        ; TrayTip , TurboPaste: Copy into Buffer [ %key% ], %copied%, 1, 17
        TrayTip , TurboPaste: Copy into Buffer, %key%, 1, 17
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
        ; TrayTip , TurboPaste: Paste from Buffer [ %key% ], %pasted%, 1, 17
        TrayTip , TurboPaste: Paste from Buffer, %key%, 1, 17
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
CapsLock::return


; CapsLock is UP
#If !GetKeyState("CapsLock", "P")
    F13::Send ^w

    #0::TurboPaste.paste(0)
    #1::TurboPaste.paste(1)
    #2::TurboPaste.paste(2)
    #3::TurboPaste.paste(3)
    #4::TurboPaste.paste(4)
    #5::TurboPaste.paste(5)
    #6::TurboPaste.paste(6)
    #7::TurboPaste.paste(7)
    #8::TurboPaste.paste(8)
    #9::TurboPaste.paste(9)

    ; !^+a::Winset, Alwaysontop, , A
    
    !^+d::Send, %A_YYYY%-%A_MM%-%A_DD%
    !^+t::Send, %A_Hour%:%A_Min%
    
    !^+w::enter_random_string(10)
    !^+s::enter_random_number(1)
    
    #c::Return

    !^+ä::explorer_restart()
    
    !^+.::window_toggle_app_mode()
    ~!^+r::
        Reload
    Return

    !^+o::Run, explorer.exe "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\AutoHotkey\Window Spy.lnk"

    #t::
        Run, explorer.exe "C:\Users\rmn\AppData\Local\Microsoft\WindowsApps\wt.exe"
        WinWait, Windows PowerShell
        WinActivate, Windows PowerShell
    return
    
    #q::minimize_current_window()
    ; #q::window_to_bottom_and_activate_topmost()
    #w::return
    ; #d::
    ;     Critical, On
    ;     DetectHiddenWindows, On
    ;     WinGet, whnd,, Desktop ahk_class CabinetWClass ahk_exe Explorer.EXE
    ;     if (whnd != "") {
    ;         WinGet, curr,, A
    ;         if (whnd == curr) {
    ;             DetectHiddenWindows, Off
    ;             Critical, Off
    ;             window_to_bottom_and_activate_topmost()
    ;             return
    ;         } else {
    ;             WinActivate, ahk_id %whnd%
    ;         }
    ;     } else {
    ;         RunWait, explorer.exe "C:\Users\rmn\Desktop"
    ;     }
    ;     DetectHiddenWindows, Off
    ;     Critical, Off
    ; return
    
    ; #c::Send, {LWin down}{LAlt down}d{LAlt up}{LWin up}
    #s::Send, {LWin down}n{LWin up}
    #.::return
    

; CapsLock is DOWN
#If GetKeyState("CapsLock", "P")
    
    #0::TurboPaste.copy(0)
    #1::TurboPaste.copy(1)
    #2::TurboPaste.copy(2)
    #3::TurboPaste.copy(3)
    #4::TurboPaste.copy(4)
    #5::TurboPaste.copy(5)
    #6::TurboPaste.copy(6)
    #7::TurboPaste.copy(7)
    #8::TurboPaste.copy(8)
    #9::TurboPaste.copy(9)
    
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

    !^+Up::vol_up()
    !^+Down::vol_down()
    
    !^End::Run %a_scriptdir%\_hibernate.ahk

#If GetKeyState("F14", "P")
    WheelUp::Send, {WheelUp}{WheelUp}{WheelUp}{WheelUp}{WheelUp}{WheelUp}
    WheelDown::Send, {WheelDown}{WheelDown}{WheelDown}{WheelDown}{WheelDown}{WheelDown}
    
#If GetKeyState("F15", "P")
    WheelUp::vol_up()
    WheelDown::vol_down()
    
#If GetKeyState("F16", "P")
    ; nothing yet
    
#IfWinActive, ahk_class CabinetWClass
    ^+m::explorer_create_new_file()

#IfWinActive, ahk_class SunAwtFrame ahk_exe idea64.exe
    :*:val ::var 

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
    F13::WinClose, A
    

#If !GetKeyState("CapsLock", "P") and WinActive("ahk_class MozillaWindowClass ahk_exe firefox.exe")
    F13::Send ^w
    
#If !GetKeyState("CapsLock", "P") and WinActive("ahk_class SUMATRA_PDF_FRAME") and get_focus_name() == ""
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
    ; XButton1::Send {Left}
    ; XButton2::Send {Right}

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




#if !GetKeyState("CapsLock", "P") and WinActive("ahk_class TaskManagerWindow ahk_exe Taskmgr.exe")
    ^W::
    F13::Send !{f4}

#if !GetKeyState("CapsLock", "P") and WinActive("ahk_class ConsoleWindowClass ahk_exe cmd.exe")
    F13::Send !{f4}

#if !GetKeyState("CapsLock", "P") and WinActive("ahk_class WorkerW ahk_exe explorer.exe")
    F1::Return

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
    F13::Send !{f4}

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
    Return

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
    Return
    
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
    Return

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
    Return

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
    Return
    
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
    Return
    
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
    Return
    
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
    Return
    
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
    Return
    
    ; eraser
    F9::
        WinGetPos, wx, wy
        MouseGetPos, x, y
        MouseClick, L, wx+74, wy+90
        MouseClick, L, wx+281, wy+90
        MouseMove, x, y
    Return
    
    ; text
    F10::
        WinGetPos, wx, wy
        MouseGetPos, x, y
        MouseClick, L, wx+74, wy+90
        MouseClick, L, wx+326, wy+90
        MouseMove, x, y
    Return
    
    
    Esc::
        WinGetPos, wx, wy
        MouseGetPos, x, y
        MouseClick, L, wx+74, wy+90
        MouseClick, L, wx+326, wy+90
        MouseClick, L, wx+326, wy+90
        MouseMove, x, y
    Return

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