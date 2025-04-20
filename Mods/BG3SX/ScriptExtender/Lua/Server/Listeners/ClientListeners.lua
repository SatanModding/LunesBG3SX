----------------------------------------------------------------------------------------------
--------------- New v22 Events
Event.FetchScenes:SetHandler(function (payload)
    if Data.SavedScenes and #Data.SavedScenes > 0 then
        _P("SavedScenes exists")
        Event.SendScenes:SendToClient(Data.SavedScenes, payload.ID)
        Event.UpdateScenes:Broadcast(Data.SavedScenes)
    else
        Event.SendScenes:SendToClient("Empty", payload.ID)
    end
end)

Event.RequestSyncActiveScenes:SetHandler(function ()
    Event.SyncActiveScenes:Broadcast(Data.SavedScenes)
end)


Event.AskForSex:SetHandler(function (payload)
    -- Debug.Print("ASK FOR SEX RECEIVED")
    -- Debug.Dump(payload)
    local caster = payload.Caster
    local target = payload.Target
    --Debug.Print("CASTER ".. caster)
    --Debug.Print("TARGET ".. target)

    local allow = true
    for _,scene in pairs(Data.SavedScenes) do
        for _,involved in pairs(scene.entities) do
            if (caster == involved) or (target == involved) then
                allow = false
                Debug.Print("Requestee or target already in a scene")
                -- TODO: Show this in UI as well
            end
        end
    end

    if allow then
        -- masturbation 
       

        if (Helper.StringContains(target,caster)) or (Helper.StringContains(caster, target)) then
            if Entity:IsWhitelisted(caster, true) then
                Entity:ClearActionQueue(caster)
                Ext.Timer.WaitFor(200, function() -- Wait for erections
                    Sex:StartSexSpellUsed(caster, {target}, Data.IntroAnimations[ModuleUUID]["Start Masturbating"])
                end)
                Ext.ModEvents.BG3SX.StartSexSpellUsed:Throw({caster = caster, target = target, animData = Data.IntroAnimations[ModuleUUID]["Start Masturbating"]})
            end

        -- sex
        else
            if Entity:IsWhitelisted(caster, true) and Entity:IsWhitelisted(target, true) then
                Entity:ClearActionQueue(caster)
                Entity:ClearActionQueue(target)
                Ext.Timer.WaitFor(200, function() -- Wait for erections
                    Sex:StartSexSpellUsed(caster, {target}, Data.IntroAnimations[ModuleUUID]["Ask for Sex"])
                end)
                Ext.ModEvents.BG3SX.StartSexSpellUsed:Throw({caster = caster, target = target, animData = Data.IntroAnimations[ModuleUUID]["Ask for Sex"]})
            end
        end
    end

end)


Event.TogglePause:SetHandler(function (payload)
    local scene = Scene:FindSceneByEntity(payload.Scene.entities[1])
    scene:TogglePause()
    -- If we add transitioning animations - our own loop system we need to also pause potential scene timers
end)

Event.SwapPosition:SetHandler(function (payload)
    local scene = Scene:FindSceneByEntity(payload.Scene.entities[1])
    scene:SwapPosition()
end)

Event.ChangeCameraHeight:SetHandler(function (payload)
    Debug.Print("Currently not Implemented - Needs access to Camera Control")
end)
Event.MoveScene:SetHandler(function (payload)
    local scene = Scene:FindSceneByEntity(payload.Scene.entities[1])
    local position = payload.Position -- vec3 WorldPosition table {x,y,z}

    scene:MoveSceneToLocation(position)
end)

        
Event.StopSex:SetHandler(function (payload)
    local scene = Scene:FindSceneByEntity(payload.Scene.entities[1])
    scene:Destroy()
end)
Event.FetchGenitals:SetHandler(function (payload)

    -- Debug.Print("Recevied FetchGenitals for character ".. payload.Character)


    -- local conts = Ext.Entity.GetAllEntitiesWithComponent("ClientControl")
    -- if conts ~= nil then
    --     for k, v in pairs(conts) do
    --         --print("sending payload to ", v.UserReservedFor.UserID)
    --         -- Event.SendGenitals:SendToClient({ID = payload.ID, Data = Data.CreateUIGenitalPayload(payload.Character), Whitelisted = Entity:IsWhitelisted(payload.Character)}, v.UserReservedFor.UserID)
    --     end
    -- end
    Event.SendGenitals:SendToClient({ID = payload.ID, Data = Data.CreateUIGenitalPayload(payload.Character), Whitelisted = Entity:IsWhitelisted(payload.Character)}, payload.ID)
end)
    
    
Event.RotateScene:SetHandler(function (payload)
    local scene = Scene:FindSceneByEntity(payload.Scene.entities[1])
    local position = payload.Position
    scene:RotateScene(position)
end)
   
Event.FetchAnimations:SetHandler(function (payload)
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
    --Event.SendAnimations:SendToClient({ID = payload.ID, Data = availableAnimations}, payload.ID)
end)

-- Event.FetchAllAnimations:SetHandler(function (payload)

--     print("-----------------------------------------------------")
--     print("YAPYAPYAPYAP")
--     print("---------------------------------------")
-- end)



-- Event.FetchAllAnimations:SetHandler(function (payload)
--     local anims = {}
--     for anim,animData in pairs(Data.Animations) do
--         if anim ~= "New" then
--             anims[anim] = animData
--             anims[anim].Heightmatching = anims[anim].Heightmatching.matchingTable
--         end
--     end
--     --Debug.DumpS(anims)
--     Event.SendAllAnimations:Broadcast(anims)
-- end)


Event.FetchAllAnimations:SetHandler(function (payload)
    local animations = Data.Animations
    local client = payload.ID
    Event.SendAllAnimations:SendToClient({Animations = animations, SceneControl = payload.SceneControl}, client)
end)

Event.FetchParty:SetHandler(function (payload)
    local party = Osi.DB_PartyMembers:Get(nil)
    Event.SendParty:SendToClient(party, payload.ID)
end)

Event.FetchWhitelist:SetHandler(function (payload)
    local newPayload = {Whitelist = Data.AllowedTagsAndRaces, ModdedTags = Data.ModdedTags, Whitelisted = Data.WhitelistedEntities, Blacklisted = Data.BlacklistedEntities}
    Event.SendWhitelist:SendToClient(newPayload, payload.ID)
end)




Event.CustomEvent:SetHandler(function (payload)
    CreateAnimationFilter()
end)

Ext.Osiris.RegisterListener("GainedControl", 1, "after", function(target)
    Event.ChangeCharacter:Broadcast(target)
end)


Ext.Osiris.RegisterListener("LevelGameplayStarted", 2, "after", function(_, _)
    Event.ChangeCharacter:Broadcast("")
end)


-- Event.FetchFilteredAnimations:SetHandler(function (payload)
--     Debug.Print("Received message FetchFilteredAnimations with payload")
--     _D(payload)
--     local filter = payload.filter
--     local animations = Animation.GetFilteredAnimations(filter)
--     local client = payload.USERID
--     Event.SendFiltered:SendToClient({Animations = animations, SceneControl = payload.SceneControl}, client)
-- end)



Event.ChangeAnimation:SetHandler(function (payload)
    --print("Received Change Animation event with payload")
    --_D(payload)
    
    local caster = payload.Caster
    local moduleUUID = payload.moduleUUID
    local animationData = payload.AnimationData
    local scene = Scene:FindSceneByEntity(caster)
    -- _D(scene)
    -- _D(animationData)
    scene:PlayAnimation(animationData)
end)



Event.FetchWhitelistedNPCs:SetHandler(function(payload)
    local tbl = payload.tbl
    local filtered = {}

    --_D(tbl)

    for _, character in pairs(tbl) do
        if Entity:IsWhitelisted(character) then
            table.insert(filtered, character)
        end
    end
    Event.SendWhitelistedNPCs:SendToClient(filtered, payload.client) 

end)

Event.FetchUserTags:SetHandler(function(payload)
    local tags = Entity:TryGetEntityValue(payload.Character, nil, {"ServerRaceTag", "Tags"})
    
    -- Can't send array over as event payloads so we add every entry to a table and send that one instead
    local nonArrayTags = {}
    for _,tagUUID in pairs(tags) do
        table.insert(nonArrayTags,tagUUID)
    end
    Event.SendUserTags:SendToClient(nonArrayTags, payload.ID)
end)