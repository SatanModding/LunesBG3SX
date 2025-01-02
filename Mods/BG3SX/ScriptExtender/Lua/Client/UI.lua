USERID = nil
UI = {}
UI.__index = UI
UIInstance = nil

---------------------------------------------------------------------------------------------------
--                                       Load MCM Tab
---------------------------------------------------------------------------------------------------

Mods.BG3MCM.IMGUIAPI:InsertModMenuTab(ModuleUUID, "BG3SX", function(mcm)
    UI.New(mcm)
end)

--------------------------------------------------
--------------------------------------------------

function UI.New(mcm)
    local workingArea
    local mcm = mcm or nil
    if mcm then
        workingArea = mcm:AddChildWindow("")
    else
        workingArea = Ext.IMGUI.NewWindow("")
    end

    --local u = _C().UserReservedFor.UserID
    --local id = Helper.UserToPeerID(u)
    local instance = setmetatable({
        ID = id,
        Window = workingArea,
        Settings = {},
        HotKeys = {},
    }, UI)
    if not mcm then
        instance.Window:SetSize({500, 500}, "FirstUseEver")
        -- instance.Window.Closeable = true
        -- instance.Window.OnClose = function (e) -- Re-enable if opening function has been added
        --     instance.Window:Destroy()
        -- end
    end
    USERID = _C().Uuid.EntityUuid
    UIInstance = instance
    instance:Initialize()
    return instance
end 


function UI:Initialize()
    self.PartyInterface = self:NewPartyInterface()
    self.PartyInterface:Initialize()
    -- PartyTable on top of Tabs so we can make everything Character specific depending on which one is selected
    self.TabBar = self.Window:AddTabBar("")
    self.SceneTab = self:NewSceneTab()
    self.GenitalsTab = self:NewGenitalsTab()
    self.SettingsTab = self:NewSettingsTab()
    self.WhitelistTab = self:NewWhitelistTab()
    self.NPCTab = self:NewNPCTab()
    self.DebugTab = self:NewDebugTab()

    self.SceneTab:Initialize()
    self.GenitalsTab:Initialize()
    self.SettingsTab:Initialize()
    self.WhitelistTab:Initialize()
    self.NPCTab:Initialize()
    self.DebugTab:Initialize()
end




function UI:AwaitInput(reason, payload)

    local payload = payload or nil
    self.Await = {Reason = reason, Payload = payload}
    if not self.EventListener then
        self.EventHandler = self:CreateEventHandler()
    end
end

-- function LuaEventBase:PreventListenerAction(bool)
--     if self.CanPreventAction then
--         self.ActionPrevented = bool
--     end
-- end

function UI:CreateEventHandler()
    local handler = Ext.Events.MouseButtonInput:Subscribe(function (e)
        local reason = self.Await.Reason
        local mouseoverPosition = nil
        local mouseoverTarget = nil
        -- we currently don't want to stop an event
        if not self.Await then
            return
        end
        e:PreventAction() --jjdoorframe()
        if e.Button == 1 and e.Pressed == true then
            if getMouseover() and getMouseover().Inner then
                mouseoverPosition = getMouseover().Inner.Position
                if reason == "MoveScene" then
                    self:InputRecieved(mouseoverPosition)
                elseif reason == "RotateScene" then
                    self:InputRecieved(mouseoverPosition)
                end
                if getMouseover().Inner.Inner[1] then
                    if getMouseover().Inner.Inner[1].Character then
                        mouseoverTarget = getUUIDFromUserdata(getMouseover())
                        if reason == "NewScene" then
                            self:InputRecieved(mouseoverTarget)
                        end
                    else
                        -- No Character Found
                        self:CancelAwaitInput()
                    end
                end
            end
        end
    end)
    return handler
end

function UI:CancelAwaitInput()
    Ext.Events.MouseButtonInput:Unsubscribe(self.EventHandler)
    self.Await = nil
end

function UI:InputRecieved(inputPayload)
    local reason = self.Await.Reason
    if reason == "NewScene" then
        _P("Ask for sex received. Caster: ", _C().Uuid.EntityUuid, " target = ", inputPayload)
        UIEvents.AskForSex:SendToServer({ID = USERID, Caster = _C().Uuid.EntityUuid, Target = inputPayload})
    elseif reason == "RotateScene" then
        UIEvents.RotateScene:SendToServer({ID = USERID, Scene = self.Await.Payload, Position = inputPayload})
    elseif reason == "MoveScene" then
        UIEvents.MoveScene:SendToServer({ID = USERID, Scene = self.Await.Payload, Position = inputPayload})
    end
    self:CancelAwaitInput()
end

function UI.DestroyChildren(obj)
    if obj.Children and #obj.Children > 0 then
        for _,child in pairs(obj.Children) do
            child:Destroy()
        end
    end
end

function UI.GetAnimations()
    UIEvents.FetchAllAnimations:SendToServer({ID = USERID})
end

--function UI.GetUIByID(id)
--    for _,UI in pairs(UIInstances) do
--        if UI.ID == id then
--            return UI
--        end
--    end
--end