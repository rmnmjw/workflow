class SlottedCopyPaste {
    static slots := {}
    
    copy(key) {
        Critical, On
            tmp := Clipboard
                Send, {Ctrl down}c{Ctrl up}
                Sleep, 50
                SlottedCopyPaste.slots[key] := Clipboard
            Clipboard := tmp
        Critical, Off
        
        copied := SlottedCopyPaste.slots[key]
        tooltip_show("Copy into slot " + key, 700)
    }
    
    paste(key) {
        Critical, On
            tmp := Clipboard
                Clipboard := SlottedCopyPaste.slots[key]
                Send, {Ctrl down}v{Ctrl up}
                Sleep, 50
            Clipboard := tmp
        Critical, Off
        
        pasted := SlottedCopyPaste.slots[key]
        tooltip_show("Paste from slot " + key, 700)
    }
}
