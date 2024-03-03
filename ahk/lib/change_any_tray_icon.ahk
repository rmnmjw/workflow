#include lib/spotify_get_hwnd.ahk

spotify_set_icon(playing, force:=false) {
    static hIcon_off := LoadPicture("..\ahk-trayapps\spotify\Spotify.ico", "w24 h-1", IMAGE_ICON := 2)
    static hIcon_on  := LoadPicture("..\ahk-trayapps\spotify\Spotify_on.ico", "w24 h-1", IMAGE_ICON := 2)
    static info := false, last_hwnd := false
    
    static next := -1
    if (A_TickCount < next && !force)
        return
    next := A_TickCount + 2000
    
    if (last_hwnd != (hwnd := spotify_get_hwnd())) {
        last_hwnd := hwnd
        dhw := A_DetectHiddenWindows
        DetectHiddenWindows, On
            last_ahk_id := selector := "ahk_id " . last_hwnd
            WinGet, PID, PID, %selector%
            last_pid := PID
            try {
                info := GetTrayIconInfo(PID)
            }
        DetectHiddenWindows, %dhw%
    }
        
    if (playing) {
        result := ReplaceTrayIcon(hIcon_on, info.hWnd, info.Id)
    } else {
        result := ReplaceTrayIcon(hIcon_off, info.hWnd, info.Id)
    }
}

; https://www.autohotkey.com/boards/viewtopic.php?p=456208#p456208
ReplaceTrayIcon(hIcon, hWnd, iconId) {
    static flag := NIF_ICON := 2, action := NIM_MODIFY := 1
    VarSetCapacity(NOTIFYICONDATA, size := A_PtrSize*4 + 8, 0)
    NumPut(size  , NOTIFYICONDATA)
    NumPut(hWnd  , NOTIFYICONDATA, A_PtrSize)
    NumPut(iconId, NOTIFYICONDATA, A_PtrSize*2)
    NumPut(flag  , NOTIFYICONDATA, A_PtrSize*2 + 4)
    NumPut(hIcon , NOTIFYICONDATA, A_PtrSize*3 + 8)
    Return DllCall("Shell32\Shell_NotifyIcon", "UInt", action, "Ptr", &NOTIFYICONDATA)
}

; https://www.autohotkey.com/boards/viewtopic.php?p=456208#p456208
GetTrayIconInfo(proceccNameOrPID := "") {
    static TB_GETBUTTON   := 0x417
          , TB_BUTTONCOUNT := 0x418
          , ptrSize := 4 << A_Is64bitOS
          , szTBBUTTON := 8 + ptrSize*3
          , szTRAYDATA := 16 + ptrSize*2
    
    Arr := []
    dhw_prev := A_DetectHiddenWindows
    DetectHiddenWindows, On
    WinGet, PID, PID, ahk_exe explorer.exe
    RB := new RemoteBuffer(PID, szTRAYDATA)
    found := false
    Loop 2 {
        if (A_Index = 2) {
            ControlGet, hToolBar, hwnd,, ToolbarWindow321, ahk_class NotifyIconOverflowWindow
        } else {
            for k, v in ["TrayNotifyWnd", "SysPager", "ToolbarWindow32"] {
                hToolBar := DllCall("FindWindowEx", "Ptr", k = 1 ? WinExist("ahk_class Shell_TrayWnd") : hToolBar, "Ptr", 0, "Str", v, "UInt", 0, "Ptr")
            }
        }
        
        SendMessage, TB_BUTTONCOUNT,,,, ahk_id %hToolBar%
        Loop % ErrorLevel {
            SendMessage, TB_GETBUTTON, A_Index - 1, RB.ptr,, ahk_id %hToolBar%
            try {
                RB.Read(TBBUTTON, szTBBUTTON)
            } catch {
                continue
            }
            try {
                RB.Read(TRAYDATA, szTRAYDATA, NumGet(&TBBUTTON + 8 + ptrSize) - RB.ptr)
            } catch {
                continue
            }
            tipOffset := NumGet(&TBBUTTON + 8 + ptrSize*2) - RB.ptr
            try {
                RB.Read(tip, 1024, tipOffset)
            }
            hWnd := NumGet(TRAYDATA)
            
            WinGet, PID, PID, ahk_id %hWnd%
            WinGet, xxx, ID, ahk_id %hWnd%
            (PID = proceccNameOrPID && found := true)
            WinGet, processName, ProcessName, ahk_id %hWnd%
            
            (processName = proceccNameOrPID && found := true)
            WinGetTitle, title, ahk_id %hWnd%
            
            if (found) {
                DetectHiddenWindows, %dhw_prev%
                return { ID: NumGet(&TRAYDATA + ptrSize, "UInt"), hWnd: hWnd}
                ; Arr.Push({ PID: PID, ProcessName: processName, ID: NumGet(&TRAYDATA + ptrSize, "UInt"), WinTitle: title
                ;             , hWnd: hWnd, Tip: tip, CallbackMessage: NumGet(&TRAYDATA + 4 + ptrSize, "UInt")
                ;             , HICON: NumGet(&TRAYDATA + 16 + ptrSize, ptrSize = 4 ? "UInt" : "UInt64") })
            }
        }
    }
    DetectHiddenWindows, %dhw_prev%
    if (proceccNameOrPID && !found)
        throw "Icon of specified process not found"
    Return found ? Arr.Pop() : Arr
}

; https://www.autohotkey.com/boards/viewtopic.php?p=456208#p456208
class RemoteBuffer {
    
    __New(PID, size) {
        static flags := (PROCESS_VM_OPERATION := 0x8) | (PROCESS_VM_WRITE := 0x20) | (PROCESS_VM_READ := 0x10)
            , Params := ["UInt", MEM_COMMIT := 0x1000, "UInt", PAGE_READWRITE := 0x4, "Ptr"]
        
        if !this.hProc := DllCall("OpenProcess", "UInt", flags, "Int", 0, "UInt", PID, "Ptr")
            throw Exception("Can't open remote process PID = " . PID . "`nA_LastError: " . A_LastError, "RemoteBuffer.__New")
      
        if !this.ptr := DllCall("VirtualAllocEx", "Ptr", this.hProc, "Ptr", 0, "Ptr", size, Params*) {
            DllCall("CloseHandle", "Ptr", this.hProc)
            throw Exception("Can't allocate memory in remote process PID = " . PID . "`nA_LastError: " . A_LastError, "RemoteBuffer.__New")
      }
   }
   
    __Delete() {
        DllCall("VirtualFreeEx", "Ptr", this.hProc, "Ptr", this.ptr, "UInt", 0, "UInt", MEM_RELEASE := 0x8000)
        DllCall("CloseHandle", "Ptr", this.hProc)
    }
   
    Read(ByRef localBuff, size, offset = 0) {
        VarSetCapacity(localBuff, size, 0)
        if !DllCall("ReadProcessMemory", "Ptr", this.hProc, "Ptr", this.ptr + offset, "Ptr", &localBuff, "Ptr", size, "PtrP", bytesRead)
            throw Exception("Can't read data from remote buffer`nA_LastError: " . A_LastError, "RemoteBuffer.Read")
        Return bytesRead
    }
   
    Write(pData, size, offset = 0) {
        if !res := DllCall("WriteProcessMemory", "Ptr", this.hProc, "Ptr", this.ptr + offset, "Ptr", pData, "Ptr", size, "PtrP", bytesWritten)
            throw Exception("Can't write data to remote buffer`nA_LastError: " . A_LastError, "RemoteBuffer.Write")
        Return bytesWritten
   }
}


