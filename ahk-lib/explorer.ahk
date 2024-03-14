; https://github.com/GorvGoyl/Autohotkey-Scripts-Windows/blob/master/create_file_here.ahk
explorer_create_new_file() {
    WinHWND := WinActive()
    for win in ComObjCreate("Shell.Application").Windows {
        if (win.HWND == WinHWND) {
            dir := SubStr(win.LocationURL, 9) ; remove "file:///"
            dir := RegExReplace(dir, "%20", " ")
            break
        }
    }
    
    InputBox, file_name, New File, Name of the new file
    file_name := Trim(file_name)
    if (file_name == "") {
        return
    }
    
    file := dir . "/" . file_name
    if (FileExist(file)) {
        MsgBox, %file_name% already exists
        return
    }
    FileAppend,, %file% 
}

explorer_restart() {
    RunWait, % A_ScriptDir "./exec/restart_explorer.bat"
}
