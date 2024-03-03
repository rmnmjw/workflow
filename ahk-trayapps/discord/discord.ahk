APP_NAME     := "Discord"
APP_SELECTOR := "Discord ahk_class Chrome_WidgetWin_1 ahk_exe brave.exe"
APP_RUN      := "C:\Program Files\BraveSoftware\Brave-Browser\Application\chrome_proxy.exe --profile-directory=Default --app-id=magkoliahgffibhgfkmoealggombgknl"

#include ../App.ahk

#if GetKeyState("CapsLock", "P")

    Numpad9::
        App.toggle()
    Return