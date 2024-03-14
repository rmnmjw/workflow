tooltip_hide() {
    ToolTip
    SetTimer, tooltip_hide, off
}

tooltip_show(msg:="", duration:=700) {
    ToolTip, %msg%
    SetTimer, tooltip_hide, %duration%
}
