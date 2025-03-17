-----------------------------------------------------------------------------------------------------------------------------------------
                                            ---- Genital Functions ----
-----------------------------------------------------------------------------------------------------------------------------------------


-- Debug.Print("Registered GenitalListeners")



UIEvents.SetInactiveGenital:SetHandler(function (payload)

    print("Event set INactive gential")

    local uuid = payload.uuid
    local genital = payload.Genital
    local entity = Ext.Entity.Get(uuid)

    if not entity then
        print(uuid, " is not a valid entity")
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



UIEvents.SetActiveGenital:SetHandler(function (payload)

    print("Event set active gential")

    local uuid = payload.uuid
    local genital = payload.Genital
    local entity = Ext.Entity.Get(uuid)

    print("Assigning new sex genital to ", genital)
    SexUserVars.AssignGenital("BG3SX_SexGenital", genital, entity)

    -- If active is changed, update UserVars, search for active actors, and change their genitals as well

    for _, scene in pairs(Data.SavedScenes) do
        
        for _, character in pairs(scene.entities) do
            if Helper.StringContains(character, uuid) then
                Genital.OverrideGenital(genital, Ext.Entity.Get(character))
                Animation.ResetAnimation(uuid)
                return
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
            UIEvents.SendGenitals:SendToClient({ID = nil, Data = Data.CreateUIGenitalPayload(object)}, v.UserReservedFor.UserID)
        end
    end
end)

Ext.Osiris.RegisterListener("ShapeshiftChanged", 4, "after", function(character, race, gender, shapeshiftStatus)
    Debug.Print("ShapeshiftChanged -> SendGenitals for character ".. character)
    local conts = Ext.Entity.GetAllEntitiesWithComponent("ClientControl")
    if conts ~= nil then
        for k, v in pairs(conts) do
            UIEvents.SendGenitals:SendToClient({ID = nil, Data = Data.CreateUIGenitalPayload(character)}, v.UserReservedFor.UserID)
        end
    end
end)

Ext.Osiris.RegisterListener("TemplateUseFinished", 4, "before", function(character, itemTemplate, _, _)
    if (itemTemplate == "UNI_MagicMirror_72ae7a39-d0ce-4cb6-8d74-ebdf7cdccf91") then
        Debug.Print("TemplateUseFinished -> SendGenitals for character ".. character)
        local conts = Ext.Entity.GetAllEntitiesWithComponent("ClientControl")
        if conts ~= nil then
            for k, v in pairs(conts) do
                UIEvents.SendGenitals:SendToClient({ID = nil, Data = Data.CreateUIGenitalPayload(character)}, v.UserReservedFor.UserID)
            end
        end
    end
end)