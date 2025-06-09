-----------------------------------------------------------------------------------------------------------------------------------------
                                            ---- Genital Functions ----
-----------------------------------------------------------------------------------------------------------------------------------------


-- Debug.Print("Registered GenitalListeners")



Event.SetInactiveGenital:SetHandler(function (payload)
    --print("Event set Inactive gential")

    local uuid = payload.uuid
    local genital = payload.Genital
    local entity = Ext.Entity.Get(uuid)

    if not entity then
        Debug.Print(tostring(uuid) .. " is not a valid entity")
    end

    SexUserVars.AssignGenital("BG3SX_OutOfSexGenital", genital, entity)
    -- If inactive is changed, update USerVars of entity and change genital
    -- only if no scene is currently active

    for _, scene in pairs(Data.SavedScenes) do
        
        for _, entity in pairs(scene.entities) do
            if Helper.StringContains(entity, uuid) then
                return
            end
        end
    end
    Genital.OverrideGenital(genital, entity)
end)



Event.SetActiveGenital:SetHandler(function (payload)

    print("Event set active gential")

    local uuid = payload.uuid
    local genital = payload.Genital
    local entity = Ext.Entity.Get(uuid)

    print("Assigning new sex genital to ", genital)
    SexUserVars.AssignGenital("BG3SX_SexGenital", genital, entity)

    -- If active is changed, update UserVars, search for active actors, and change their genitals as well

    local scene = Scene.FindSceneByEntity(uuid)

    -- character is currently in a sex scene (currently only works for scenes of 1 or 2 characters)
    if scene then
        if scene.Type == "NSFW" then
            -- immediately swap genitals
            Genital.OverrideGenital(genital, entity)

            scene.SceneType = Helper.DetermineSceneType(scene)
            -- if it is apaired animation, then swap the "top" and "bottom" based on genitals
            if #scene.entities == 2 then
                if Entity:HasPenis(scene.entities[1]) ~= Entity:HasPenis(scene.entities[2]) then
                    if not Entity:HasPenis(scene.entities[1]) then
                        local savedActor = scene.entities[1]
                        scene.entities[1] = scene.entities[2]
                        scene.entities[2] = savedActor
                    end
                end
            end

            for _, character in pairs(scene.entities) do    
                Event.UpdateSceneControlPicker:SendToClient({SceneType = scene.SceneType, Character = character}, character)

                    -- wait for the replication event to be sent to the AF and the AniamtionWaterfall to be re-adde don client
                --Ext.Timer.WaitFor(2000, function ()
                    -- print("resetting animation")
                    -- Animation.ResetAnimation(uuid)
                --end)
            end
        end
    end
end)



Ext.Osiris.RegisterListener("GainedControl", 1, "after", function(target)  

    -- send event to refresh genital tab 

end)

-- TODO - test for shapeshifts, rsculpts etc.
Ext.Events.NetMessage:Subscribe(function(e)



    if (e.Channel == "BG3SX_ChangeAutoErection") then


        -- payload.setting is "ON" or "OFF"
        local payload = Ext.Json.Parse(e.Payload)
        local character = payload.character
        local setting = payload.setting
        

        if setting == "ON" then
            SexUserVars.SetAutoSexGenital(true, character)
        elseif setting == "OFF" then
            SexUserVars.SetAutoSexGenital(false, character)
        end
    end

end)


Ext.Osiris.RegisterListener("ObjectTransformed", 2, "after", function(object, toTemplate)
    Debug.Print("ObjectTransformed -> SendGenitals for character ".. object)
    local conts = Ext.Entity.GetAllEntitiesWithComponent("ClientControl")
    if conts ~= nil then
        for k, v in pairs(conts) do
            print("sending genital update event for " , Helper.GetName(v.Uuid.EntityUuid))
            Event.SendGenitals:SendToClient({ID = nil, Data = Data.CreateUIGenitalPayload(v.Uuid.EntityUuid)}, v.UserReservedFor.UserID)
        end
    end
end)

Ext.Osiris.RegisterListener("ShapeshiftChanged", 4, "after", function(character, race, gender, shapeshiftStatus)
    Debug.Print("ShapeshiftChanged -> SendGenitals for character ".. character)
    local conts = Ext.Entity.GetAllEntitiesWithComponent("ClientControl")
    if conts ~= nil then
        for k, v in pairs(conts) do
            Event.SendGenitals:SendToClient({ID = nil, Data = Data.CreateUIGenitalPayload(v.Uuid.EntityUuid)}, v.UserReservedFor.UserID)
        end
    end
end)

Ext.Osiris.RegisterListener("TemplateUseFinished", 4, "before", function(character, itemTemplate, _, _)
    if (itemTemplate == "UNI_MagicMirror_72ae7a39-d0ce-4cb6-8d74-ebdf7cdccf91") then
        Debug.Print("TemplateUseFinished -> SendGenitals for character ".. character)
        local conts = Ext.Entity.GetAllEntitiesWithComponent("ClientControl")
        if conts ~= nil then
            for k, v in pairs(conts) do
                Event.SendGenitals:SendToClient({ID = nil, Data = Data.CreateUIGenitalPayload(v.Uuid.EntityUuid)}, v.UserReservedFor.UserID)
            end
        end
    end
end)