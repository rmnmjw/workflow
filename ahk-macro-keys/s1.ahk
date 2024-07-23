#include _base.ahk

if (desktop_current == 1) {
    if (ctrl_down) {
        window_toggle("Brave ahk_class Chrome_WidgetWin_1 ahk_exe brave.exe")
    } else {
        window_toggle("Developer Edition ahk_class MozillaWindowClass ahk_exe firefox.exe")
    }
}

if (desktop_current == 2) {
    ControlSend, , {Left}, ahk_class SUMATRA_PDF_FRAME ahk_exe SumatraPDF.exe
}
