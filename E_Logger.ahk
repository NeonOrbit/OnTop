
FLUSH_INTERVAL := 3600
FLUSH_THRESHOLD := 500

class Logger {
    maxLogFiles := 10

    __new(dir) {
        this.logDir := dir
        this.logBuffer := Array()
        this.flushedAt := A_NowUTC
    }

    max(limit) {
        this.maxLogFiles := limit
    }
 
    log(msg, flush := false)
    {
        if (msg)
            this.logBuffer.push(this.buildMsg(msg))
        if (flush or this.shouldFlush()) {
            this.logBuffer.push(this.buildMsg("Flushing logs..."))
            try {
                file := FileOpen(this.getLogFile(), "a")
                for index, value in this.logBuffer
                    file.writeLine(value)
                file.writeLine(this.buildMsg("Log Flushed."))
                file.close()
            }
            this.logBuffer := []
            this.cleanOldFiles()
            this.flushedAt := A_NowUTC
        }
    }

    cleanOldFiles()
    {
        total := 0
        filelist := ""
        Loop Files, this.logDir "\*.*"
            total++
        if (total < (this.maxLogFiles + 10))
            return
        Loop Files, this.logDir "\*.*"
            filelist .= A_LoopFileFullPath "`n"
        Sort(filelist)
        maxdel := total - this.maxLogFiles
        Loop Parse, filelist, "`n", "`r"
        {
            if (A_Index > maxdel)
                break
            FileDelete A_LoopField
        }
    }
    
    shouldFlush() {
        total := this.logBuffer.Length
        elapsed := DateDiff(this.flushedAt, A_NowUTC, "Seconds")
        return total and (total >= FLUSH_THRESHOLD or elapsed >= FLUSH_INTERVAL)
    }

    buildMsg(msg) {
        return FormatTime(, "hh:mm:ss.'" A_MSec "' tt") . " - " . msg
    }

    getLogFile() {
        return this.logDir . "\Log-" . FormatTime(, "yyyy-MM-dd") . ".log"
    }
}
