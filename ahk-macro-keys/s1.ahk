#include _base.ahk

if (desktop_current == 0) {
    WinActivate, ahk_class MozillaWindowClass ahk_exe firefox.exe
}
