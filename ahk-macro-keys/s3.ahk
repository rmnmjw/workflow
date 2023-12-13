#include _base.ahk

if (desktop_current == 0) {
    WinActivate, common ahk_class Chrome_WidgetWin_1 ahk_exe Code.exe
}
