Imgui = {}
function Imgui.ScaleFactor()
    -- testing monitor for development is 1440p
    return Ext.IMGUI.GetViewportSize()[2] / 1440
end

---@class WindowCreationArgs
---@field IDContext string?
---@field Size vec2? # default {600, 550}
---@field MinSize vec2? # default {500, 500}
---@field MaxSizePercentage vec2? # default {0.5, 0.85}, half the width, 85% of the height
---@field Open boolean? # default false
---@field Closeable boolean? # default true
---@field AlwaysAutoResize boolean? # default true

--- Creates an imgui window with nice defaults
---@param name any
---@param args WindowCreationArgs?
---@return ExtuiWindow
function Imgui.CreateCommonWindow(name, args)
    name = name or ""
    args = args or {}
    args.Open = args.Open ~= nil and args.Open or false
    args.Closeable = args.Closeable ~= nil and args.Closeable or true
    -- args.AlwaysAutoResize = args.AlwaysAutoResize ~= nil and args.AlwaysAutoResize or true
    args.Size = args.Size ~= nil and args.Size or {600*ViewPortScale, 550*ViewPortScale}
    args.MinSize = args.MinSize ~= nil and args.MinSize or {500*ViewPortScale, 500*ViewPortScale}
    args.MaxSizePercentage = args.MaxSizePercentage ~= nil and args.MaxSizePercentage or { .5, .85}

    local win = Ext.IMGUI.NewWindow(name)
    if args.IDContext then
        win.IDContext = args.IDContext
    end
    win:SetSize(args.Size, "FirstUseEver")
    win.Open = args.Open
    win.Closeable = args.Closeable
    if args.AlwaysAutoResize then
        win.AlwaysAutoResize = args.AlwaysAutoResize
    end

    -- if Scribe and Scribe.AllWindows then
    --     table.insert(Scribe.AllWindows, win)
    -- else
    --     _P("Attempt to create window before Decor is ready: %s", name)
    -- end

    win:SetStyle("WindowMinSize", args.MinSize[1], args.MinSize[2])
    local viewportMaxConstraints = Ext.IMGUI.GetViewportSize()
    viewportMaxConstraints[1] = math.floor(viewportMaxConstraints[1] * args.MaxSizePercentage[1])
    viewportMaxConstraints[2] = math.floor(viewportMaxConstraints[2] * args.MaxSizePercentage[2])
    win:SetSizeConstraints(args.MinSize,viewportMaxConstraints)
    return win
end

function Imgui.ClearChildren(el)
    if el == nil or not pcall(function() return el.Handle end) then return end
    for _, v in pairs(el.Children) do
        if v.UserData ~= nil and v.UserData.SafeKeep ~= nil then
            v.UserData.SafeKeep()
        else
            v:Destroy()
        end
    end
end

function Imgui.FindChildByLabel(el, label)
    if el.Children and #el.Children >= 0 then
        for _,elChild in pairs(el.Children) do
            if elChild.Label == label then
                return elChild
            end
        end
    end
end

function Imgui.CreateCustomTitleBar(holder, name)
    local titleBar = holder:AddTable(name, 3)
    titleBar.SizingStretchSame = true
    local row = titleBar:AddRow()
    row:AddCell()
    local title = row:AddCell():AddText(name)
    return titleBar, title
end

return Imgui