
AppName := "OnTop", Version := "1.0.1"
;@Ahk2Exe-Let Name = %A_PriorLine~U)^(.+"){1}(.+)".*$~$2%
;@Ahk2Exe-Let Version = %A_PriorLine~U)^(.+"){3}(.+)".*$~$2%
;@Ahk2Exe-ExeName %A_ScriptName~\.[^\.]+$~ %%U_Version%.exe%
;@Ahk2Exe-UpdateManifest 1, %U_Name%, %U_Version%.0
;@Ahk2Exe-SetName %U_Name%
;@Ahk2Exe-SetVersion %U_Version%.0
;@Ahk2Exe-SetDescription %U_Name%
;@Ahk2Exe-SetCopyright © %U_Name% Software ™
;@Ahk2Exe-SetMainIcon Resource\Icon.ico
;@Ahk2Exe-AddResource Resource\Icon.ico, 160
;@Ahk2Exe-AddResource Resource\Icon.ico, 206
;@Ahk2Exe-AddResource Resource\IconAlt.ico, 207
;@Ahk2Exe-AddResource Resource\IconAlt.ico, 208
/*@Ahk2Exe-Keep
#ErrorStdOut
#SingleInstance Ignore
*/

#NoEnv
#Persistent
#MenuMaskKey vkFF

#Include E_Trayer.ahk
#Include E_Utility.ahk

SendMode Input
SetTitleMatchMode 1
DetectHiddenWindows On

Global Preference   := []
Global ProcessList  := []

Global LogBuffer    := []
Global LogFlushed   := 0
Global WindowEvent  := 0

Global HKWindSet    := "#SPACE"
Global HKWindRem    := "#!SPACE"
Global HKProgSet    := "#+SPACE"
Global HKProgRem    := "#!+SPACE"

Global AppName      := AppName
Global Version      := Version
Global AppIcon      := 0000206
Global AppIconAlt   := 0000207
Global LogFileDir   := AppName "Logs"
Global DefaultDir   := A_AppData "\" AppName
Global ResourceDir  := A_ScriptDir "\Resource"
Global HelpFile     := DefaultDir "\" AppName "Help.txt"
Global ConfigFile   := DefaultDir "\" AppName "Config.ini"

Try {
    AppStart()
} catch e {
    HandleError(e)
}
OnExit("OnAppExit")

AppStart()
{
    FileCreateDir % DefaultDir
    SetWorkingDir % DefaultDir
    FileCreateDir % LogFileDir
    LogFlushed := GetTime()
    WriteLog("[App Started]")
    MenuBuilder()
    FetchAppData()
    if (!Preference.HasKey("AppInit"))
        InitializeApp()
    flag := (Preference["Service"]) ? 1 : 2
    Service(flag)
    UpdateAllWindow(Preference["Service"])
}

OnAppExit()
{
    Try {
        UpdateAllWindow(false)
        WriteLog("[App Terminated]", true)
    }
    return 0
}

InitializeApp()
{
    GenerateHelpFile()
    UpdatePreference("AppInit", true)
    UpdatePreference("Service", true)
    UpdatePreference("Logging", false)
    UpdatePreference("LogFileMax", 30)
    UpdatePreference("HKWindSet", HKWindSet)
    UpdatePreference("HKWindRem", HKWindRem)
    UpdatePreference("HKProgSet", HKProgSet)
    UpdatePreference("HKProgRem", HKProgRem)
}

FetchAppData()
{
    Preference := []
    ProcessList := []
    IniRead, pref, %ConfigFile%, Preference
    for index, value in StrSplit(pref, "`n") {
        item := StrSplit(value, "=")
        Preference[item[1]] := item[2]
    }
    IniRead, process, %ConfigFile%, ProcessList
    for index, value in StrSplit(process, "`n") {
        ProcessList[StrSplit(value, "=")[1]] := "on"
    }
}

ResetAppData()
{
    Preference := []
    ProcessList := []
    FileDelete, %ConfigFile%
    InitializeApp()
}

UpdateHotKey()
{
    try {
        key := "#+c"
        HotKey, % key, PinWindow
        HotKey, % key, UnpinWindow
        HotKey, % key, PinProgram
        HotKey, % key, UnpinProgram
    } catch e {
        HandleError(e)
    }
}

UpdatePreference(key, val := "")
{
    Preference[key] := val
    IniWrite, %val%, %ConfigFile%, Preference, %key%
}

UpdateProcessList(process, add)
{
    if (add) {
        ProcessList[process] := true
        IniWrite, %true%, %ConfigFile%, ProcessList, %process%
    } else {
        ProcessList.Delete(process)
        IniDelete, %ConfigFile%, ProcessList, %process%
    }
}

IsValidWindow(process, uid)
{
    WinGetTitle, title, ahk_id %uid%
    if (process and title ~= ".*\S.*"
        and !(process = AppName . ".exe")) {
        if (process = "explorer.exe") {
            WinGetClass, class, ahk_id %uid%
            if !(class = "CabinetWClass" or class = "#32770") {
                return false
            }
        }
        return true
    }
    return false
}

ToggleAlwaysOnTop(uid, state)
{
    ontop := state ? "on" : "off"
    Loop, 3 {
        WinGet, style, ExStyle, ahk_id %uid%
        if (((style & 0x8) && true) = state)
            break
        WinSet, AlwaysOnTop, %ontop%, ahk_id %uid%
    }
}

GetActiveProcess(uid) {
    WinGet, process, ProcessName, ahk_id %uid%
    if (process = "ApplicationFrameHost.exe") {
        ControlGet, hwnd, Hwnd,
            , Windows.UI.Core.CoreWindow1, ahk_id %uid%
        process := ""
        if (hwnd) {
            WinGet, process, ProcessName, ahk_id %hwnd%
        }
    }
    return process
}

UpdateAllWindow(state, list := "")
{
    if (!list)
        list := ProcessList
    for key, value in list {
        UpdateWindowState(, key, state)
    }
}

UpdateWindowState(uid := "", process := "", state := true)
{
    list := ""
    if (process) {
        DetectHiddenWindows, off
        WinGet, list, List, ahk_exe %process%
        DetectHiddenWindows, on
    }
    if (list) {
        loop %list% {
            _id := list%list%
            if IsValidWindow(process, _id) {
                ToggleAlwaysOnTop(_id, state)
            }
            list--
        }
    } else if (uid) {
        ToggleAlwaysOnTop(uid, state)
        parent := DllCall("GetParent", UInt, uid)
        if (parent and IsValidWindow("-", parent)) {
            sleep 10
            ToggleAlwaysOnTop(parent, state)
        }
    }
}

OnActiveWindowChange(hWinEventHook, vEvent, hWnd)
{
    Static _ := DllCall("user32\SetWinEventHook"
                        , UInt, 0x3, UInt, 0x3, Ptr, 0, Ptr
                        , RegisterCallback("OnActiveWindowChange")
                        , UInt, 0, UInt, 0, UInt, 0, Ptr)
    Try {
        WindowEvent := token := GetTime()
        while true {
            process := GetActiveProcess(hWnd)
            if (process or token < WindowEvent or A_Index > 50)
                break
            sleep 50
        }
        if ProcessList.HasKey(process) and IsValidWindow(process, hWnd) {
            UpdateWindowState(hWnd)
        }
    } Catch E {
        WriteLog("Error[OnActiveWindowChange]: " E.Message)
    }
}


;; Register Hotkeys

#SPACE::    ; Win+Space to pin a single window
Suspend
Try {
    WinGet, hWindow, ID, A
    ToggleAlwaysOnTop(hWindow, true)
} Catch E {
    HandleError(E, false, "Failed to pin the window!")
}
Return

#!SPACE::   ; Win+Alt+Space to unpin a single window
Suspend
Try {
    WinGet, hWindow, ID, A
    ToggleAlwaysOnTop(hWindow, false)
} catch e {
    HandleError(e, false, "Failed to unpin the window!")
}
Return

#+SPACE::   ; Win+Shift+Space to pin a program
Try {
    WinGet, hWindow, ID, A
    wProcess := GetActiveProcess(hWindow)
    if IsValidWindow(wProcess, hWindow) {
        UpdateProcessList(wProcess, true)
        UpdateWindowState(hWindow, wProcess, true)
    }
} catch e {
    HandleError(e, false, "Failed to pin the program!")
}
Return

#!+SPACE::  ; Win+Shift+Alt+Space unpin a program
Try {
    WinGet, hWindow, ID, A
    wProcess := GetActiveProcess(hWindow)
    if IsValidWindow(wProcess, hWindow) {
        if ProcessList.HasKey(wProcess) {
            UpdateProcessList(wProcess, false)
            UpdateWindowState(hWindow, wProcess, false)
        }
    }
} catch e {
    HandleError(e, false, "Failed to unpin the program!")
}
Return
