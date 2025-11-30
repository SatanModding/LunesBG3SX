--------------------------------------------------------------------------------

-- UI Event Handling

--------------------------------------------------------------------------------

Event.InitUIAfterReset:SetHandler(function()
    if MCMActive then
        Mods.BG3MCM.IMGUIAPI:InsertModMenuTab(ModuleUUID, "BG3SX", function(mcm)
            UI:New(mcm):Init()
            _P("-------------------------------------- [BG3SX] MCM Tab Loaded --------------------------------------")
        end)
    else
        UI:New():Init()
        _P("-------------------------- [BG3SX] No MCM Loaded - Standalone Window Created -----------------------")
    end
end)

-- Updates the USERID based on which character is currently selected per client
Event.ChangeCharacter:SetHandler(function (changedControlledEntity)
    local function condition()
        return UI and UI.Ready == true and UI.PartyInterface.SelectedCharacter ~= nil
    end

    local function changeCharacter()
        local entity = Helper.GetLocalControlledEntity()
        if entity then
            local entityUuid = entity.Uuid.EntityUuid

            if Helper.StringContainsOne(entityUuid, changedControlledEntity) or (changedControlledEntity == "") then
                USERID = entityUuid
                UI.PartyInterface:SetSelectedCharacter(entityUuid)
                UI.AppearanceTab:FetchGenitals()
            else
                Debug.Print("No entity")
            end
        else
            Debug.Print("No entity")
        end
    end

    -- CharacterChanged event needs to delay what it wants to execute because Osiris is slow AF - ClientEntity ID's don't update quickly enough after its triggered
    Helper.DelayUntilTrue(changeCharacter, condition, 200)
end)


Event.UIInitialized:SetHandler(function (payload)
    local something = nil -- This Event can be used by other modders
end)

Event.GenitalsLoaded:SetHandler(function (payload)
    -- Debug.Print("GenitalsLoaded recieved on client, sending FetchGenitals event with currently selected Client character" .. _C().Uuid.EntityUuid)
    -- _D(_C().Uuid.EntityUuid)
    -- Event.FetchGenitals:SendToServer({ID = USERID, Character = _C().Uuid.EntityUuid})
end)

Event.SendParty:SetHandler(function (payload)
    local function optionalDelay()
        local party = payload
        UI.PartyInterface.Party = party
        UI.PartyInterface:UpdateParty()
        -- UI.AppearanceTab:UpdateReplicationListener()
    end
    if not UI.PartyInterface then
        Ext.Timer.WaitFor(200, function ()
            optionalDelay()
        end)
    else
        optionalDelay()
    end
end)

Event.SendWhitelistStatus:SetHandler(function (payload)
    local status = payload.Status
    -- _P("Whitelist status: " .. tostring(status))
    if status == true then
        UI.SceneTab:EnableSceneButtons()
    else
        UI.SceneTab:DisableSceneButtons()
    end
end)


Event.SendScenes:SetHandler(function (payload)
    -- local scenes = payload
    -- local tab = UI.SceneTab
    -- if tab.AwaitingScenes == true then
        -- tab.Scenes = scenes
        -- if tab.Scenes and #tab.Scenes > 0 then
        --     for _,Scene in pairs(tab.Scenes) do
        --         if not Scene.SceneControl then
        --             tab.SceneControl:New(UI.ID, Scene, tab.Tab)
        --         end
        --     end
        -- end
        -- UI.SceneTab.AwaitingScenes = false
    -- end

end)
Event.NewScene:SetHandler(function (payload)
    local scene = payload
    UI.SceneControl:CreateInstance(scene)
    UI.SceneTab.NoSceneText.Visible = false
end)

Event.SendGenitals:SetHandler(function (payload)
    --Debug.Print("SendGenitals recieved on client, updating Genital tab for")

    if UI then
        local genitals = payload.Data
        local whitelisted = payload.Whitelisted

        -- Ext.Timer.WaitFor(2000, function()

        local tab = UI.AppearanceTab
        tab.Genitals = genitals

        tab:UpdateGenitalGroup(whitelisted)
    end
end)

Event.SendIgnoredTags:SetHandler(function(payload)
    if UI.WhitelistTab and UI.WhitelistTab.IgnoredTags then
        UI.WhitelistTab.IgnoredTags = payload
    end
end)
Event.SendUserTags:SetHandler(function (payload)
    if UI.WhitelistTab and UI.WhitelistTab.UserTags then
        UI.WhitelistTab.UserTags.Tags = payload
        UI.WhitelistTab:UpdateUserTags(payload)
    end
end)
Event.SendWhitelist:SetHandler(function (payload)
    if UI.WhitelistTab and UI.WhitelistTab.Whitelists then
        UI.WhitelistTab.Whitelists = payload
        UI.WhitelistTab:GenerateWhitelistArea()
        --_D(UI.WhitelistTab.UserTags.Tags)
        UI.WhitelistTab:UpdateUserTags(UI.WhitelistTab.UserTags.Tags)
    end
end)

---------------------------------------------------------------------
--- Animations
---------------------------------------------------------------------

Event.SendFilteredAnimations:SetHandler(function (payload)
    local animations = payload.Data
    local scene = payload.Scene or nil
    local sceneTab = UI.SceneTab
    if scene then
        local sceneControl = sceneTab:FindSceneControlByEntity(scene.entities[1])
        if sceneControl then
            sceneTab:RefreshAvailableAnimations(animations, scene)
            sceneControl:UpdateAnimationPicker()
        end
    elseif sceneTab then
        sceneTab:RefreshAvailableAnimations(animations)
        for _,sceneControl in pairs(SceneControl.ActiveSceneControls) do
            sceneControl:UpdateAnimationPicker()
        end
    end
end)
Event.SendAllAnimations:SetHandler(function (payload)
    --Debug.Print("---------------CLAPPI--------------------")
    --Debug.Dump(payload)
    local animData = payload.Animations
    local sceneID = payload.SceneControl

    --Debug.Print("SendAllAnimations")
    --_P(Table.TableSize(animData))

    if UI and UI.SceneControl and UI.SceneControl.ActiveSceneControls then
        for _,sceneControl in pairs(UI.SceneControl.ActiveSceneControls) do
            if sceneControl.ID == sceneID then
                -- Debug.Print("FOUND SCENECONTROL")
                sceneControl:UpdateAnimationData(animData)
                break
            end
        end
    end
end)

Event.UpdateSceneControlPicker:SetHandler(function (payload)
    local sceneControl = UI.SceneControl:FindInstanceByEntity(payload.Character)
    sceneControl.Scene.SceneType = payload.SceneType
    if sceneControl then
        -- print("sceneControl exists- updating")
        sceneControl:UpdateAnimationPicker()
    else
        -- print("SceneControl doesnt exist")
    end
end)

Event.SceneControlInstanceDestroyed:SetHandler(function (payload)
    for _,entity in pairs(payload) do
        local sceneControl = UI.SceneControl:FindInstanceByEntity(entity)
        if sceneControl then
            sceneControl:Destroy()
        end
    end
end)


-- Here is the code it is supposed to execute
-- Hello Skiz. Please add a toggleable button in Settings for "BG3SX_ShowAllAnimations" 

-- function Event:somethingsomethingBG3SX_ShowAllAnimations()

-- -- Please initialize the value of that button according to the ModVars

--     local vars = Ext.Vars.GetModVariables(ModuleUUID)
--     local BG3SX_ShowAllAnimations = vars.BG3SX_ShowAllAnimations

--     if BG3SX_ShowAllAnimations == "true" then
--         -- initialize button to activated
--     else
--         -- initialize button to not activates
--     end

-- -- Then please listen to the user who clicks on the button
-- -- and change the variable accordingly    

-- -- If Button true then:
--     -- vars.BG3SX_ShowAllAnimations = "true"

-- -- If Button false then:
--     -- vars.BG3SX_ShowAllAnimations = "false"


-- -- ModVars are not writeable on client, so send an event over to 
-- -- server.

-- -- I initialize and set the default on server, as it is not writable on client
-- -- so let me know if this causes issues


-- end



-- I also need my genital tab back.  See "GenitalMessages.lua" for events to  throw