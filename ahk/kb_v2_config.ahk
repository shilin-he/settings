#Requires AutoHotkey v2.0
#SingleInstance Force
#Warn
#NoEnv
SendMode "Input"
SetWorkingDir A_ScriptDir
SetTitleMatchMode 2

; ========================================================
; Config (edit here or use kb.config.ini next to this file)
; ========================================================
Config := {
    Paths: {
        VSExe:      "C:\\Program Files\\Microsoft Visual Studio\\2022\\Professional\\Common7\\IDE\\devenv.exe",
        VSCodeExe:  "C:\\Users\\***\\AppData\\Local\\Programs\\Microsoft VS Code\\Code.exe",
        EdgeExe:    "C:\\Program Files (x86)\\Microsoft\\Edge\\Application\\msedge.exe",
        ChromeExe:  "C:\\Program Files (x86)\\Google\\Chrome\\Application\\chrome.exe",
        WTExe:      "C:\\Users\\***\\AppData\\Local\\Microsoft\\WindowsApps\\wt.exe",
        GVimExe:    "C:\\Program Files\\Vim\\vim91\\gvim.exe",
        OutlookExe: "C:\\Program Files\\Microsoft Office\\root\\Office16\\OUTLOOK.EXE"
    },
    Classes: {
        WTClass:    "CASCADIA_HOSTING_WINDOW_CLASS",
        ChromeClass:"Chrome_WidgetWin_1",
        VimClass:   "Vim"
    },
    UI: {
        PaletteW: 420,
        PaletteH: 160
    }
}

iniPath := A_ScriptDir "\\kb.config.ini"
if FileExist(iniPath) {
    ; Read paths from INI, fallback to defaults
    for k, v in Config.Paths {
        try Config.Paths[k] := IniRead(iniPath, "paths", k, v)
    }
    for k, v in Config.Classes {
        try Config.Classes[k] := IniRead(iniPath, "classes", k, v)
    }
    for k, v in Config.UI {
        try Config.UI[k] := IniRead(iniPath, "ui", k, v)
    }
}

; ========================================================
; Auto-reload when script file changes (archive attribute)
; ========================================================
SetTimer(ReloadIfArchive, 1000)
ReloadIfArchive() {
    attr := FileGetAttrib(A_ScriptFullPath)
    if InStr(attr, "A") {
        FileSetAttrib("-A", A_ScriptFullPath)
        TrayTip("Reloading Script...", A_ScriptName, 1)
        Sleep 500
        Reload
        TrayTip("")
    }
}

; ========================================================
; Helpers
; ========================================================
CapsLock::Esc

centerX := A_ScreenWidth // 2
centerY := A_ScreenHeight // 2

ActivateOrRunExe(path) {
    if !path
        return
    SplitPath(path, &file)
    if WinExist("ahk_exe " file) {
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
    WinGetActiveTitle(&title)
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
ClickActiveWindow(x, y) {
    CoordMode("Mouse", "Window")
    Click "Left", x, y
    CoordMode("Mouse", "Screen")
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
CloseToolWindow() {
    Send "^+{F4}"
    Sleep 50
    Send "+{Escape}"
}

; ========================================================
; Contextual paste for bash.exe
; ========================================================
#HotIf WinActive("ahk_exe bash.exe")
^v:: SendText A_Clipboard
#HotIf

; ========================================================
; Action palette (Shift+CapsLock): token -> action
; ========================================================
actions := Map()

; Apps
actions["ms"] := (*) => ActivateOrRunExe(Config.Paths.SSMSExe)
actions["vs"] := (*) => ActivateOrRunExe(Config.Paths.VSExe)
actions["vc"] := (*) => ActivateOrRunExe(Config.Paths.VSCodeExe)
actions["eg"] := (*) => ActivateOrRunExe(Config.Paths.EdgeExe)
actions["wt"] := (*) => ActivateOrRunClass(Config.Classes.WTClass, Config.Paths.WTExe)
actions["ch"] := (*) => ActivateOrRunClass(Config.Classes.ChromeClass, Config.Paths.ChromeExe)
actions["vm"] := (*) => ActivateOrRunClass(Config.Classes.VimClass, Config.Paths.GVimExe)
actions["ol"] := (*) => ActivateOrRunExe(Config.Paths.OutlookExe)

; Windows ops
actions["x"]  := (*) => Send "!{F4}"
actions["mx"] := (*) => MaximizeActive()
actions["mmc"]:= (*) => MoveMouseActiveCenter()
actions["mmsc"]:= (*) => ClickScreenCenter()
actions["lm"] := (*) => Click "Left"

; Visual Studio actions
actions["w"]  := (*) => Send "!wl"
actions["vi"] := (*) => Send "!tv"
actions["ve"] := (*) => Send "!tl"
actions["fd"] := (*) => Send "^k^d"
actions["pm"] := (*) => Send "!tnn"
actions["pmc"]:= (*) => Send "!tno"

; ReSharper / Navigation
actions["gd"] := (*) => Send "!rng"
actions["cd"] := (*) => Send "!rnc"
actions["gb"] := (*) => Send "!{Home}"
actions["gs"] := (*) => Send "!{End}"
actions["gu"] := (*) => Send "+!{F12}"
actions["fu"] := (*) => Send "!rff"
actions["fw"] := (*) => Send "^!{F12}"
actions["hu"] := (*) => Send "^+{F7}"
actions["ne"] := (*) => Send "!+{PgDn}"
actions["pe"] := (*) => Send "+!{PgUp}"
actions["gf"] := (*) => Send "^+t"
actions["sy"] := (*) => Send "+!t"
actions["le"] := (*) => Send "^+{Backspace}"
actions["t"]  := (*) => CloseToolWindow()
actions["su"] := (*) => Send "^eu"
actions["cc"] := (*) => Send "^ec"

; Templates & files
actions["f"]  := (*) => (Send "!{Insert}", Send "f")
actions["c"]  := (*) => Send "^!{Insert}c"
actions["d"]  := (*) => Send "!rend"
actions["vd"] := (*) => Send "!renv"
actions["i"]  := (*) => Send "^!{Insert}i"
actions["e"]  := (*) => Send "!rnr"
actions["pi"] := (*) => Send "!rep"
actions["qq"] := (*) => Send "!req"
actions["fs"] := (*) => Send "^!f"
actions["gm"] := (*) => Send "!\\"

; Solution-wide Analysis
actions["swa"] := (*) => ( Send "!r", Sleep 100, Send "a", Sleep 100, Send "s" )

; Observations
actions["oc"]  := (*) => Send "!renb"
actions["owc"] := (*) => Send "!reno"
actions["so"]  := (*) => Send "!rent"

; Live Templates flows (coordinate-dependent)
actions["lt"]  := (*) => ( Send "!RL", Sleep 100, Send "{Down}", Sleep 200, ClickActiveWindow(20,35), Send "+{Tab}" )
actions["ltn"] := (*) => (
    Send "!RL", Sleep 100, Send "{Down}", Sleep 200, ClickActiveWindow(89,97),
    ClickActiveWindow(16,59), SendWithSleep("!RL+{Escape}", 100),
    SendWithSleep("{Down}", 500), ClickActiveWindow(126,130)
)
actions["ft"]  := (*) => ( Send "!RL", Sleep 100, Send "{Down}", Sleep 200, ClickActiveWindow(251,34) )
actions["cft"] := (*) => (
    Send "!RL", Sleep 100, Send "{Down}", Sleep 200, ClickActiveWindow(251,34),
    ClickActiveWindow(58,244), SendWithSleep("{Down}", 200), ClickActiveWindow(18,60),
    SendWithSleep("!RL+{Escape}", 100), SendWithSleep("{Down}", 500), ClickActiveWindow(90,151)
)

+CapsLock:: {
    tokens := ""
    for k in actions {
        tokens .= (tokens ? "," : "") k
    }
    dims := Format("w{} h{}", Config.UI.PaletteW, Config.UI.PaletteH)
    ib := InputBox("Enter action token:`n" tokens, "AHK v2 Actions", dims)
    if ib.Result = "OK" {
        token := Trim(ib.Value)
        if token && actions.Has(token)
            actions[token].Call()
    }
}

; ========================================================
; ReSharper shortcut remappings (global hotkeys)
; ========================================================
#n::  Send "!rnt"     ; Go To Type (Win+n)
#g::  Send "!rna"     ; Navigate from here (Win+g)
#Enter:: Send "^+{Enter}" ; Statement completion
#Space:: Send "^{Space}"   ; Symbol completion
#/::    Send "^+{Space}"   ; Smart auto completion
#.::    Send "^!{Space}"   ; Smart symbol completion
!k::    Send "!{Up}"       ; Move Up A Method
!j::    Send "!{Down}"     ; Move Down A Method
^+!k::  Send "^+!{Up}"     ; Process Move Method Up
^+!j::  Send "^+!{Down}"   ; Process Move Method Down
^+!h::  Send "^+!{Left}"   ; Move Member Left
^+!l::  Send "^+!{Right}"  ; Move Member Right
+!j::   Send "^!{Down}"    ; Go to next usage
+!k::   Send "^!{Up}"      ; Go to previous usage

; ========================================================
; Hotstrings
; ========================================================
::pym:: {
    SendText("if __name__ == '__main__':`n    print()")
}
