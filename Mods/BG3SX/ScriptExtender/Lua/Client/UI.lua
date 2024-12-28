-- TODO Skiz. I need an autoerection setting  and a Stop Sex button

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

    local id = _C().Uuid.EntityUuid
    --local u = _C().UserReservedFor.UserID
    --local id = Helper.UserToPeerID(u)
    local instance = setmetatable({
        ID = id,
        Window = workingArea,
        HotKeys = {},
    }, UI)
    if not mcm then
        instance.Window:SetSize({500, 500}, "FirstUseEver")
        -- instance.Window.Closeable = true
        -- instance.Window.OnClose = function (e) -- Re-enable if opening function has been added
        --     instance.Window:Destroy()
        -- end
    end
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
    self.DebugTab = self:NewDebugTab()

    self.SceneTab:Initialize()
    self.GenitalsTab:Initialize()
    self.SettingsTab:Initialize()
    self.DebugTab:Initialize()
end




function UI:AwaitInput(whatFor, payload)
    local payload = payload or nil
    self.Await = {whatFor = whatFor, payload = payload}
    if not self.EventListener then
        self.EventListener = self:CreateListener()
    end
end


function UI:CreateListener()
    --jjdoorframe()
    local listener = Ext.Events.MouseButtonInput:Subscribe(function (e)
        -- we currently don't want to stop an event
        if not self.Await then
            return
        end
        e:PreventAction()
        if e.Button == 1 and e.Pressed == true then
            if getMouseover() and getMouseover().Inner and getMouseover().Inner.Inner[1] and getMouseover().Inner.Inner[1].Character then
                if self.Await.whatFor == "NewScene" then
                    self:InputRecieved()
                end
            end
        end
    end)
    return listener
end

function UI:InputRecieved()
    if self.Await.whatFor == "NewScene" then
        self.Await = nil
        -- target is not set correcty, sends userID instead

        local target = getUUIDFromUserdata(getMouseover())

        -- if no target exists, do nothing. Then a non entity has been clicked
        if not target then
            return
        end

        UIEvents.AskForSex:SendToServer({ID = self.ID, Caster = _C().Uuid.EntityUuid, Target = target})
    elseif self.Await.whatFor == "ChangePosition" then
        UIEvents.ChangePosition:SendToServer({ID = self.ID, Scene = self.Await.payload, Position = getMouseover().Inner.WorldPosition})
    end
    self.EventListener = nil -- Destroy event listener after recieving input
end

function UI.DestroyChildren(obj)
    if obj.Children and #obj.Children > 0 then
        for _,child in pairs(obj.Children) do
            child:Destroy()
        end
    end
end

function UI.GetAnimations()
    UIEvents.FetchAllAnimations:SendToServer({ID = UIInstance.ID})
end

--function UI.GetUIByID(id)
--    for _,UI in pairs(UIInstances) do
--        if UI.ID == id then
--            return UI
--        end
--    end
--end