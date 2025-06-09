USERID = nil
ViewPort = Ext.IMGUI.GetViewportSize()
ViewPortScale = Ext.Require("Client/IMGUI.lua").ScaleFactor()
MCMActive = Mods and Mods.BG3MCM -- true or false depending on if MCM is active without storing it in a global variable

---@class UI
---@field Ready boolean
---@field Window ExtuiWindow|ExtuiChildWindow
---@field Settings table<string, any>
---@field HotKeys table<string, any>
---@field Await table<string, any>
---@field KeyInputHandler LuaEventBase|nil
---@field MouseInputHandler LuaEventBase|nil
---@field ControllerInputHandler LuaEventBase|nil
---@field ControllerAxisHandler LuaEventBase|nil
---@field TabBar ExtuiTabBar
---@field PartyInterface PartyInterface
---@field SceneTab SceneTab
---@field AppearanceTab AppearanceTab
---@field WhitelistTab WhitelistTab
---@field NPCTab NPCTab
---@field SettingsTab SettingsTab
---@field DebugTab DebugTab|nil
---@field FAQTab FAQTab
UI = {
    Ready = false,
}
UI.__index = UI

local PartyInterface = Ext.Require("Client/PartyInterface.lua")
local SceneTab = Ext.Require("Client/Tabs/SceneTab.lua")
local AppearanceTab = Ext.Require("Client/Tabs/AppearanceTab.lua")
local WhitelistTab = Ext.Require("Client/Tabs/WhitelistTab.lua")
local NPCTab = Ext.Require("Client/Tabs/NPCTab.lua")
local SettingsTab = Ext.Require("Client/Tabs/SettingsTab.lua")
local SceneControl, SceneControlInstance = Ext.Require("Client/SceneControl.lua")
local DebugTab = Ext.Require("Client/Tabs/DebugTab.lua")
local FAQTab = Ext.Require("Client/Tabs/FAQTab.lua")

--------------------------------------------------
--------------------------------------------------

function UI:New(mcm)
    local window
    if mcm then
        window = mcm:AddChildWindow("BG3SX")
    else
        window = Ext.IMGUI.NewWindow("BG3SX")
        window:SetSize({500*ViewPortScale, 500*ViewPortScale}, "FirstUseEver")
    end

    self.Window = window
    self.Settings = {}
    self.HotKeys = {}

    USERID = _C().Uuid.EntityUuid
    return self
end

function UI:Init()
    self.PartyInterface = PartyInterface:New(self.Window)
    self.PartyInterface:Init()

    self.TabBar = self.Window:AddTabBar("")
    self.SceneTab = SceneTab:New(self.TabBar)
    self.AppearanceTab = AppearanceTab:New(self.TabBar)
    self.WhitelistTab = WhitelistTab:New(self.TabBar)
    self.WhitelistTab.Tab.Visible = false
    self.NPCTab = NPCTab:New(self.TabBar)
    self.SettingsTab = SettingsTab:New(self.TabBar)
    self.FAQTab = FAQTab:New(self.TabBar)
    self.DebugTab = DebugTab:New(self.TabBar)
    self.DebugTab.Tab.Visible = false


    self.NPCTab:FetchAllNPCs()

    self.SceneTab:Init()
    self.AppearanceTab:Init()
    self.WhitelistTab:Init()
    self.NPCTab:Init()
    self.SettingsTab:Init()
    self.FAQTab:Init()
    self.DebugTab:Init()


    self.SceneControl = SceneControl:Init()

    Event.FinishedBuildingNPCUI:SendToServer({ID=USERID})  -- Restores stored NPCs from last session
    self.Ready = true
    -- Event.UIInitialized:SendToServer({ID = USERID})
    -- Send ModEvent about UI being ready
end

---@param settingName string
---@param value any
function UI:RegisterSetting(settingName,value)
    self.Settings[settingName] = value
end

function UI:AwaitInput(reason, payload)

    local payload = payload or nil
    if self.MouseInputHandler or self.ControllerInputHandler then
        self:CancelAwaitInput() -- Sanity Check Reset
    end
    self.Await = {Reason = reason, Payload = payload}
    self.KeyInputHandler, self.MouseInputHandler, self.ControllerInputHandler, self.ControllerAxisHandler = self:CreateEventHandler()
end

function UI:CreateEventHandler()
    if not self.Await then -- Sanity Check
        return nil,nil,nil,nil
    end

    local reason = self.Await.Reason
    local mouseoverPosition = nil
    local mouseoverTarget = nil

    ---------------------------------------------------------
    --- KEYBOARD Keys
    ---------------------------------------------------------

    local keyHandler = Ext.Events.KeyInput:Subscribe(function (e)
        if e.Key == "ESCAPE" and e.Pressed == true then -- .Pressed checks if it was the first input registered or a held down event - Check .Repeat for this
            self:CancelAwaitInput("Canceled")
            self:ShowWindows()
        end
    end)

    ---------------------------------------------------------
    --- MOUSE Buttons
    ---------------------------------------------------------

    local mouseHandler
    mouseHandler = Ext.Events.MouseButtonInput:Subscribe(function (e)
        e:PreventAction() --jjdoorframe()
        if e.Button == 1 and e.Pressed == true then
            if getMouseover() and getMouseover().Inner then
                mouseoverPosition = getMouseover().Inner.Position
                if reason == "MoveScene" then
                    self:InputRecieved(mouseoverPosition)
                elseif reason == "RotateScene" then
                    self:InputRecieved(mouseoverPosition)
                elseif reason == "NewSFWScene" or reason == "NewNSFWScene" then
                    _P("NewSFWScene or NewNSFWScene")
                    if getMouseover().Inner.Inner[1] then
                        if getMouseover().Inner.Inner[1].Character then
                            mouseoverTarget = getUUIDFromUserdata(getMouseover()) or getMouseover().UIEntity.Uuid.EntityUuid or nil
                            if mouseoverTarget ~= nil then
                                self:InputRecieved(mouseoverTarget)
                            else
                                self:CancelAwaitInput("No entity found")
                            end
                        elseif self.PartyInterface:GetHovered() then
                            mouseoverTarget = self.PartyInterface:GetHovered().Uuid or nil
                            if mouseoverTarget ~= nil then
                                self:InputRecieved(mouseoverTarget)
                            else
                                self:CancelAwaitInput("No entity found")
                            end
                        else
                            self:CancelAwaitInput("No entity found")
                        end
                    else
                        self:CancelAwaitInput("No entity found")
                    end
                else
                    self:CancelAwaitInput("No entity found")
                end
            else
                self:CancelAwaitInput("No entity found")
            end
        elseif e.Button == 3 and e.Pressed == true then -- Button 3 is right click | 2 is middle mouse click
            self:CancelAwaitInput("Canceled") -- Cancel
        end
    end)

    ---------------------------------------------------------
    --- CONTROLLER Buttons
    ---------------------------------------------------------

    local function controllerCancelAwaitInput(reason)
        local reason = reason or nil
        self:CancelAwaitInput(reason)
        self:ShowWindows()
    end

    local controllerHandler = Ext.Events.ControllerButtonInput:Subscribe(function (e)
        local enteredTargeting
        local collapsed
        if not e.Button == "LeftStick" then -- Only allow "LeftStick" click to enable targeting  - TODO check PS5 Controller
            e:PreventAction()
        end

        -- self.Settings["AutomaticControllerTargetingMode"]
        -- Add LeftStick press injection

        if e.Button == "LeftStick" and e.Pressed == true then
            enteredTargeting = true
            self:HideWindows()
        elseif e.Button == "A" and e.Pressed == true and not enteredTargeting then-- UI target selection handling, when not in targeting mode
            if reason == "NewSFWScene" or reason == "NewNSFWScene" then
                if getMouseover() and getMouseover().UIEntity then -- In case a UI entity has been found
                    mouseoverTarget = getUUIDFromUserdata(getMouseover()) or getMouseover().UIEntity.Uuid.EntityUuid or nil
                    if mouseoverTarget ~= nil then
                        self:InputRecieved(mouseoverTarget)
                    else
                        self:CancelAwaitInput("No entity found")
                    end
                elseif self.PartyInterface:GetHovered() then
                    mouseoverTarget = self.PartyInterface:GetHovered().Uuid or nil
                    if mouseoverTarget ~= nil then
                        self:InputRecieved(mouseoverTarget)
                    else
                        self:CancelAwaitInput("No entity found")
                    end
                else
                    self:CancelAwaitInput("No entity found")
                end
            end
        end

        if enteredTargeting then
            if e.Button == "A" and e.Pressed == true then
                if getMouseover() and getMouseover().Inner then
                    mouseoverPosition = getMouseover().Inner.Position
                    if reason == "MoveScene" then
                        self:InputRecieved(mouseoverPosition)
                        self:ShowWindows()
                    elseif reason == "RotateScene" then
                        self:InputRecieved(mouseoverPosition)
                        self:ShowWindows()
                    elseif reason == "NewSFWScene" or reason == "NewNSFWScene" then
                        if getMouseover().Inner.Inner[1] then
                            if getMouseover().Inner.Inner[1].Character then
                                mouseoverTarget = getUUIDFromUserdata(getMouseover()) or getMouseover().UIEntity.Uuid.EntityUuid or nil
                                if mouseoverTarget ~= nil then
                                    self:InputRecieved(mouseoverTarget)
                                else
                                   controllerCancelAwaitInput("No entity found")
                                end
                            elseif self.PartyInterface:GetHovered() then
                                mouseoverTarget = self.PartyInterface:GetHovered().Uuid or nil
                                if mouseoverTarget ~= nil then
                                    self:InputRecieved(mouseoverTarget)
                                else
                                    controllerCancelAwaitInput("No entity found")
                                end
                            else
                                controllerCancelAwaitInput("No entity found")
                            end
                        else
                            controllerCancelAwaitInput("No entity found")
                        end
                    else
                        controllerCancelAwaitInput("No entity found")
                    end
                else
                    controllerCancelAwaitInput("No entity found")
                end
            elseif e.Button == "LeftStick" and e.Pressed == true then
                enteredTargeting = false
                if self.Window.Open == false then
                    self:ShowWindows()
                end
            end
        elseif e.Button == "B" and e.Pressed == true then -- Cancel out of targeting
            controllerCancelAwaitInput("Canceled")
        end
    end)

    ---------------------------------------------------------
    --- CONTROLLER Axises
    ---------------------------------------------------------

    local controllerAxisHandler = Ext.Events.ControllerAxisInput:Subscribe(function (e)
        if e.Axis == "TriggerLeft" or e.Axis == "TriggerRight" then
            e:PreventAction()
        end
    end)
    return keyHandler, mouseHandler, controllerHandler, controllerAxisHandler
end

function UI:DisplayInfoText(reason, duration)
    -- When floor is clicked, error is thrown
    -- if not self.SceneTab then
    --     return
    -- end
    local info = self.SceneTab.InfoText
    info.Label = reason
    info.Visible = true
    if duration then
        Ext.Timer.WaitFor(duration, function()
            info.Visible = false
        end)
    end
end
function UI:HideInfoText()
    local info = self.SceneTab.InfoText
    info.Visible = false
end

function UI:CancelAwaitInput(reason)
    local reason = reason or nil
    if reason then
        self:DisplayInfoText(reason, 3000)
    end

    if self.KeyInputHandler then
        Ext.Events.KeyInput:Unsubscribe(self.KeyInputHandler)
        self.KeyInputHandler = nil
    end
    if self.MouseInputHandler then
        Ext.Events.MouseButtonInput:Unsubscribe(self.MouseInputHandler)
        self.MouseInputHandler = nil
    end
    if self.ControllerInputHandler then
        Ext.Events.ControllerButtonInput:Unsubscribe(self.ControllerInputHandler)
        self.ControllerInputHandler = nil
    end
    if self.ControllerAxisHandler then
        Ext.Events.ControllerAxisInput:Unsubscribe(self.ControllerAxisHandler)
        self.ControllerAxisHandler = nil
    end
    self.Await = nil
end

function UI:InputRecieved(inputPayload)
    if not self.Await then return end
    local reason = self.Await.Reason
    if reason == "NewSFWScene" then
        Event.NewSceneRequest:SendToServer({ID = USERID, Caster = UI:GetSelectedCharacter(), Target = inputPayload, Type = "SFW"})
    elseif reason == "NewNSFWScene" then
        Event.NewSceneRequest:SendToServer({ID = USERID, Caster = UI:GetSelectedCharacter(), Target = inputPayload, Type = "NSFW"})
    elseif reason == "RotateScene" then
        Event.RotateScene:SendToServer({ID = USERID, Scene = self.Await.Payload, Position = inputPayload})
    elseif reason == "MoveScene" then
        Event.MoveScene:SendToServer({ID = USERID, Scene = self.Await.Payload, Position = inputPayload})
    end
    self:CancelAwaitInput()
end

function UI:HideWindows()
    if MCMActive then
        Mods.BG3MCM.IMGUIAPI:CloseMCMWindow()
    else
        if self.Window then
            self.Window.Open = false
        end
    end
    if self.SceneControl and self.SceneControl.ActiveSceneControls then
        for _,sceneControl in pairs(self.SceneControl.ActiveSceneControls) do
            sceneControl.TempClosed = true
            sceneControl.Window.Open = false
        end
    end
end
function UI:ShowWindows()
    if MCMActive then
        Mods.BG3MCM.IMGUIAPI:OpenMCMWindow()
    else
        if self.Window then
            self.Window.Open = true
        end
        for _,sceneControl in pairs(self.SceneControl.ActiveSceneControls) do
            if sceneControl.TempClosed == true then
                sceneControl.Window.Open = true
                sceneControl.TempClosed = false
            end
        end
    end
end

function UI.DestroyChildren(obj)
    if obj == nil then
        return
    end
    if obj.Children and #obj.Children > 0 then
        for _,child in pairs(obj.Children) do
            child:Destroy()
        end
    end
end

-- function UI:DestroyAllSceneControls(backToServer)
--     _P("Destroying all Scene Controls")
--     local sc = self.SceneControl
--     if sc then
--         _P("SceneControl Component found")
--         _D(sc.ActiveSceneControls)
--         if sc.ActiveSceneControls and #sc.ActiveSceneControls > 0 then
--             for _,sceneControl in pairs(sc.ActiveSceneControls) do
--                 _P("Destroying Scene Control")
--                 sceneControl:Destroy(backToServer)
--             end
--         end
--     end
-- end
-- Event.DestroyAllSceneControls:SetHandler(function ()
--     UI:DestroyAllSceneControls(false)
-- end)


function UI.FetchScenes()
    Event.FetchScenes:SendToServer("")
end

function UI.GetAnimations()
    Event.FetchAllAnimations:SendToServer({ID = USERID})
end

function UI:GetSelectedCharacter()
    -- Debug.Print("Selected Characer Is:")
    -- _D(self.PartyInterface.SelectedCharacter)


    -- local iteration = 0
    -- local function uiStateCheck(fn)
    --     iteration = iteration + 1
    --     -- _P("UIStateCheck: Checking UI state: Iteration", iteration)
    --     if iteration > 999 then
    --         -- _P("UIStateCheck: Max iterations reached, stopping check")
    --         iteration = 0
    --         return
    --     end
    --     if UI and UI.PartyInterface and UI.PartyInterface.SelectedCharacter then
    --         -- _P("UIStateCheck: Condition met, executing function")
    --         iteration =  0
    --         -- Ext.Timer.WaitFor(200, function ()
    --             return fn()
    --         -- end)
    --     else
    --         -- _P("UIStateCheck: Condition not met, executing function")
    --         Ext.Timer.WaitFor(200, function ()
    --             uiStateCheck(fn)
    --         end)
    --     end
    -- end

    -- uiStateCheck(
    --     function ()
    --         if UI then
                return self.PartyInterface.SelectedCharacter.Uuid or _C().Uuid.EntityUuid
    --         else
    --             -- print("ERROR: UIINSTANCE DOESNT EXIST")
    --         end
    --     end
    -- )

    -- return self.PartyInterface.SelectedCharacter.Uuid or _C().Uuid.EntityUuid
end

---------------------------------------------------------------------------------------------------
--                                       Load MCM Tab
---------------------------------------------------------------------------------------------------

if MCMActive then
    Mods.BG3MCM.IMGUIAPI:InsertModMenuTab(ModuleUUID, "BG3SX", function(mcm)
        UI:New(mcm):Init()
        _P("-------------------------------------- [BG3SX] MCM Tab Loaded --------------------------------------")
    end)
else
    UI:New():Init()
    _P("-------------------------- [BG3SX] No MCM Loaded - Standalone Window Created -----------------------")
end

return UI