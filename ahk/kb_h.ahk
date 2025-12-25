#Requires AutoHotkey v2.0
#SingleInstance Force
#Warn

SendMode "Input"
SetWorkingDir A_ScriptDir
SetTitleMatchMode 2

;========================================================
; Auto-reload when script file changes (archive attribute check)
;========================================================
SetTimer(ReloadIfArchive, 1000)
ReloadIfArchive() {
    attr := FileGetAttrib(A_ScriptFullPath)
    if InStr(attr, "A") {
        FileSetAttrib("-A", A_ScriptFullPath)
        TrayTip("Reloading Script...", A_ScriptName)
        Sleep(500)
        Reload()
    }
}

;========================================================
; Shared variables & helpers
;========================================================
CapsLock::Esc

centerX := A_ScreenWidth // 2
centerY := A_ScreenHeight // 2

ActivateOrRunExe(path) {
    SplitPath(path, &exeName)
    if WinExist("ahk_exe " exeName) {
        WinActivate
    } else {
        Run path
    }
}

ActivateOrRunClass(class, path := "") {
    if WinExist("ahk_class " class) {
        WinActivate
    } else if path != "" {
        Run path
    }
}

MaximizeActive() {
    title := WinGetTitle("A")
    if title
        WinMaximize title
}

MoveMouseActiveCenter() {
    hwnd := WinExist("A")
    if hwnd {
        WinGetPos(&x, &y, &w, &h, hwnd)
        MouseMove x + w//2, y + h//2, 0
    }
}

ClickScreenCenter() {
    MouseMove centerX, centerY, 0
    Click "Left"
}

CoordWindow(Func) {
    CoordMode("Mouse", "Window")
    try Func()
    finally CoordMode("Mouse", "Screen")
}

ClickActiveWindow(x, y) {
    CoordWindow(() => Click("Left", x, y))
}

ClickActiveWindowMultiple(x, y, times := 1) {
    CoordMode("Mouse", "Window")
    Click "Left", x, y, times
    CoordMode("Mouse", "Screen")
}

SendWithSleep(keys, ms := 0) {
    Send keys
    if ms > 0
        Sleep ms
}

;========================================================
; Contextual paste for bash.exe
;========================================================
#HotIf WinActive("ahk_exe bash.exe")
^v:: SendText A_Clipboard
#HotIf

;========================================================
; Action palette (Shift+CapsLock) – tokens mapped to functions
;========================================================
actions := Map()

; App launch/activate
;actions["vc"] := (*) => ActivateOrRunExe(A_AppData . "\..\Local\Programs\Microsoft VS Code\Code.exe")
actions["wt"] := (*) => ActivateOrRunClass("CASCADIA_HOSTING_WINDOW_CLASS", A_AppData . "\..\Local\Microsoft\WindowsApps\wt.exe")
actions["eg"] := (*) => ActivateOrRunExe("C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe")
actions["ch"] := (*) => ActivateOrRunExe("C:\Program Files\Google\Chrome\Application\chrome.exe")
actions["vm"] := (*) => ActivateOrRunClass("Vim", "d:\apps\Vim\vim91\gvim.exe")

; Window ops
actions["x"]  := (*) => Send("!{F4}")
actions["mx"] := (*) => MaximizeActive()
actions["mmc"]:= (*) => MoveMouseActiveCenter()
actions["mmsc"]:= (*) => ClickScreenCenter()
actions["lm"] := (*) => Click("Left")

+CapsLock:: {
    ; Present a simple palette: enter one of the tokens
    tokens := ""
    for k in actions {
        tokens .= (tokens ? ", " : "") k
    }
    ib := InputBox("Enter action token:`n" tokens, "AHK v2 Actions", "w420 h160")
    if ib.Result = "OK" {
        token := Trim(ib.Value)
        if token && actions.Has(token)
            actions[token].Call()
    }
}

;========================================================
; Hotstrings
;========================================================
::pym:: {
    SendText("if __name__ == '__main__':`n    print()")
}
