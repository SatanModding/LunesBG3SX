
Ext.RegisterNetListener("BG3SX_Client_Masturbate", function(e, payload)
    local payload = Ext.Json.Parse(payload)
    -- _P("ClientMasturbateEvent Dump")
    -- _D(payload)
    local caster = payload[1]
    local target = payload[1]
    if Entity:IsWhitelisted(caster, true) and Entity:IsWhitelisted(target, true) then
        Ext.Timer.WaitFor(200, function() -- Wait for erections
            Sex:StartSexSpellUsed(caster, {target}, Data.StartSexSpells["BG3SX_StartMasturbating"])
        end)
        Ext.ModEvents.BG3SX.StartSexSpellUsed:Throw({caster = caster, target = target, animData = Data.StartSexSpells["BG3SX_StartMasturbating"]})
    end
end)

Ext.RegisterNetListener("BG3SX_Client_AskForSex", function(e, payload)
    local payload = Ext.Json.Parse(payload)
    -- _P("ClientAskForSexEvent Dump")
    -- _D(payload)
    local caster = payload["caster"]
    local target = payload["target"]
    if Entity:IsWhitelisted(caster, true) and Entity:IsWhitelisted(target, true) then
        Ext.Timer.WaitFor(200, function() -- Wait for erections
            Sex:StartSexSpellUsed(caster, {target}, Data.StartSexSpells["BG3SX_AskForSex"])
        end)
        Ext.ModEvents.BG3SX.StartSexSpellUsed:Throw({caster = caster, target = target, animData = Data.StartSexSpells["BG3SX_AskForSex"]})
    end
end)


-------------------------------------------------------------------------------------------------
--------------- New v22 Events
UIEvents.FetchScenes:SetHandler(function (payload)
    if Data.SavedScenes and #Data.SavedScenes > 0 then
        _P("SavedScenes exists")
        UIEvents.SendScenes:SendToClient(Ext.Json.Stringify(Data.SavedScenes), payload.ID)
    else
        _P("SavedScenes doesn't exist")
        UIEvents.SendScenes:Broadcast("Empty")
    end
end)
UIEvents.AskForSex:SetHandler(function (payload)
    local caster = payload.Caster
    local target = payload.Target
    if Entity:IsWhitelisted(caster, true) and Entity:IsWhitelisted(target, true) then
        Ext.Timer.WaitFor(200, function() -- Wait for erections
            Sex:StartSexSpellUsed(caster, {target}, Data.StartSexSpells["BG3SX_StartMasturbating"])
        end)
        Ext.ModEvents.BG3SX.StartSexSpellUsed:Throw({caster = caster, target = target, animData = Data.StartSexSpells["BG3SX_StartMasturbating"]})
    end
end)
UIEvents.ChangePosition:SetHandler(function (payload)
    local scene = Scene:FindSceneByEntity(payload.Caster)
    local position = payload.Position
end)
UIEvents.ChangeCameraHeight:SetHandler(function (payload)
    Debug.Print("Currently not Implemented - Needs access to Camera Control")
end)
UIEvents.MoveScene:SetHandler(function (payload)
    local scene = Scene:FindSceneByEntity(payload)
end)
UIEvents.StopSex:SetHandler(function (payload)
    local scene = Scene:FindSceneByEntity(payload)
end)
UIEvents.FetchGenitals:SetHandler(function (payload)

    local conts = Ext.Entity.GetAllEntitiesWithComponent("ClientControl")
    if conts ~= nil then
        for k, v in pairs(conts) do
            print("sending payload to ", v.UserReservedFor.UserID)
            UIEvents.SendGenitals:SendToClient({ID = payload.ID, Data = Data.CreateUIGenitalPayload(payload.Character)}, v.UserReservedFor.UserID)
        end
    end
end)
    
    
   
UIEvents.FetchAnimations:SetHandler(function (payload)
    local sceneType = Scene:FindSceneByEntity(payload.ID)
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


UIEvents.FetchParty:SetHandler(function (payload)
    local party = Osi.DB_PartyMembers:Get(nil)
    UIEvents.SendParty:SendToClient({Data = party}, payload.ID)
end)



Ext.Osiris.RegisterListener("GainedControl", 1, "after", function(target)  
    print("Sending message about gained control ", target)
    UIEvents.ChangeCharacter:Broadcast(target)
end)
