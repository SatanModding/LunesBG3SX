ConsoleCommand = {}
ConsoleCommand.__index = ConsoleCommand
local ConsoleCommands = {}
local function getFunctionName(func)
    local info = debug.getinfo(3, "n")
    Debug.Print("debug.getInfo")
    Debug.Dump(info)
    return info.name or "anonymous"
end
function ConsoleCommand.New(fn, info)
    local name = getFunctionName(fn)
    if fn then
        info = info or nil
        local prefix = "BG3SX."
        Ext.RegisterConsoleCommand(prefix .. name, fn)
        if info then
            ConsoleCommands["!BG3SX." .. name] = info
        else
            ConsoleCommands["!BG3SX." .. name] = "Calls the " .. name .. " function"
        end
        Debug.Print("Created new console function = " .. prefix .. name)
    else
        Debug.PrintWarn("Not a valid function to setup ConsoleCommands")
    end
end
function ConsoleCommand.GetAll()
    return ConsoleCommands
end
local function Help()
    _D(ConsoleCommands)
end
ConsoleCommand.New(Help, "Dumps every available console command")