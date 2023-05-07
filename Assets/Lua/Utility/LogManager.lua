Debug = {}
Debug.strPrefix = ""
Debug.bOpen = false

function Debug.SetPrefix(str)
    Debug.strPrefix = str
end

function Debug.SetOpen(bOpen)
    if bOpen == nil then
        bOpen = CS.GameBootConfig.Instance.bOpenDebugTest or GameConfig.PLATFORM_EDITOR or GameConfig.Instance:orTestUser()
    end
    Debug.bOpen = bOpen
end

function Debug.Log(str)
    if Debug.bOpen then
        if str then
            CS.UnityEngine.Debug.Log(Debug.strPrefix.." : "..str.."\n"..debug.traceback())
        else
            CS.UnityEngine.Debug.Log(Debug.strPrefix.." : nil".."\n"..debug.traceback())
        end
    end
end

function Debug.LogWithColor(str)
    if Debug.bOpen then
        if str then
            str = string.format("<color=#FFD700>%s</color>", str)
            str = Debug.strPrefix.." : "..str
            CS.UnityEngine.Debug.Log(str.."\n"..debug.traceback())
        else
            CS.UnityEngine.Debug.Log(Debug.strPrefix.." : nil".."\n"..debug.traceback())
        end
    end
end

function Debug.LogError(str)
    if Debug.bOpen then
        if str then
            CS.UnityEngine.Debug.LogError(Debug.strPrefix.." : "..str.."\n"..debug.traceback())
        else
            CS.UnityEngine.Debug.LogError(Debug.strPrefix.." : nil".."\n"..debug.traceback())
        end
    end
end

function Debug.Assert(bTrue, str)
    if Debug.bOpen then
        if not bTrue then
            if str then
                Debug.LogError("Assert Failed: "..str)
            else
                Debug.LogError("Assert Failed")
            end
        end
    end
end

function Debug.LogLuaTable(printTable, strTag)
    if Debug.bOpen then
        if strTag then
            strTag = strTag or ""
            strTag = "Table: "..strTag
        else
            strTag = "Table: "
        end
        
        Debug.Log(Debug.strPrefix.." : "..strTag..serpent.block(printTable)) -- multi-line indented, no self-ref section
    end
end

