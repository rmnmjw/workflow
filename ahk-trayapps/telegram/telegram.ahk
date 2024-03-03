APP_NAME     := "Telegram"
APP_SELECTOR := "Telegram ahk_class Chrome_WidgetWin_1 ahk_exe brave.exe"
APP_RUN      := "C:\Program Files\BraveSoftware\Brave-Browser\Application\chrome_proxy.exe --profile-directory=Default --app-id=ibblmnobmgdmpoeblocemifbpglakpoi"

#include ../App.ahk

#if GetKeyState("CapsLock", "P")

    Numpad8::
        App.toggle()
    Return