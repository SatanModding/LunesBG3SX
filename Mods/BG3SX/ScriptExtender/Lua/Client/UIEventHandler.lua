--------------------------------------------------------------------------------

-- UI Event Handling

--------------------------------------------------------------------------------


UIEvents.ChangeCharacter:SetHandler(function (payload)

    Ext.Timer.WaitFor(200, function ()
        local entity = Helper.GetLocalControlledEntity()
        if entity then
            print("target of change control: ", payload)
            print("current client host ", entity.Uuid.EntityUuid)

            Debug.Print("ChangeCharacter EventHandler")
            UIInstance.GenitalsTab:FetchGenitals()
        else
            Debug.Print("No entity")
        end
    end)

end)

UIEvents.SendParty:SetHandler(function (payload)
    print("client received SendParty message for id ", _C().UserReservedFor.UserID)
    
    local party = payload
    UIInstance.PartyInterface.Party = party
    UIInstance.PartyInterface:UpdateParty()
end)


UIEvents.SendScenes:SetHandler(function (payload)
    local scenes = payload
    -- local tab = UIInstance.SceneTab
    -- if tab.AwaitingScenes == true then
    --     tab.Scenes = scenes
    --     if tab.Scenes and #tab.Scenes > 0 then
    --         for _,Scene in pairs(tab.Scenes) do
    --             if not Scene.SceneControl then
    --                 tab.SceneControl:New(UIInstance.ID, Scene, tab.Tab)
    --             end
    --         end
    --     end
    --     UIInstance.SceneTab.AwaitingScenes = false
    -- end

end)
UIEvents.NewScene:SetHandler(function (payload)
    local scene = payload
    UIInstance.SceneTab:NewSceneControl(scene)
    UIInstance.SceneTab.NoSceneText.Visible = false
end)

UIEvents.SendGenitals:SetHandler(function (payload)
    local genitals = payload.Data

    local tab = UIInstance.GenitalsTab
    if tab.AwaitingGenitals == true then
        tab.Genitals = genitals
        tab:UpdateGenitalTable()
        tab.AwaitingGenitals = false
    end
end)

UIEvents.SendUserTags:SetHandler(function (payload)
    _P("1")
    _D(payload)
    UIInstance.WhitelistTab.UserTags.Tags = payload
    UIInstance.WhitelistTab:UpdateUserTags(payload)
end)
UIEvents.SendWhitelist:SetHandler(function (payload)
    UIInstance.WhitelistTab.Whitelists = payload
    UIInstance.WhitelistTab:GenerateWhitelistArea()
    _D(UIInstance.WhitelistTab.UserTags.Tags)
    UIInstance.WhitelistTab:UpdateUserTags(UIInstance.WhitelistTab.UserTags.Tags)
end)

---------------------------------------------------------------------
--- Animations
---------------------------------------------------------------------

UIEvents.SendFilteredAnimations:SetHandler(function (payload)
    local animations = payload.Data
    local sceneTab = UIInstance.SceneTab
    if sceneTab then
        sceneTab:RefreshAvailableAnimations(animations)
        for _,sceneControl in pairs(sceneTab.ActiveSceneControls) do
            sceneControl:AddAnimationPicker()
        end
    end
end)
UIEvents.SendAllAnimations:SetHandler(function (payload)
    Debug.Print("---------------CLAPPI--------------------")
    Debug.DumpS(payload)
    local animData = payload.Animations
    local sceneID = payload.SceneControl
    local sceneTab = UIInstance.SceneTab
    for _,sceneControl in pairs(sceneTab.ActiveSceneControls) do
        if sceneControl.Instance.ID == sceneID then
            Debug.Print("FOUND SCENECONTROL")
            sceneControl.Instance:UpdateAnimationData(animData)
        end
    end
end)



-- Here is the code it is supposed to execute
-- Hello Skiz. Please add a toggleable button in Settings for "BG3SX_ShowAllAnimations" 

function UIEvents:somethingsomethingBG3SX_ShowAllAnimations()

-- Please initialize the value of that button according to the ModVars

    local vars = Ext.Vars.GetModVariables(ModuleUUID)
    local BG3SX_ShowAllAnimations = vars.BG3SX_ShowAllAnimations

    if BG3SX_ShowAllAnimations == "true" then
        -- initialize button to activated
    else
        -- initialize button to not activates
    end

-- Then please listen to the user who clicks on the button
-- and change the variable accordingly    

-- If Button true then:
    -- vars.BG3SX_ShowAllAnimations = "true"

-- If Button false then:
    -- vars.BG3SX_ShowAllAnimations = "false"


-- ModVars are not writeable on client, so send an event over to 
-- server.

-- I initialize and set the default on server, as it is not writable on client
-- so let me know if this causes issues


end



-- I also need my genital tab back.  See "GenitalMessages.lua" for events to  throw