SetTimer, ReloadScriptIfChanged, 1000

ReloadScriptIfChanged:
{
    FileGetAttrib, FileAttribs, %A_ScriptFullPath%
        IfInString, FileAttribs, A
        {
            FileSetAttrib, -A, %A_ScriptFullPath%
                TrayTip, Reloading Script..., %A_ScriptName%, , 1
                Sleep, 1000
                Reload
                TrayTip
        }
    Return
}

;==========================
;Initialize
;==========================
#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir% 
SetTitleMatchMode 2
;=========================================
;Shared variables 
;=========================================
devenv = Visual Studio
autohotkey_spy = 
process_explorer = 
divvy = 
camrec_exe = 
mingw = 
cygwin = 
conemu = 
camrec = Recording
camrec_preview = Preview
autohotkey_scripts = 

SysGet, screen_width, 59
SysGet, screen_height, 60 
screen_center_x := screen_width/2
screen_center_y := screen_height/2
left := screen_width/2
right := screen_width
middle_of_screen := screen_height/2

Capslock::Esc

;==================================================
;bring up the R# context actions
actions="gu,gb,gs,gb,gs,gd,cm,cy,fd,ms,w,vl,mx,vm,vi,mmc,mmsc,as,lm,vs,av,ol,x,ai,c,cd,d,cft,e,f,ne,gf,ft,ff,fs,fu,fw,i,ltn,le,lt,gm,sy,oc,owc,hu,pe,so,swa,pi,qq,t,su,jj,kk,vd,mmu,mmd,mml,mmr"
+Capslock::
Input,command_input,T1/1,{enter}{esc}{tab},%actions%
if (ErrorLevel = Max | ErrorLevel = Timeout )
{
    return
}
if (command_input <> "")
{
  SetTimer, %command_input%, -1
}
return

ms:
activate_or_run_program_by_ahk_exe("C:\Program Files (x86)\Microsoft SQL Server\110\Tools\Binn\ManagementStudio\Ssms.exe")
return

vl:
activate_or_run_program_by_ahk_title("VLC media player", "C:\Program Files\VideoLAN\VLC\vlc.exe")
return 

;Move the mouse center
mmc:
move_mouse_to_middle_of_active_screen()
return


;Move the mouse center
mmsc:
click_mouse_in_middle_of_screen()
return


;Run autohotkey spy
as:
run_regular_program("C:\Program Files\AutoHotkey\au3_spy.exe")
return

; Run VS2010 as admin
av:
activate_or_run_program_by_ahk_title("Visual Studio (Administrator)", "c:\utils\vs2010.lnk")
return

vs:
activate_or_run_program_by_ahk_exe("C:\Program Files (x86)\Microsoft Visual Studio 12.0\Common7\IDE\devenv.exe")
return

ff:
activate_or_run_program_by_ahk_class("MozillaWindowClass", "firefox.exe")
return

vm:
activate_or_run_program_by_ahk_class("Vim", "C:\Program Files (x86)\Vim\vim74\gvim.exe")
return

cy:
activate_or_run_program_by_ahk_class("mintty", "C:\cygwin64\bin\mintty.exe -i /Cygwin-Terminal.ico -")
return

cm:
activate_or_run_program_by_ahk_class("VirtualConsoleClass", "c:\cmder\cmder.exe")
return


ol:
activate_or_run_program_by_ahk_exe("C:\Program Files (x86)\Microsoft Office\Office15\outlook.exe")
return

x:
Send, !{F4}
return

mx:
maximize_active_program()
return

lm:
Click
return

;================================================================
; Visual studio actions

;close all documents
w:
send,!wl
return

;open current file with vim
vi:
send,!tv
return

;open windows explorer for Visual Studio
ve:
send,!tl
return

;format document
fd:
send,^k^d
return

;===================================================
;R# Shortcut Remappings
;===================================================
;Resharper generate code(alt + insert) or in solution explorer Create file from template 
ai: 
  send, !{insert}
return

;generate code dialog
LWIN & '::
  send, !{Enter}
return

;Go To Type
LWIN & n::
Send,!rnt
return

;Resharper navigate from here
LWIN & g::
send, !rna
return

;statement completion
LWIN & Enter::
  send, ^+{enter}
return

;symbol completion
LWIN & space::
  send, ^{Space}
return

;smart auto completion
LWIN & /::
  send, ^+{Space}
return

;Smart symbol completion
LWIN & .::
Send, ^!{Space}
return

;Move Up A Method
$!k::
    Send, !{Up}
return

;Move Down A Method
$!j::
    Send, !{Down}
return

;Process Move Method Up
$^+!k::
  Send, ^+!{Up}
return
mmu:
  Send, ^+!{Up}
return

;Process Move Method Down
$^+!j::
  Send, ^+!{Down}
return
mmd:
  Send, ^+!{Down}
return

;Move Member Left
$^+!h::
    Send, ^+!{Left}
return
mml:
Send, ^+!{Left}
return

;Move Member Right
$^+!l::
    Send, ^+!{Right}
return
mmr:
Send, ^+!{Right}
return


;Process Go to next usage 
$+!j::
    Send, ^!{Down}
return
jj:
    Send, ^!{Down}
return

;Process Go to previous usage 
$+!k::
    Send, ^!{Up}
return
kk:
    Send, ^!{Up}
return
;===================================================
;R# Actions
;===================================================

;Go to declaration
gd:
send, !rng
return

;Naviagate to containing declaration
cd:
Send, !rnc
return

;Go to base symbols
gb:
Send, !{Home}
return

;Go to derived(sub) symbols
gs:
Send, !{End}
return

;Go to Usage
gu:
Send, +!{F12}
return

;Find Usages
fu:
Send, !rff
return

;Find Window
fw:
Send, ^!{F12}
return

;Highlight Current Usages
hu:
Send, ^+{F7}
return

;Next Error In File
ne:
Send, !+{PgDn}
return

;Previous Error In Solution
pe:
Send, +!{PgUp}
return

;Goto file
gf:
Send, ^+t
return

;Turn on solution wide error analysis
swa:
click_mouse_in_active_window_multiple_times(1914,1074,2)
WinWaitActive, Solution-wide Analysis,,2
Send, {Enter}
return


;observations without contract
oc:
Send, !renb
return

;observations contract
owc:
Send, !reno
return

;static observations
so:
Send, !rent
return

;new folder
f: 
Send, !{insert}f
return

;new class
c:
Send, !renc
return

;new delegate
d:
Send, !rend
return

;new delegate
vd:
Send, !renv
return

;new interface
i:
Send, !reni
return

;Recent Files
e:
Send,!rnr
return

;Parameter Info
pi:
Send,!rep
return

;Quick Doc
qq:
Send,!req
return

;file structure
fs:
Send,^!f
return

;Goto File Member
gm:
Send,!\
return

;Goto symbol
sy:
Send, +!t
return

;Live Templates
lt:
send_keystrokes_to_program("!RL",devenv)
send_with_sleep("{down}",200)
click_mouse_in_active_window(20,35)
send_keystrokes("+{tab}")
return

;last edit location
le:
Send, ^+{backspace}
return

;New Live Template
ltn:
send_keystrokes_to_program("!RL",devenv)
send_with_sleep("{down}",200)
click_mouse_in_active_window(89,97)
click_mouse_in_active_window(16,59)
send_with_sleep("!RL+{escape}",100)
send_with_sleep("{down}",500)
click_mouse_in_active_window(126,130)
return


;File Templates
ft:
send_keystrokes_to_program("!RL",devenv)
send_with_sleep("{down}",200)
click_mouse_in_active_window(251,34)
return

;Create A File Template
cft:
send_keystrokes_to_program("!RL",devenv)
send_with_sleep("{down}",200)
click_mouse_in_active_window(251,34)
click_mouse_in_active_window(58,244)
send_with_sleep("{down}",200)
click_mouse_in_active_window(18,60)
send_with_sleep("!RL+{escape}",100)
send_with_sleep("{down}",500)
click_mouse_in_active_window(90,151)
return

;Reformat Code
;ff:
;send, ^+!f
;return

;close current tool window
t:
send, ^+{F4}
send, +{ESCAPE}
return

;surround with template
su:
send, ^eu
return

;================================
;Hotstrings
;================================
::pym::
(
if __name__ == '__main__':
    print
)

;================================================================
;utilities
;================================================================
disable_timer(timer_name)
{
  SetTimer, %timer_name%, off
}

wait_for_window(window_name)
{
  WinWaitActive, %window_name%,,0.8
  return ErrorLevel
}

move_mouse(x,y)
{
  MouseMove,x,y
}

move_mouse_to_middle_of_active_screen()
{
  WinGetPos,X,Y,Width,Height,A
  move_mouse(Width/2,Height/2)
}

click_mouse_in_middle_of_screen()
{
  SysGet, screen_width, 59
  SysGet, screen_height, 60 
  click_mouse_on_screen(screen_width/2,screen_height/2)
}

screen_drag(x1,y1,x2,y2)
{
  CoordMode,Mouse,Screen
  MouseClickDrag,Left,x1,y1,x2,y2
  CoordMode,Mouse,Relative
}

click_mouse_in_active_window(x,y)
{
  click_mouse_in_active_window_multiple_times(x,y,1)
}

click_mouse_on_screen(x,y)
{
  CoordMode,Mouse,Screen
  click_mouse_in_active_window(x,y)
  CoordMode,Mouse,Relative
}

click_mouse_in_active_window_multiple_times(x,y,times)
{
  MouseClick,Left,x,y,times
}


send_with_sleep(keystrokes,duration)
{
  send, %keystrokes%
  sleep,duration
}

send_keystrokes(keystrokes)
{
  send_with_sleep(keystrokes,0)
}

send_keystrokes_to_program(keystrokes,program)
{
  IfWinActive, %program%
  {
    send_keystrokes(keystrokes)
  }
}

run_start_menu_program(program)
{
  send_with_sleep("{LWIN}",100)
  send_with_sleep(program,100)
  send_with_sleep("{enter}",1000)
}


run_regular_program(program)
{
  Run, %program%
}

position_window_and_size(x1,y1,width,height)
{
  WinGetActiveTitle, current_active_window
  WinMove,%current_active_window%,,x1,y1,width,height
}


maximize_active_program()
{
  WinGetActiveTitle,current_active_window
  WinMaximize, %current_active_window%
}

activate_or_run_program_by_ahk_class(class, program)
{
  class = ahk_class %class%
  if WinExist(class)
  {
    WinActivate
    WinMaximize
  }
  else
    Run, %program%
  return
}

activate_or_run_program_by_ahk_title(title, program)
{
  SetTitleMatchMode, 2
  IfWinExist, %title%
  {
    WinActivate
    WinMaximize
  }
  else
    Run, %program%
  return
}

activate_or_run_program_by_ahk_exe(program)
{
  path = ahk_exe %program%
  if WinExist(path)
  {
    WinActivate
    WinMaximize
  }
  else
    Run, %program%
  return
}
