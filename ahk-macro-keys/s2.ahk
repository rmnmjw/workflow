#include _base.ahk

if (desktop_current == 1) {
    window_toggle("backend ahk_class Chrome_WidgetWin_1 ahk_exe Code.exe")
}

if (desktop_current == 2) {
    ControlSend, , {Right}, ahk_class SUMATRA_PDF_FRAME ahk_exe SumatraPDF.exe
}
