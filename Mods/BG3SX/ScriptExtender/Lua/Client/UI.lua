USERID = nil
UI = {}
UI.__index = UI
UIInstance = nil
ViewPort = Ext.IMGUI.GetViewportSize()
ViewPortScale = Ext.Require("Client/IMGUI.lua").ScaleFactor()

---------------------------------------------------------------------------------------------------
--                                       Load MCM Tab
---------------------------------------------------------------------------------------------------

Mods.BG3MCM.IMGUIAPI:InsertModMenuTab(ModuleUUID, "BG3SX", function(mcm)
    UI.New(mcm)
end)

--------------------------------------------------
--------------------------------------------------

function UI.New(mcm)
    local window
    local mcm = mcm or nil
    if mcm then
        MCMActive = true
        window = mcm:AddChildWindow("")
    else
        window = Ext.IMGUI.NewWindow("BG3SX")
        window:SetSize({500*ViewPortScale, 500*ViewPortScale}, "FirstUseEver")
    end

    --local u = _C().UserReservedFor.UserID
    --local id = Helper.UserToPeerID(u)
    local instance = setmetatable({
        ID = id,
        Window = window,
        Settings = {},
        HotKeys = {},
    }, UI)
    USERID = _C().Uuid.EntityUuid
    UIInstance = instance
    instance:Initialize()
    return instance
end 


function UI:Initialize()
    -- local idtestbutton = self.Window:AddButton("ID Test 5")
    -- idtestbutton.OnClick = function()
    --     _P(USERID)
    -- end
    self.PartyInterface = self:NewPartyInterface()
    self.PartyInterface:Initialize()
    -- PartyTable on top of Tabs so we can make everything Character specific depending on which one is selected
    
    self.TabBar = self.Window:AddTabBar("")
    self.SceneTab = self:NewSceneTab()
    self.AppearanceTab = self:NewAppearanceTab()
    self.WhitelistTab = self:NewWhitelistTab()
    self.WhitelistTab.Visible = false
    self.NPCTab = self:NewNPCTab()
    self.SettingsTab = self:NewSettingsTab()
    --self.DebugTab = self:NewDebugTab()

    self.SceneTab:Initialize()
    self.AppearanceTab:Initialize()
    self.WhitelistTab:Initialize()
    self.NPCTab:Initialize()
    self.SettingsTab:Initialize()
    print("calling restore NPCs")
    Event.FinishedBuildingNPCUI:SendToServer({ID=USERID})  -- Restores stored NPCs from last session

    -- self.SettingsTab:Initialize()
    -- self.DebugTab:Initialize()
end

function UI:AwaitInput(reason, payload)

    local payload = payload or nil
    if self.MouseInputHandler or self.ControllerInputHandler then
        self:CancelAwaitInput() -- Sanity Check Reset
    end
    self.Await = {Reason = reason, Payload = payload}
    self.KeyInputHandler, self.MouseInputHandler, self.ControllerInputHandler, self.ControllerAxisHandler = self:CreateEventHandler()
end

-- Maybe move into its own class
function UI:CreateEventHandler()
    if not self.Await then -- Sanity Check
        return nil,nil,nil
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
        end
    end)

    ---------------------------------------------------------
    --- MOUSE Buttons
    ---------------------------------------------------------

    local mouseHandler = Ext.Events.MouseButtonInput:Subscribe(function (e)
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
                        Debug.Print("------------------------New BG3SX Scene------------------------")
                        mouseoverTarget = getUUIDFromUserdata(getMouseover()) or getMouseover().UIEntity.Uuid.EntityUuid or self.PartyInteface.GetHovered().Uuid
                        if reason == "NewScene" then
                            self:InputRecieved(mouseoverTarget)
                        end
                    else
                        -- No Character Found
                        self:CancelAwaitInput("No entity found")
                    end
                end
            end
        elseif e.Button == 3 and e.Pressed == true then -- Button 3 is right click | 2 is middle mouse click
            -- _D(getMouseover())
            self:CancelAwaitInput("Canceled") -- Cancel
        end
    end)

    ---------------------------------------------------------
    --- CONTROLLER Buttons
    ---------------------------------------------------------
    
    local controllerHandler = Ext.Events.ControllerButtonInput:Subscribe(function (e)
        local enteredTargeting
        local collapsed
        if not e.Button == "LeftStick" then -- Only allow "LeftStick" click to enable targeting  - TODO check PS5 Controller
            e:PreventAction()
        end

        if e.Button == "LeftStick" and e.Pressed == true then
            enteredTargeting = true
            self:HideWindows()
        elseif e.Button == "A" and e.Pressed == true then -- Only check this if
            if getMouseover() and getMouseover().UIEntity then -- In case a UI entity has been found
                mouseoverTarget = getUUIDFromUserdata(getMouseover()) or getMouseover().UIEntity.Uuid.EntityUuid or self.PartyInteface.GetHovered().Uuid
                if reason == "NewScene" then
                    self:InputRecieved(mouseoverTarget)
                end
            end
        end
        
        if enteredTargeting then
            if e.Button == "A" and e.Pressed == true then
                if getMouseover() and getMouseover().Inner then
                    mouseoverPosition = getMouseover().Inner.Position
                    if reason == "MoveScene" then
                        self:InputRecieved(mouseoverPosition)
                        self:CancelAwaitInput()
                    elseif reason == "RotateScene" then
                        self:InputRecieved(mouseoverPosition)
                        self:CancelAwaitInput()
                    end
                    if getMouseover().Inner.Inner[1] then
                        if getMouseover().Inner.Inner[1].Character then
                            mouseoverTarget = getUUIDFromUserdata(getMouseover()) or getMouseover().UIEntity.Uuid.EntityUuid or self.PartyInteface.GetHovered().Uuid
                            if reason == "NewScene" then
                                self:InputRecieved(mouseoverTarget)
                            end
                        else
                            self:CancelAwaitInput("No entity found")
                            self:ShowWindows()
                        end
                    end
                end
            end
        elseif e.Button == "B" and e.Pressed == true then -- Cancel out of targeting
            self:CancelAwaitInput("Canceled")
            self:ShowWindows() -- In case it was set to collapse
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

function UI:CancelAwaitInput(reason)
    local reason = reason or nil
    if reason then
        local info = self.SceneTab.InfoText
        info.Label = reason
        info.Visible = true
        Ext.Timer.WaitFor(3000, function()
            info.Visible = false
        end)
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
        Ext.Events.ControllerButtonInput:Unsubscribe(self.ControllerAxisHandler)
        self.ControllerAxisHandler = nil
    end
    self.Await = nil
end

function UI:InputRecieved(inputPayload)
    local reason = self.Await.Reason
    if reason == "NewScene" then
        _P("Ask for sex request. Caster: ", _C().Uuid.EntityUuid, " target = ", inputPayload)
        Event.AskForSex:SendToServer({ID = USERID, Caster = UIInstance.GetSelectedCharacter(), Target = inputPayload})
    elseif reason == "RotateScene" then
        Event.RotateScene:SendToServer({ID = USERID, Scene = self.Await.Payload, Position = inputPayload})
    elseif reason == "MoveScene" then
        Event.MoveScene:SendToServer({ID = USERID, Scene = self.Await.Payload, Position = inputPayload})
    end
    self:CancelAwaitInput()
end

function UI:HideWindows()
    if MCMActive then
        Mods.MCM.IMGUIAPI:CloseMCMWindow()
    else
        if self.Window then
            self.Window.Open = false
        end
        for _,sceneControl in pairs(self.SceneTab.ActiveSceneControls) do
            sceneControl.TempClosed = true
            sceneControl.Window.Open = false
        end
    end
end
function UI:ShowWindows()
    if MCMActive then
        Mods.MCM.IMGUIAPI:OpenMCMWindow()
    else
        if self.Window then
            self.Window.Open = true
        end
        for _,sceneControl in pairs(self.SceneTab.ActiveSceneControls) do
            if sceneControl.TempClosed == true then
                sceneControl.Window.Open = true
                sceneControl.TempClosed = false
            end
        end
    end
end

function UI.DestroyChildren(obj)
    if obj.Children and #obj.Children > 0 then
        for _,child in pairs(obj.Children) do
            child:Destroy()
        end
    end
end

function UI.GetAnimations()
    Event.FetchAllAnimations:SendToServer({ID = USERID})
end

--function UI.GetUIByID(id)
--    for _,UI in pairs(UIInstances) do
--        if UI.ID == id then
--            return UI
--        end
--    end
--end