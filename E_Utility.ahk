
GetTime() ; return current time in ms
{
    return A_Now A_Msec
}

TimeElapsed(from) ; return elapsed minutes
{
    return Floor((GetTime() - from) / 100000)
}

WriteLog(msg, flush := false)
{   
    if (!Preference["Logging"])
        return
    FormatTime, time,, hh:mm:ss.%A_MSec% tt
    LogBuffer.Push(time . " - " . msg)
    totalbuffer := LogBuffer.Count()
    flushlapsed := TimeElapsed(LogFlushed)
    if flush or totalbuffer > 500 or flushlapsed >= 60 {
        if (totalbuffer) {
            msg := "Flushing " totalbuffer " Logs..."
            LogBuffer.Push(time . " - " . msg)
            FormatTime, date,, yyyy-MM-dd
            name := "Log-" . date . ".log"
            path := LogFileDir . "\" . name
            file := FileOpen(path, "a")
            for index, value in LogBuffer
                file.WriteLine(value)
            FormatTime, time,, hh:mm:ss.%A_MSec% tt
            msg := "Log Flushed."
            file.WriteLine(time . " - " . msg)
            file.Close()
            LogBuffer := []
            LogCleanUp()
        }
        LogFlushed := GetTime()
    }
}

LogCleanUp()
{
    total := 0
    filelist := ""
    maxlog := Preference["LogFileMax"]
    Loop, Files, %LogFileDir%\*.*
        total++
    if (total < maxlog+10)
        return
    Loop, Files, %LogFileDir%\*.*
        filelist .= A_LoopFileName "`n"
    Sort, filelist
    maxdel := total - maxlog
    Loop, Parse, filelist, `n, `r
    {
        if (A_Index > maxdel)
            break
        FileDelete, % A_LoopField
    }
}

HandleError(e, fatal := true, msg := "")
{
    ErrMsg := ((msg != "") ? msg : "An Error Occured!") "`n`n"
    if (e.Message ~= ".*\S.*")
        ErrMsg .= "Error:  " e.Message "`n`n"
    if (e.What ~= ".*\S.*")
        ErrMsg .= "ErrorBy:  " e.What "`n`n"
    if (e.Extra ~= ".*\S.*")
        ErrMsg .= "Details:  " e.Extra
    If (!A_IsCompiled)
        ErrMsg .= "ErrorAt:  " e.File ":" e.Line "`n`n"
    if (fatal)
        ErrMsg .= "The program will exit."
    MsgBox, % ErrMsg
    if (fatal)
        ExitApp, 1
}

GenerateHelpFile()
{
    Try {
        FileInstall, Resource\OnTopHelp.txt, % HelpFile, 1
    }
}
