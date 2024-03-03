APP_NAME     := "MailHog"
APP_SELECTOR := "MailHog ahk_class Chrome_WidgetWin_1 ahk_exe brave.exe"
APP_RUN      := "C:\Program Files\BraveSoftware\Brave-Browser\Application\chrome_proxy.exe --profile-directory=Default --app-id=gochdcnakoneocoladpaahebkdkmndol"

#include ../App.ahk

#if GetKeyState("CapsLock", "P")

    Numpad2::
        if (App.toggle()) {
            Critical, On
            tmp := A_DetectHiddenWindows
            DetectHiddenWindows, On
            ControlSend, , {F5}, %APP_SELECTOR%
            DetectHiddenWindows, %tmp%
            Critical, Off
        }
    Return