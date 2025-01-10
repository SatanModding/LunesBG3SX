ConsoleCommand = {}
ConsoleCommand.__index = ConsoleCommand
local ConsoleCommands = {}

-- Using stack inspection, but limited by Lua's restrictions on local variables
local function getFunctionName()
    local info = debug.getinfo(3, "n")
    if info and info.name then
        return info.name
    end
    return "anonymous"
end

function ConsoleCommand.New(name, fn, info)
    if not fn then
        Debug.PrintWarn("Not a valid function to setup ConsoleCommands")
        return
    end

    local prefix = "BG3SX."
    Ext.RegisterConsoleCommand(prefix .. name, fn)
    if info then
        ConsoleCommands["!BG3SX." .. name] = info
    else
        ConsoleCommands["!BG3SX." .. name] = "No description provided"
    end
    -- Debug.Print("Created new console function: !" .. prefix .. name .. "\n- " .. (info or "No description provided"))
end
function ConsoleCommand.GetAll()
    Debug.Dump(ConsoleCommands)
    return ConsoleCommands
end
ConsoleCommand.New("Help", ConsoleCommand.GetAll, "Dumps every available console command")