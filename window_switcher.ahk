; AutoHotkey v2
; Works with Ciantic's VirtualDesktopAccessor.dll

DllCall("LoadLibrary", "Str", A_ScriptDir "window_switcher\VirtualDesktopAccessor.dll")

SwitchDesktop(n) {
    count := DllCall("VirtualDesktopAccessor\GetDesktopCount", "Int")
    if (n < 1 || n > count)
        return
    DllCall("VirtualDesktopAccessor\GoToDesktopNumber", "Int", n - 1)
}






; Hotkeys: Win+1 … Win+9
#1::SwitchDesktop(1)
#2::SwitchDesktop(2)
#3::SwitchDesktop(3)
#4::SwitchDesktop(4)
#5::SwitchDesktop(5)
#6::SwitchDesktop(6)
#7::SwitchDesktop(7)
#8::SwitchDesktop(8)
#9::SwitchDesktop(9)
