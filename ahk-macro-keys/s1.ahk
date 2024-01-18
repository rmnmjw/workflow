#include _base.ahk

if (desktop_current == 0) {
    window_toggle("ahk_class MozillaWindowClass ahk_exe firefox.exe")
    ; WinActivate, ahk_class MozillaWindowClass ahk_exe firefox.exe
}
