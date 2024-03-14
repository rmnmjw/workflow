vol_up_down(vol_up) {
    Critical, On
    if (vol_up > 0)
        Send, {Volume_Up}
    else
        Send, {Volume_Down}
    Critical, Off
}
