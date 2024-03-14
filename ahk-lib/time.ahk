; based on https://www.autohotkey.com/boards/viewtopic.php?t=77420
time_format(T) {
    Local H, M, HH, Q:=60, R:=3600
    Return Format("{:02}:{:02}:{:02}", H:=T//R, M:=(T:=T-H*R)//Q, T-M*Q, HH:=H, HH*Q+M)
}

time_diff_sec_abs(a, b:=false) {
    EnvSub, a, %b%, seconds
    return Abs(a)
}
