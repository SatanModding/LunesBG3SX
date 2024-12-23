--------------------------------------------------------------------------------

-- UI Event Handling

--------------------------------------------------------------------------------


UIEvents.ChangeCharacter:SetHandler(function (payload)

    Ext.Timer.WaitFor(200, function ()
        local entity = Helper.GetLocalControlledEntity()

        print("target of change control: ", payload)
        print("current client host ", entity.Uuid.EntityUuid)

        Debug.Print("ChangeCharacter EventHandler")
        UIInstance.GenitalsTab:FetchGenitals()
            
    end)

end)

UIEvents.SendParty:SetHandler(function (payload)
    local party = payload.Data
    UIInstance.PartyInterface.Party = party
    UIInstance.PartyInterface:UpdateParty()
end)
UIEvents.SendScenes:SetHandler(function (payload)
    local scenes = payload.Data
    local tab = UIInstance.SceneTab
    if tab.AwaitingScenes == true then
        tab.Scenes = scenes
        if tab.Scenes and #tab.Scenes > 0 then
            for _,Scene in pairs(tab.Scenes) do
                if not Scene.SceneControl then
                    tab.SceneControl:New(UIInstance.ID, Scene, tab.Tab)
                end
            end
        end
        UIInstance.SceneTab.AwaitingScenes = false
    end
end)
UIEvents.NewScene:SetHandler(function (payload)
    local scene = payload.Data
    local newSceneControl = UIInstance.SceneTab.NewSceneControl(scene)
    table.insert(UIInstance.SceneTab.Scenes, newSceneControl)
end)

UIEvents.SendGenitals:SetHandler(function (payload)
    local genitals = payload.Data

    print("CLIENT RECEIVED SEND GENITALS")
    print("payload.Data")
    _D(payload)
    local tab = UIInstance.GenitalsTab
    if tab.AwaitingGenitals == true then
        tab.Genitals = genitals
        tab:UpdateGenitalTable()
        tab.AwaitingGenitals = false
    end
end)

UIEvents.SendAnimations:SetHandler(function (payload)
    local animations = payload.Data
    UIInstance.SceneTab:RefreshAvailableAnimations(animations)
end)
function SceneTab:RefreshAvailableAnimations(animationTable)
    for _,SceneControl in pairs(self.ActiveSceneControls) do
        SceneControl.UpdatingAnimationPicker = true
        SceneControl.AnimationPicker.Options = {}
        for i,Animation in ipairs(animationTable) do
            SceneControl.AnimationPicker.Options[i] = Animation
        end
        SceneControl.UpdatingAnimationPicker = false
    end
end




-- Here is the code it is supposed to execute
-- Hello Skiz. Please add a toggleable button in Settings for "ShowAllAnimations" 

function UIEvents:somethingsomethingShowAllAnimations()

-- Please initialize the value of that button according to the ModVars

    local vars = Ext.Vars.GetModVariables(ModuleUUID)
    local showAllAnimations = vars.ShowAllAnimations

    if showAllAnimations == "true" then
        -- initialize button to activated
    else
        -- initialize button to not activates
    end

-- Then please listen to the user who clicks on the button
-- and change the variable accordingly    

-- If Button true then:
    -- vars.ShowAllAnimations = "true"

-- If Button false then:
    -- vars.ShowAllAnimations = "false"


-- ModVars are not writeable on client, so send an event over to 
-- server.

-- I initialize and set the default on server, as it is not writable on client
-- so let me know if this causes issues


end



-- I also need my genital tab back.  See "GenitalMessages.lua" for events to  throw