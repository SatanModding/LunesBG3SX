--------------------------------------------------------------------------------

-- UI Event Handling

--------------------------------------------------------------------------------


-- Updates the USERID based on which character is currently selected per client
Event.ChangeCharacter:SetHandler(function (changedControlledEntity)
    Debug.Print("Changed character to " .. changedControlledEntity)
    Ext.Timer.WaitFor(200, function () -- CharacterChanged event needs to delay what it wants to execute because Osiris is slow AF - ClientEntity ID's don't update quickly enough after its triggered
        local entity = Helper.GetLocalControlledEntity()
        local entityUuid = entity.Uuid.EntityUuid

        if Helper.StringContainsOne(entityUuid, changedControlledEntity) or (changedControlledEntity == "") then
            USERID = entityUuid
            -- swap the character in the UI
            UIInstance.PartyInterface:SetSelectedCharacter(entityUuid)
            UIInstance.AppearanceTab:FetchGenitals()
        else
            Debug.Print("No entity")
        end
    end)
end)

Event.GenitalsLoaded:SetHandler(function (payload)
    -- Debug.Print("GenitalsLoaded recieved on client, sending FetchGenitals event with currently selected Client character" .. _C().Uuid.EntityUuid)
    -- _D(_C().Uuid.EntityUuid)
    -- Event.FetchGenitals:SendToServer({ID = USERID, Character = _C().Uuid.EntityUuid})
end)

Event.SendParty:SetHandler(function (payload)    
    local party = payload
    UIInstance.PartyInterface.Party = party
    UIInstance.PartyInterface:UpdateParty()
end)


Event.SendScenes:SetHandler(function (payload)
    -- local scenes = payload
    -- local tab = UIInstance.SceneTab
    -- if tab.AwaitingScenes == true then
        -- tab.Scenes = scenes
        -- if tab.Scenes and #tab.Scenes > 0 then
        --     for _,Scene in pairs(tab.Scenes) do
        --         if not Scene.SceneControl then
        --             tab.SceneControl:New(UIInstance.ID, Scene, tab.Tab)
        --         end
        --     end
        -- end
        -- UIInstance.SceneTab.AwaitingScenes = false
    -- end

end)
Event.NewScene:SetHandler(function (payload)
    local scene = payload
    UIInstance.SceneTab:NewSceneControl(scene)
    UIInstance.SceneTab.NoSceneText.Visible = false
end)

Event.SendGenitals:SetHandler(function (payload)
    --Debug.Print("SendGenitals recieved on client, updating Genital tab for")

    if UIInstance then
        local genitals = payload.Data
        local whitelisted = payload.Whitelisted

        -- Ext.Timer.WaitFor(2000, function()

        local tab = UIInstance.AppearanceTab
        tab.Genitals = genitals

        tab:UpdateGenitalGroup(whitelisted)
    end
end)

Event.SendUserTags:SetHandler(function (payload)
    --_P("1")
    --_D(payload)
    UIInstance.WhitelistTab.UserTags.Tags = payload
    UIInstance.WhitelistTab:UpdateUserTags(payload)
end)
Event.SendWhitelist:SetHandler(function (payload)
    UIInstance.WhitelistTab.Whitelists = payload
    UIInstance.WhitelistTab:GenerateWhitelistArea()
    --_D(UIInstance.WhitelistTab.UserTags.Tags)
    UIInstance.WhitelistTab:UpdateUserTags(UIInstance.WhitelistTab.UserTags.Tags)
end)

---------------------------------------------------------------------
--- Animations
---------------------------------------------------------------------

Event.SendFilteredAnimations:SetHandler(function (payload)
    local animations = payload.Data
    local scene = payload.Scene or nil
    local sceneTab = UIInstance.SceneTab
    if scene then
        local sceneControl = sceneTab:FindSceneControlByEntity(scene.entities[1])
        if sceneControl then
            sceneTab:RefreshAvailableAnimations(animations, scene)
            sceneControl:UpdateAnimationPicker()
        end
    elseif sceneTab then
        sceneTab:RefreshAvailableAnimations(animations)
        for _,sceneControl in pairs(sceneTab.ActiveSceneControls) do
            sceneControl:UpdateAnimationPicker()
        end
    end
end)
Event.SendAllAnimations:SetHandler(function (payload)
    --Debug.Print("---------------CLAPPI--------------------")
    --Debug.Dump(payload)
    local animData = payload.Animations
    local sceneID = payload.SceneControl
    local sceneTab = UIInstance.SceneTab
    --Debug.Print("SendAllAnimations")
    --_P(Table.TableSize(animData))
    for _,sceneControl in pairs(sceneTab.ActiveSceneControls) do
        if sceneControl.ID == sceneID then
            -- Debug.Print("FOUND SCENECONTROL")
            sceneControl:UpdateAnimationData(animData)
        end
    end
end)
Event.UpdateSceneControlPicker:SetHandler(function (payload)
    local sceneControl = UIInstance.SceneTab:FindSceneControlByEntity(payload.Character)
    sceneControl.Scene.SceneType = payload.SceneType
    if sceneControl then
        print("sceneControl exists- updating")
        sceneControl:UpdateAnimationPicker()
    else
        print("SceneControl doesnt exist")
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