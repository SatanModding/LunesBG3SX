Debug  = {}
Debug.GLOBALDEBUG = true
Debug.USEPREFIX = true
GLOBALDEBUG = true

local function getDebugPrefix()
    local prefix

    if Debug.USEPREFIX then
        prefix = "[BG3SX]"
    end

    if Ext.Debug.IsDeveloperMode() and Debug.USEPREFIX then
        local info = debug.getinfo(3, "nfSlu")
        local fileLocation = string.format("\"%s\" IN FILE \"%s\" AT LINE", info.name or "Unknown", info.source or "Unknown Source")
        local line = string.format("%d] :", info.currentline or "Unknown")
        return string.format("\n%s[DEBUG][Function %s %s", "[BG3SX]" , fileLocation , line)
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

function Debug.Dump(tbl)
    if Debug.Active then
        local pre = getDebugPrefix()

        _P(pre)
        _P("Dump:")
        _D(tbl)
    end
end

function Debug.DumpS(tbl)
    if Debug.Active then
        local pre = getDebugPrefix()
        _P(pre .. "Shallow Dump:")
        _DS(tbl)
    end
end

-- function Debug.PrintWarn(message)
--     if Debug.Active then
--         local pre = getDebugPrefix()
--         _PW(pre .. "\n" .. message)
--     end
-- end

-- function Debug.PrintError(message)
--         if Debug.Active then
--         local pre = getDebugPrefix()
--         _PE(pre .. "\n" .. message)
--     end
-- end

-- Debug.PW = Debug.PrintWarn
-- Debug.PE = Debug.PrintError
-- Debug.PW("Test Warning")
-- Debug.PE("Test Error")