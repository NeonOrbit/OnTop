
MenuBuilder()
{
    traylist := AppName
    traylist .= ",Service,Refresh,ResetAll,Preference,,"
    traylist .= "AppList,Supports,,Exit"
    servicesub := "Enable,Disable"
    supportsub := "Log,Help,About"
    Menu, Tray, NoStandard
    Loop, parse, traylist, `,
    {
        if (!A_LoopField)
            Menu, Tray, Add
        else
            Menu, Tray, Add, % A_LoopField, MenuHandler
    }
    Menu, Tray, Disable, 1&
    Loop, parse, servicesub, `,
        Menu, ServiceSub, Add, % A_LoopField, MenuHandler
    Loop, parse, supportsub, `,
        Menu, SupportSub, Add, % A_LoopField, MenuHandler
    Menu, Tray, Add, Service, :ServiceSub
    Menu, Tray, Add, Supports, :SupportSub
}

MenuHandler()
{
    Switch A_ThisMenuItem {
        case "Enable", "Disable":
            Service(A_ThisMenuItemPos)
        case "Refresh":
            Refresh()
        case "ResetAll":
            Refresh(true)
        case "Preference":
            Preferences()
        case "Log", "Help", "About":
            Supports(A_ThisMenuItem)
        case "AppList":
            AppList()
        case "Exit":
            ExitApp
    }
}

Service(flag)
{
    item := !(flag^1) ? 1 : 2
    mode := !(flag^1) ? "Off" : "On"
    stat := !(flag^1) ? true : false
    icon := !(flag^1) ? -AppIcon : -AppIconAlt
    srvs := !(flag^1) ? "Running" : "Stopped"
    Menu, Tray, Rename, 1&, % srvs
    Menu, ServiceSub, Check, % item "&"
    Menu, ServiceSub, Uncheck, % (item^3) "&"
    Menu, Tray, Tip, % AppName " (" srvs ")"
    If A_IsCompiled
        Menu, Tray, Icon, % A_ScriptFullPath, % icon, 1
    UpdateAllWindow(stat)
    UpdatePreference("Service", stat)
    Paused := !(flag^1) ? false : true
    Suspend % mode
    Pause % mode
}

Refresh(reset := false)
{
    list := ProcessList
    if (reset) {
        msg := "Reset app to default?"
        MsgBox, 0x1134, % AppName, % msg
        IfMsgBox Yes
            ResetAppData()
        else
            return
    }
    FetchAppData()
    flag := (Preference["Service"]) ? 1 : 2
    Service(flag)
    if (reset) {
        UpdateAllWindow(false, list)
    }
    list := []
}

AppList()
{
    list := "Active Apps List:`n`n"
    if (!ProcessList.count()) {
        list .= "  List is Empty"
    } else {
        for key, value in ProcessList {
            list .= "  " A_Index ". " key "`n"
        }
    }
    MsgBox, 0x1000, % AppName, % list
}

Preferences()
{
    Run % ConfigFile
}

Supports(item)
{
    Switch item {
        case "Log":
            Run % LogFileDir
        case "Help":
            Run % HelpFile
        case "About":
            msg := "© " . AppName . " Software ™"
            MsgBox, 0x1000, % AppName, % msg
    }
}
