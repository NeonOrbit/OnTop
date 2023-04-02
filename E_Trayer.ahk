
TrayListMain := A_ScriptName ",Service,Refresh,ResetAll,Shortcuts,,AppList,Support,,Exit"
TrayListSrvc := "Enable,Disable"
TrayListSupp := "Log,Help,Update,About"

class Trayer {
    serviceSub := Menu()
    supportSub := Menu()
    eventHandler := this.handleEvents.bind(this)

    init(state) {
        A_TrayMenu.delete()
        Loop Parse, TrayListMain, ","
        {
            if (!A_LoopField)
                A_TrayMenu.add()
            else
                A_TrayMenu.add(A_LoopField, this.eventHandler)
        }
        Loop Parse, TrayListSrvc, ","
            this.serviceSub.add(A_LoopField, this.eventHandler)
        Loop Parse, TrayListSupp, ","
            this.supportSub.add(A_LoopField, this.eventHandler)
        A_TrayMenu.disable("1&")
        A_TrayMenu.add("Service", this.serviceSub)
        A_TrayMenu.add("Support", this.supportSub)
    }

    update(state)
    {
        position := state ? 1 : 2
        icon := state ? -APP_ICON : -ALT_ICON
        srvs := state ? "Running" : "Stopped"
        if (A_IsCompiled) {
            TraySetIcon(A_ScriptFullPath, icon, 1)
        }
        A_TrayMenu.rename("1&", srvs)
        A_IconTip := A_ScriptName . " (" . srvs . ")"
        this.serviceSub.check(position . "&")
        this.serviceSub.uncheck((position ^ 3) . "&")
    }

    handleEvents(item, pos, obj)
    {
        state := pos = 1 ? true : false
        switch (item) {
            case "Enable", "Disable":
                Critical
                UpdateAppService(state)
            case "Refresh":
                this.refresh()
            case "ResetAll":
                this.refresh(true)
            case "Shortcuts":
                ShowShortcutsWindow()
            case "AppList":
                this.showAppList()
            case "Log":
                FlushLog()
                Run APP_LOG_FILE_DIR
            case "Help":
                MsgBox(HelpText,, 0x1000)
            case "Update":
                Run UPDATE_URL
            case "About":
                MsgBox(AboutText,, 0x1000)
            case "Exit":
                ExitApp
        }
    }

    refresh(reset := false)
    {
        Critical("On")
        if (reset) {
            if (MsgBox("Reset to default?",, 0x1134) = "Yes") {
                UpdateAllWindows(false)
                ResetAppData()
            } else {
                return
            }
        }
        RefreshApp()
        Critical("Off")
    }

    showAppList()
    {
        list := "Active Apps List:`n`n"
        if (!ProcessList.count) {
            list .= "  List is Empty"
        } else {
            for item in ProcessList {
                list .= "  " . A_Index . ". " . item "`n"
            }
        }
        MsgBox(list,, 0x1000)
    }
}

AboutText := ""
. APP_NAME . "  (" APP_VERSION . ")`n`n"
. "Developer:  " . DEVELOPER . "`n`n"
. "Source Code:  " . SOURCE_SITE . "`n"

HelpText := ""
. "Features:`n`n"
. "|-> Pin Window (win+space):  Keeps a window on top of other windows.`n`n"
. "|-> Unpin Window (win+alt+space):  Removes the ontop ability of a window.`n`n"
. "|-> Pin Program (win+shift+space):  Keeps an app (not just a window) always on top.`n`n"
. "|-> Unpin Program (win+shift+alt+space):  Removes the ontop ability of a previously pinned app.`n`n"
. "`n"
. "[-] Pin Window* ability is temporary, which means it will remain only until the window is closed.`n"
. "[-] Pin Program* ability is sticky, it will remain in effect until the user unpin it manually.`n"
. "`n"
. "To change the default shortcut keys, please go to OnTop tray menu.`n"
