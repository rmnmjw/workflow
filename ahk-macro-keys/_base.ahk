#SingleInstance Force
#UseHook
#NoEnv
ListLines Off ; Displays the script lines most recently executed.
SetBatchLines -1 ; Determines how fast a script will run (affects CPU utilization).
DetectHiddenWindows, Off
CoordMode, Mouse, Screen
SendMode Input
SetTitleMatchMode, 2
SetWorkingDir %A_ScriptDir%
SetWinDelay, 0

#include ../ahk-lib/window_to_bottom_and_activate_topmost.ahk

window_toggle(selector) {
    WinGet, hwnd_have, ID, A
    WinGet, hwnd_want, ID, %selector%
    if (hwnd_have == hwnd_want) {
        window_to_bottom_and_activate_topmost()
    } else {
        WinActivate, %selector%
    }
}

RegRead, cur, HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\SessionInfo\1\VirtualDesktops, CurrentVirtualDesktop
RegRead, all, HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VirtualDesktops, VirtualDesktopIDs
desktop_current := floor(InStr(all,cur) / strlen(cur))
