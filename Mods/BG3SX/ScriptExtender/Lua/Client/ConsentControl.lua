ConsentControl = {}
ConsentControl.__index = ConsentControl
ConsentControl.ActiveRequests = {}

function ConsentControl:Init()
    local instance = setmetatable({}, ConsentControl)
    instance:RegisterHandlers()
    return instance
end

function ConsentControl:RegisterHandlers()
    Event.RequestSceneConsent:SetHandler(function(payload)
        -- Check for an already existing request from same caster
        for _, existingRequest in pairs(ConsentControl.ActiveRequests) do
            if existingRequest.Payload.Caster == payload.Caster
               and existingRequest.Payload.Target == payload.Target then
                Debug.Print("[BG3SX] Duplicate consent request blocked")
                return
            end
        end
        local instance = ConsentControlInstance:New(payload)
        table.insert(ConsentControl.ActiveRequests, instance)
    end)
end

---@class ConsentControlInstance
---@field ID number
---@field Window ExtuiWindow
---@field Payload table
---@field Buttons table


ConsentControlInstance = {}
ConsentControlInstance.__index = ConsentControlInstance

function ConsentControlInstance:New(payload)
    local id = Table.GetNextFreeIndex(ConsentControl.ActiveRequests)
    local instance = setmetatable({
        ID = id,
        Window = Ext.IMGUI.NewWindow(id),
        Payload = payload,
        Buttons = {},
        IsDestroyed = false
    }, ConsentControlInstance)

    instance:Initialize()
    return instance
end

function ConsentControlInstance:Initialize()
    self.Window.Label = "Scene Request"
    self.Window:SetSize({300*ViewPortScale, 150*ViewPortScale})
    self.Window:SetStyle("WindowRounding", 10)
    self.Window.Closeable = true
    self.Window.NoResize = true

    local casterName = Helper.GetName(self.Payload.Caster) or "Player"
    local requestText = self.Window:AddText(string.format(
        "%s wants to initiate \na %s scene with you.",
        casterName,
        self.Payload.Type
    ))

    local acceptButton = self.Window:AddButton("Accept")
    acceptButton.OnClick = function()
        self:Accept()
    end

    local declineButton = self.Window:AddButton("Decline")
    declineButton.SameLine = true
    declineButton.OnClick = function()
        self:Decline()
    end

    self.Buttons = {
        Accept = acceptButton,
        Decline = declineButton
    }

    -- Auto-decline after 30 seconds
    Ext.Timer.WaitFor(30000, function()
        if not self.IsDestroyed then
            self:Decline()
        end
    end)
end



function ConsentControlInstance:Accept()
    Event.NewSceneRequest:SendToServer({
        Caster = self.Payload.Caster,
        Target = self.Payload.Target,
        Type = self.Payload.Type,
        IsResponse = true,
        Accepted = true
    })
    self:Destroy()
end

function ConsentControlInstance:Decline()
    Event.NewSceneRequest:SendToServer({
        Caster = self.Payload.Caster,
        Target = self.Payload.Target,
        Type = self.Payload.Type,
        IsResponse = true,
        Accepted = false
    })
    self:Destroy()
end

function ConsentControlInstance:Destroy()
    if self.IsDestroyed then
        return
    end
    self.IsDestroyed = true
    self.Window:Destroy()
    Table.RemoveByValue(ConsentControl.ActiveRequests, self)
    self = nil
end

return ConsentControl, ConsentControlInstance