----------------------------------------------------------------------------------------------
--------------- New v22 Events
UIEvents.FetchScenes:SetHandler(function (payload)
    if Data.SavedScenes and #Data.SavedScenes > 0 then
        _P("SavedScenes exists")
        UIEvents.SendScenes:SendToClient(Data.SavedScenes, payload.ID)
    else
        _P("SavedScenes doesn't exist")
        UIEvents.SendScenes:Broadcast("Empty")
    end
end)
UIEvents.AskForSex:SetHandler(function (payload)
    -- Debug.Print("ASK FOR SEX RECEIVED")
    -- Debug.Dump(payload)
    local caster = payload.Caster
    local target = payload.Target
    --Debug.Print("CASTER ".. caster)
    --Debug.Print("TARGET ".. target)

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
    Osi.PlayAnimation(caster, animation)
end)
UIEvents.ChangePosition:SetHandler(function (payload)
    local scene = Scene:FindSceneByEntity(payload.Caster)
    local position = payload.Position
end)
UIEvents.ChangeCameraHeight:SetHandler(function (payload)
    Debug.Print("Currently not Implemented - Needs access to Camera Control")
end)
UIEvents.MoveScene:SetHandler(function (payload)
    local scene = Scene:FindSceneByEntity(payload.Scene)
    local position = payload.Position -- vec3 WorldPosition table {x,y,z}

    for _, character in pairs(scene.entities) do
        UIEvents.RequestTeleport:Broadcast({character= character, target = position})
    end
end)

        
UIEvents.StopSex:SetHandler(function (payload)
    print("stop sex event received")
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

UIEvents.CustomEvent:SetHandler(function (payload)
    CreateAnimationFilter()
end)

Ext.Osiris.RegisterListener("GainedControl", 1, "after", function(target)  
    UIEvents.ChangeCharacter:Broadcast(target)
end)
