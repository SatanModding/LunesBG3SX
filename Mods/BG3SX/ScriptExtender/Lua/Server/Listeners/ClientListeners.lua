Event.FetchScenes:SetHandler(function (payload)
    if Data.SavedScenes and #Data.SavedScenes > 0 then
        -- _P("SavedScenes exists")
        Event.SendScenes:SendToClient(Data.SavedScenes, payload.ID)
        Event.UpdateScenes:Broadcast(Data.SavedScenes)
    else
        Event.SendScenes:SendToClient("Empty", payload.ID)
    end
end)

Event.RequestSyncActiveScenes:SetHandler(function ()
    Event.SyncActiveScenes:Broadcast(Data.SavedScenes)
end)

Event.NewSceneRequest:SetHandler(function (payload)
    local caster = payload.Caster
    local target = payload.Target
    local type = payload.Type
    local isResponse = payload.IsResponse
    local accepted = payload.Accepted

    if Scene.ExistsInScene(caster) or Scene.ExistsInScene(target) then
        if Scene.ExistsInScene(caster) then
            Debug.Print("Caster already in scene " .. Scene.FindSceneByEntity(caster).Uuid)
        end
        if Scene.ExistsInScene(target) then
            Debug.Print("Target already in scene " .. Scene.FindSceneByEntity(target).Uuid)
        end
        return
    end

    local consentGranted = false

    if not (Entity:IsWhitelisted(caster, true) and Entity:IsWhitelisted(target, true)) then
        return
    end

    -- NPCs are assumed to automatically consent (this is the workaround for now)
    if Entity:IsNPC(target) then
        consentGranted = true
    end

    -- For player response with consent, proceed
    if isResponse and accepted then
        consentGranted = true
    end

    if isResponse and not accepted then
        Debug.Print(string.format("[BG3SX] Consent not given by target %s — aborting scene.", target))
        return
    end

    -- For initial player requests, first ask for consent
    if not consentGranted and not isResponse then
        local entity = Ext.Entity.Get(target)
        local targetClient = nil

        -- Only send consent form if the target is a different player avatar
        if entity
        and entity.UserReservedFor
        and entity.UserReservedFor.UserID
        and entity.CharacterCreationStats  -- only playable characters have this component?
        and not Entity:IsNPC(target)
        and not Helper.StringContainsOne(caster, target)
        then
            local targetUserID = entity.UserReservedFor.UserID
            local casterEntity = Ext.Entity.Get(caster)
            local casterUserID = casterEntity and casterEntity.UserReservedFor and casterEntity.UserReservedFor.UserID or nil

            -- Make sure target and caster are not the same player (prevents self-consent requests for solo scenes)
            if targetUserID and (not casterUserID or targetUserID ~= casterUserID) then
                targetClient = targetUserID
            end
        end

        if targetClient then
            Debug.Print(string.format("[BG3SX] Sending consent request to client %s for target %s", targetClient, target))
            Event.RequestSceneConsent:SendToClient({
                Caster = caster,
                Target = target,
                Type = type
            }, targetClient)

            return
        else
            Debug.Print(string.format("[BG3SX] Skipping consent — target is NPC or self: %s", tostring(target)))
        end
    end

    if type == "SFW" then
        if Helper.StringContainsOne(caster, target) then -- SoloScene
            local scene = Scene:New({Type = "SFW", Entities = {caster}, Animation = Data.IntroAnimations[ModuleUUID]["Start SFW"], Fade = 666})
            scene:Init()
            scene:PlayAnimation(Data.IntroAnimations[ModuleUUID]["Start SFW"])

        else-- PairedScene
            local scene = Scene:New({Type = "SFW", Entities = {caster, target}, Animation = Data.IntroAnimations[ModuleUUID]["Hug or Carry"], Fade = 666})
            scene:Init()
            scene:PlayAnimation(Data.IntroAnimations[ModuleUUID]["Hug or Carry"])
        end

    elseif type == "NSFW" then
        if Helper.StringContainsOne(caster, target) then -- SoloScene
            local scene = Scene:New({Type = "NSFW", Entities = {caster}, Animation = Data.IntroAnimations[ModuleUUID]["Start Masturbating"], Fade = 666})
            scene:Init()
            scene:PlayAnimation(Data.IntroAnimations[ModuleUUID]["Start Masturbating"])

        else -- PairedScene
            local scene = Scene:New({Type = "NSFW", Entities = {caster, target}, Animation = Data.IntroAnimations[ModuleUUID]["Hug or Carry"], Fade = 666})
            scene:Init()
            scene:PlayAnimation(Data.IntroAnimations[ModuleUUID]["Hug or Carry"])
        end
    else
        Debug.Print("Unknown scene type: " .. type)
    end
end)

Event.NewSFWScene:SetHandler(function (payload)
    local caster = payload.Caster
    local target = payload.Target

    if Scene.ExistsInScene(caster) or Scene.ExistsInScene(target) then
        Debug.Print("Caster or target already in a scene")
        return
    end

    -- Add BG3SX AnimationSets
    -- if BG3AFActive then
    --     local function addWaterfallToEntity(entity, tbl)
    --         local animWaterfall = Mods.BG3AF.AnimationWaterfall.Get(entity)
    --         local waterfallEntry = animWaterfall:AddWaterfall(tbl)
    --     end

    --     local tbl = {
    --         Resource = Data.AnimationSets["BG3SX_Body"].Uuid,
    --         DynamicAnimationTag = "9bfa73ed-2573-4f48-adc3-e7e254a3aadb",
    --         Slot = "", -- 0 = Body, 1 = Attachment
    --         OverrideType = 0, -- 0 = Replace, 1 = Additive
    --     }

    --     addWaterfallToEntity(caster, tbl)
    --     if not Helper.StringContainsOne(caster, target) then
    --         addWaterfallToEntity(target, tbl)
    --     end
    -- else
    --     Debug.Print("BG3AF not found")
    -- end

    if Helper.StringContainsOne(caster, target) then -- SoloScene
        if Entity:IsWhitelisted(caster, true) then
            Entity:ClearActionQueue(caster)
            -- Ext.Timer.WaitFor(200, function() -- Wait for erections
                -- Sex:NewSFWScenePreSetup(caster, {target}, Data.IntroAnimations[ModuleUUID]["Start Masturbating"])
            Scene:New({Type = "SFW", Entities = {caster}, Animation = Data.IntroAnimations[ModuleUUID]["Start Masturbating"]}):Init()
            -- end)
            -- Ext.ModEvents.BG3SX.StartSexSpellUsed:Throw({caster = caster, target = target, animData = Data.IntroAnimations[ModuleUUID]["Start Masturbating"]})
        end

    else -- PairedScene
        if Entity:IsWhitelisted(caster, true) and Entity:IsWhitelisted(target, true) then
            Entity:ClearActionQueue(caster)
            Entity:ClearActionQueue(target)
            -- Ext.Timer.WaitFor(200, function() -- Wait for erections
                -- Sex:NewSFWScenePreSetup(caster, {target}, Data.IntroAnimations[ModuleUUID]["Ask for Sex"])
                Scene:New({Type = "SFW", Entities = {caster, target}, Animation = Data.IntroAnimations[ModuleUUID]["Ask for Sex"]}):Init()
            -- end)
            -- Ext.ModEvents.BG3SX.StartSexSpellUsed:Throw({caster = caster, target = target, animData = Data.IntroAnimations[ModuleUUID]["Ask for Sex"]})
        end
    end
end)

Event.NewNSFWScene:SetHandler(function (payload)
    local caster = payload.Caster
    local target = payload.Target
    -- local type = payload.Type

    if Scene.ExistsInScene(caster) or Scene.ExistsInScene(target) then
        Debug.Print("Caster or target already in a scene")
        return
    end

    -- Add BG3SX AnimationSets
    -- if BG3AFActive then
    --     local function addWaterfallToEntity(entity, tbl)
    --         local animWaterfall = Mods.BG3AF.AnimationWaterfall.Get(entity)
    --         local waterfallEntry = animWaterfall:AddWaterfall(tbl)
    --     end

    --     local tbl = {
    --         Resource = Data.AnimationSets["BG3SX_Body"].Uuid,
    --         DynamicAnimationTag = "9bfa73ed-2573-4f48-adc3-e7e254a3aadb",
    --         Slot = "", -- 0 = Body, 1 = Attachment
    --         OverrideType = 0, -- 0 = Replace, 1 = Additive
    --     }

    --     addWaterfallToEntity(caster, tbl)
    --     if not Helper.StringContainsOne(caster, target) then
    --         addWaterfallToEntity(target, tbl)
    --     end
    -- else
    --     Debug.Print("BG3AF not found")
    -- end

    if Helper.StringContainsOne(caster, target) then -- SoloScene
        if Entity:IsWhitelisted(caster, true) then
            Entity:ClearActionQueue(caster)
            -- Ext.Timer.WaitFor(200, function() -- Wait for erections
                -- Sex:StartSexSpellUsed(caster, {target}, Data.IntroAnimations[ModuleUUID]["Start Masturbating"])
                Scene:New({Type = "NSFW", Entities = {caster}, Animation = Data.IntroAnimations[ModuleUUID]["Start Masturbating"]}):Init()
            -- end)
            -- Ext.ModEvents.BG3SX.StartSexSpellUsed:Throw({caster = caster, target = target, animData = Data.IntroAnimations[ModuleUUID]["Start Masturbating"]})
        end

    else -- PairedScene
        if Entity:IsWhitelisted(caster, true) and Entity:IsWhitelisted(target, true) then
            Entity:ClearActionQueue(caster)
            Entity:ClearActionQueue(target)
            -- Ext.Timer.WaitFor(200, function() -- Wait for erections
                -- Sex:StartSexSpellUsed(caster, {target}, Data.IntroAnimations[ModuleUUID]["Ask for Sex"])
                Scene:New({Type = "NSFW", Entities = {caster, target}, Animation = Data.IntroAnimations[ModuleUUID]["Ask for Sex"]}):Init()
            -- end)
            -- Ext.ModEvents.BG3SX.StartSexSpellUsed:Throw({caster = caster, target = target, animData = Data.IntroAnimations[ModuleUUID]["Ask for Sex"]})
        end
    end
end)


Event.TogglePause:SetHandler(function (payload)
    local scene = Scene.FindSceneByEntity(payload.Scene.entities[1])
    scene:TogglePause()
    -- If we add transitioning animations - our own loop system we need to also pause potential scene timers
end)

Event.SwapPosition:SetHandler(function (payload)
    local scene = Scene.FindSceneByEntity(payload.Scene.entities[1])
    scene:SwapPosition()
end)

Event.ChangeCameraHeight:SetHandler(function (payload)
    Debug.Print("Currently not Implemented - Needs access to Camera Control")
end)
Event.MoveScene:SetHandler(function (payload)
    local scene = Scene.FindSceneByEntity(payload.Scene.entities[1])
    local position = payload.Position -- vec3 WorldPosition table {x,y,z}

    scene:MoveSceneToLocation(position)
end)


Event.StopSex:SetHandler(function (payload)
    local scene = Scene.FindSceneByEntity(payload.Scene.entities[1]) -- Re-get scene because scene send as payload lost metatable status
    if scene then
        -- Event.SceneControlInstanceDestroyed:Broadcast(payload.Scene.entities)
        scene:Destroy()
    end
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
    local scene = Scene.FindSceneByEntity(payload.Scene.entities[1])
    local position = payload.Position
    scene:RotateScene(position)
end)

Event.FetchAnimations:SetHandler(function (payload)
    local sceneType = Scene.FindSceneByEntity(payload.Caster)
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
    -- _P("SEND PARTY ----------------------TO CLIENT WITH ID", payload.ID, "--------------------------")
    Event.SendParty:SendToClient(party, payload.ID)
end)

Event.FetchWhitelist:SetHandler(function (payload)
    local newPayload = {Whitelist = Data.AllowedTagsAndRaces, ModdedTags = Data.ModdedTags, Whitelisted = Data.WhitelistedEntities, Blacklisted = Data.BlacklistedEntities}
    Event.SendWhitelist:SendToClient(newPayload, payload.ID)
end)

Event.RequestWhitelistStatus:SetHandler(function (payload)
    local uuid = payload.Uuid
    local status = Entity:IsWhitelisted(uuid)
    Event.SendWhitelistStatus:SendToClient({Status = status}, payload.ID)
end)


Event.CustomEvent:SetHandler(function (payload)
    -- CreateAnimationFilter()
end)

Ext.Osiris.RegisterListener("GainedControl", 1, "after", function(target)
    Event.ChangeCharacter:Broadcast(target)
end)


Ext.Osiris.RegisterListener("LevelGameplayStarted", 2, "after", function(_, _)
    Event.ChangeCharacter:Broadcast("")
    -- UI.AppearanceTab:UpdateReplicationListener()
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
    local scene = Scene.FindSceneByEntity(caster)
    -- _D(scene)
    -- _D(animationData)
    scene:PlayAnimation(animationData)
end)



Event.FetchWhitelistedNPCs:SetHandler(function(payload)
    -- print("reveived FetchWhitelistedNPCs")
    local tbl = payload.tbl
    local filtered = {}

    -- print("dumping payload")
    -- _D(payload.client)

    if not payload.client then
        Debug.Print("ERROR, CLIENT NOT FOUND")
        return
    end



    for _, character in pairs(tbl) do
        if Entity:IsWhitelisted(character) then
            table.insert(filtered, character)
        end
    end

    -- Debug.Print("sending event  Event.SendWhitelistedNPCs:SendToClient")
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

-- Ext.ModEvents.BG3AF.WaterfallReplicated:Subscribe(function (uuid)
--     if Scene.FindSceneByEntity(uuid) then
--         local scene = Scene.FindSceneByEntity(uuid)
--         if scene and not scene.ReplicatedWaterfalls then
--             scene.ReplicatedWaterfalls = {}
--         end
--         scene.ReplicatedWaterfalls[uuid] = true
--         scene:ReplicationAnimationResetCheck()
--     end
-- end)

Event.ToggleInvisibility:SetHandler(function (uuid)
    local invisState = Osi.IsInvisible(uuid)
    if invisState == 1 then
        Osi.SetVisible(uuid, 1)
    elseif invisState == 0 then
        Osi.SetVisible(uuid, 0)
    end
end)