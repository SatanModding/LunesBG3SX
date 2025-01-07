Debug  = {}
Debug.GLOBALDEBUG = true
Debug.USEPREFIX = true


local function getDebugPrefix()

    local prefix
    if USEPREFIX then
        prefix = "[BG3SX]"
    end

    if Ext.Debug.IsDeveloperMode() and Debug.USEPREFIX then
        local info = debug.getinfo(3, "nfSlu")
        local fileLocation = string.format("\"%s\" IN FILE \"%s\" AT LINE", info.name or "unknown", info.source or "unknown")
        local line = string.format("%d] :", info.currentline or 0)
        return string.format("\n %s %s %s", prefix , fileLocation , line)
    else
        return ""
    end
    
end



Debug.Active = true
function Debug.Print(message)
    if Debug.Active then

        local pre = getDebugPrefix()

        _P(pre .. "\n" .. message)
    end
end
function Debug.Dump(table)
    if Debug.Active then

        local pre = getDebugPrefix()

        _D(pre .. "Dump:")
        _D(table)
    end
end
function Debug.DumpS(table)
    if Debug.Active then

        local pre = getDebugPrefix()
        _P(pre .. "Shallow Dump:")
        _DS(table)
    end
end
function Debug.PrintWarn(message)
    if Debug.Active then

        local pre = getDebugPrefix()

        _PW(pre .. "\n" .. message)
    end
end
function Debug.PrintError(message)
        if Debug.Active then

        local pre = getDebugPrefix()

        _PE(pre .. "\n" .. message)
    end
end
Debug.PW = Debug.PrintWarn
Debug.PE = Debug.PrintError
-- Debug.PW("Test Warning")
-- Debug.PE("Test Error")