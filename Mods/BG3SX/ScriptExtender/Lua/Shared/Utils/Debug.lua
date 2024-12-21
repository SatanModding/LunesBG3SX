GLOBALDEBUG = true

function SatanPrint(debug, message)
    local modname = "[BG3SX] "
    if debug then
        if message and (type(message) == string) then
            _P(modname .. message)
        else
            _P(modname)
            _P(message)
        end
    end
end

function SatanDump(debug, message)

    if debug then
        _D(message)
    end
end

Debug = {}
Debug.Active = true
local modname = "[BG3AF] "
function Debug.Print(message)
    if Debug.Active then
        _P(modname .. "\n" .. message)
    end
end
function Debug.Dump(table)
    if Debug.Active then
        _D(modname .. "Dump:\n" .. table)
    end
end
function Debug.DumpS(table)
    if Debug.Active then
        _DS(modname .. "Shallow Dump:\n" .. table)
    end
end