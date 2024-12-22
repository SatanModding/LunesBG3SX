if Ext.IsServer() then
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

    Ext.RegisterNetListener("BG3SX_Client_RequestGenitals", function(e, payload)
        -- TODO - get UUID from client in payload instead, so its MP compatible
        local uuid = Osi.GetHostCharacter()
        local payload = Data.CreateUIGenitalPayload(uuid)
        Ext.Net.BroadcastMessage("BG3SX_Server_DistributeGenitals", Ext.Json.Stringify(payload))
    end)

    UIEvents.FetchScenes:SetHandler(function (payload)
        if Data.SavedScenes and #Data.SavedScenes > 0 then
            _P("SavedScenes exists")
            UIEvents.SendScenes:Broadcast(Ext.Json.Stringify(Data.SavedScenes))
        else
            _P("SavedScenes doesn't exist")
            UIEvents.SendScenes:Broadcast("Empty")
        end
    end)
end