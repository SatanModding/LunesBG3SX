----------------------------------------------------------------------------------------------
--------------- New v22 Events
UIEvents.FetchScenes:SetHandler(function (payload)
    if Data.SavedScenes and #Data.SavedScenes > 0 then
        _P("SavedScenes exists")
        UIEvents.SendScenes:SendToClient(Data.SavedScenes, payload.ID)
        UIEvents.UpdateScenes:Broadcast(Data.SavedScenes)
    else
        UIEvents.SendScenes:SendToClient("Empty", payload.ID)
    end
end)
UIEvents.AskForSex:SetHandler(function (payload)
    -- Debug.Print("ASK FOR SEX RECEIVED")
    -- Debug.Dump(payload)
    local caster = payload.Caster
    local target = payload.Target
    --Debug.Print("CASTER ".. caster)
    --Debug.Print("TARGET ".. target)

    
    -- TODO - don't allow scenes to start when one entity is already in a scene
    
    -- masturbation 
    if target == caster then
        if Entity:IsWhitelisted(caster, true) then
            Ext.Timer.WaitFor(200, function() -- Wait for erections
                Sex:StartSexSpellUsed(caster, {target}, Data.StartSexSpells["BG3SX_StartMasturbating"])
            end)
            Ext.ModEvents.BG3SX.StartSexSpellUsed:Throw({caster = caster, target = target, animData = Data.StartSexSpells["BG3SX_StartMasturbating"]})
        end
        

    -- sex
    else
        if Entity:IsWhitelisted(caster, true) and Entity:IsWhitelisted(target, true) then
            Ext.Timer.WaitFor(200, function() -- Wait for erections
                Sex:StartSexSpellUsed(caster, {target}, Data.StartSexSpells["BG3SX_AskForSex"])
            end)

            Ext.ModEvents.BG3SX.StartSexSpellUsed:Throw({caster = caster, target = target, animData = Data.StartSexSpells["BG3SX_AskForSex"]})
        end
    end
end)



UIEvents.ChangeAnimation:SetHandler(function (payload)
    Debug.Dump(payload)
    local caster = payload.Caster
    local animation = payload.Animation
    if animation.NextAnimation then
        
    end
    Osi.PlayAnimation(caster, animation)
end)
UIEvents.SwapPosition:SetHandler(function (payload)
    local scene = Scene:FindSceneByEntity(payload.Scene.entities[1])
    scene:SwapPosition()
end)

UIEvents.ChangeCameraHeight:SetHandler(function (payload)
    Debug.Print("Currently not Implemented - Needs access to Camera Control")
end)
UIEvents.MoveScene:SetHandler(function (payload)
    local scene = Scene:FindSceneByEntity(payload.Scene.entities[1])
    local position = payload.Position -- vec3 WorldPosition table {x,y,z}

    scene:MoveSceneToLocation(position)
end)

        
UIEvents.StopSex:SetHandler(function (payload)
    local scene = Scene:FindSceneByEntity(payload.Scene.entities[1])
    scene:Destroy()
end)
UIEvents.FetchGenitals:SetHandler(function (payload)

    local conts = Ext.Entity.GetAllEntitiesWithComponent("ClientControl")
    if conts ~= nil then
        for k, v in pairs(conts) do
            --print("sending payload to ", v.UserReservedFor.UserID)
            UIEvents.SendGenitals:SendToClient({ID = payload.ID, Data = Data.CreateUIGenitalPayload(payload.Character)}, v.UserReservedFor.UserID)
        end
    end
end)
    
    
UIEvents.RotateScene:SetHandler(function (payload)
    local scene = Scene:FindSceneByEntity(payload.Scene.entities[1])
    local position = payload.Position
    scene:RotateScene(position)
end)
   
UIEvents.FetchAnimations:SetHandler(function (payload)
    local sceneType = Scene:FindSceneByEntity(payload.Caster)
    local container = nil
    for _,type in pairs(Data.SceneTypes) do
        if type.sceneType == sceneType then
            container = type.container
        end
    end
    local containerSpell = Ext.StaticData.Get(container)
    local spells = containerSpell.ContainerSpells
    local availableAnimations
    for _,spell in pairs(spells) do
        if Data.Animation[spell] then
            table.insert(availableAnimations, Data.Animation[spell])
        end
    end
    --UIEvents.SendAnimations:SendToClient({ID = payload.ID, Data = availableAnimations}, payload.ID)
end)
UIEvents.FetchAllAnimations:SetHandler(function (payload)
    local anims = {}
    for anim,animData in pairs(Data.Animations) do
        if anim ~= "New" then
            anims[anim] = animData
            anims[anim].Heightmatching = anims[anim].Heightmatching.matchingTable
        end
    end
    --Debug.DumpS(anims)
    UIEvents.SendAllAnimations:Broadcast(anims)
end)


UIEvents.FetchParty:SetHandler(function (payload)
    local party = Osi.DB_PartyMembers:Get(nil)
    UIEvents.SendParty:SendToClient(party, payload)
end)

UIEvents.FetchWhitelist:SetHandler(function (payload)
    local newPayload = {Whitelist = Data.AllowedTagsAndRaces, ModdedTags = Data.ModdedTags, Whitelisted = Data.WhitelistedEntities, Blacklisted = Data.BlacklistedEntities}
    UIEvents.SendWhitelist:SendToClient(newPayload, payload.ID)
end)




UIEvents.CustomEvent:SetHandler(function (payload)
    CreateAnimationFilter()
end)

Ext.Osiris.RegisterListener("GainedControl", 1, "after", function(target)  
    UIEvents.ChangeCharacter:Broadcast(target)
end)
