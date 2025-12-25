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
actions["vc"] := (*) => ActivateOrRunExe(A_AppData . "\..\Local\Programs\Microsoft VS Code\Code.exe")
actions["eg"] := (*) => ActivateOrRunExe("C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe")
actions["wt"] := (*) => ActivateOrRunClass("CASCADIA_HOSTING_WINDOW_CLASS", A_AppData . "\..\Local\Microsoft\WindowsApps\wt.exe")
actions["ch"] := (*) => ActivateOrRunClass("Chrome_WidgetWin_1", "C:\Program Files\Google\Chrome\Application\chrome.exe")
actions["vm"] := (*) => ActivateOrRunClass("Vim", "d:\apps\Vim\vim91\gvim.exe")

; Window ops
actions["x"]  := (*) => Send("!{F4}")
actions["mx"] := (*) => MaximizeActive()
actions["mmc"]:= (*) => MoveMouseActiveCenter()
actions["mmsc"]:= (*) => ClickScreenCenter()
actions["lm"] := (*) => Click("Left")

; Visual Studio shortcuts
actions["w"]  := (*) => Send("!wl")          ; Close all documents
actions["vi"] := (*) => Send("!tv")          ; Open current file with Vim
actions["ve"] := (*) => Send("!tl")          ; Open Windows Explorer
actions["fd"] := (*) => Send("^k^d")         ; Format document
actions["pm"] := (*) => Send("!tnn")         ; Package Manager
actions["pmc"]:= (*) => Send("!tno")         ; Package Manager Console

; ReSharper / navigation actions
actions["gd"] := (*) => Send("!rng")          ; Go to declaration
actions["cd"] := (*) => Send("!rnc")          ; Containing declaration
actions["gb"] := (*) => Send("!{Home}")       ; Base symbols
actions["gs"] := (*) => Send("!{End}")        ; Derived symbols
actions["gu"] := (*) => Send("+!{F12}")       ; Go to usage
actions["fu"] := (*) => Send("!rff")          ; Find usages
actions["fw"] := (*) => Send("^!{F12}")       ; Find window
actions["hu"] := (*) => Send("^+{F7}")        ; Highlight current usages
actions["ne"] := (*) => Send("!+{PgDn}")      ; Next error in file
actions["pe"] := (*) => Send("+!{PgUp}")      ; Previous error in solution
actions["gf"] := (*) => Send("^+t")           ; Goto file
actions["sy"] := (*) => Send("+!t")           ; Goto symbol
actions["le"] := (*) => Send("^+{Backspace}") ; Last edit location
actions["t"]  := (*) => (Send("^+{F4}"), Send("+{Escape}")) ; Close current tool window
actions["su"] := (*) => Send("^eu")           ; Surround with template
actions["cc"] := (*) => Send("^ec")           ; Code cleanup

; Template & file actions
actions["f"]  := (*) => (Send("!{Insert}"), Send("f")) ; new folder
actions["c"]  := (*) => Send("^!{Insert}c") ; new class
actions["d"]  := (*) => Send("!rend")        ; new delegate
actions["vd"] := (*) => Send("!renv")        ; new delegate variant
actions["i"]  := (*) => Send("^!{Insert}i") ; new interface
actions["e"]  := (*) => Send("!rnr")        ; Recent files
actions["pi"] := (*) => Send("!rep")        ; Parameter info
actions["qq"] := (*) => Send("!req")        ; Quick doc
actions["fs"] := (*) => Send("^!f")          ; File structure
actions["gm"] := (*) => Send("!\\")          ; Goto file member

; Solution-wide Analysis (try menu path; fallback clicks if needed)
actions["swa"] := (*) => (
    Send("!r"), Sleep(100), Send("a"), Sleep(100), Send("s")
)

; Observations (custom R# actions)
actions["oc"]  := (*) => Send("!renb")
actions["owc"] := (*) => Send("!reno")
actions["so"]  := (*) => Send("!rent")

; Live Templates menu flows (coordinates retained; may require DPI tweak)
actions["lt"]  := (*) => (
    Send("!RL"), Sleep(100), Send("{Down}"), Sleep(200), ClickActiveWindow(20,35), Send("+{Tab}")
)
actions["ltn"] := (*) => (
    Send("!RL"), Sleep(100), Send("{Down}"), Sleep(200), ClickActiveWindow(89,97),
    ClickActiveWindow(16,59), SendWithSleep("!RL+{Escape}", 100),
    SendWithSleep("{Down}", 500), ClickActiveWindow(126,130)
)
actions["ft"]  := (*) => (
    Send("!RL"), Sleep(100), Send("{Down}"), Sleep(200), ClickActiveWindow(251,34)
)
actions["cft"] := (*) => (
    Send("!RL"), Sleep(100), Send("{Down}"), Sleep(200), ClickActiveWindow(251,34),
    ClickActiveWindow(58,244), SendWithSleep("{Down}", 200), ClickActiveWindow(18,60),
    SendWithSleep("!RL+{Escape}", 100), SendWithSleep("{Down}", 500), ClickActiveWindow(90,151)
)

; Method/member movement sequences
actions["mmu"] := (*) => Send("^+!{Up}")
actions["mmd"] := (*) => Send("^+!{Down}")
actions["mml"] := (*) => Send("^+!{Left}")
actions["mmr"] := (*) => Send("^+!{Right}")
actions["jj"]  := (*) => Send("^!{Down}")
actions["kk"]  := (*) => Send("^!{Up}")

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
; ReSharper shortcut remappings (hotkeys rather than tokens)
;========================================================
#n::  Send("!rnt")     ; Go To Type (Win+n)
#g::  Send("!rna")     ; Navigate from here (Win+g)
#Enter:: Send("^+{Enter}") ; Statement completion
#Space:: Send("^{Space}")   ; Symbol completion
#/::    Send("^+{Space}")   ; Smart auto completion
#.::    Send("^!{Space}")   ; Smart symbol completion
!k::    Send("!{Up}")       ; Move Up A Method
!j::    Send("!{Down}")     ; Move Down A Method
^+!k::  Send("^+!{Up}")     ; Process Move Method Up
^+!j::  Send("^+!{Down}")   ; Process Move Method Down
^+!h::  Send("^+!{Left}")   ; Move Member Left
^+!l::  Send("^+!{Right}")  ; Move Member Right
+!j::   Send("^!{Down}")    ; Go to next usage
+!k::   Send("^!{Up}")      ; Go to previous usage

;========================================================
; Hotstrings
;========================================================
::pym:: {
    SendText("if __name__ == '__main__':`n    print()")
}
