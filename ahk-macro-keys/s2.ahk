#include _base.ahk

if (desktop_current == 0) {
    WinActivate, backend ahk_class Chrome_WidgetWin_1 ahk_exe Code.exe
}
