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



