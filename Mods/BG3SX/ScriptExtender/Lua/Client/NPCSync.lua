Ext.Events.NetMessage:Subscribe(function(e) 
    if (e.Channel == "BG3SX_NPCStrip") then
        local character = Ext.Json.Parse(e.Payload)
        Debug.Print("Stripping for NPC in multiplayer required")
    end
    if (e.Channel == "BG3SX_NPCDress") then
        local character = Ext.Json.Parse(e.Payload)
        Debug.Print("Redressing for NPC in multiplayer required")
    end
end)

-- Doesn't work with ModEvents because it needs to be replicated on all clients

-- Ext.ModEvents.BG3SX.NPCStrip:Subscribe(function (payload)
--     local strip = Ext.Json.Parse(payload)
--     Ext.Resource.Get(strip.resource,"CharacterVisual").VisualSet.Slots = strip.naked
-- end)
-- Ext.ModEvents.BG3SX.NPCDress:Subscribe(function (payload)
--     local dress = Ext.Json.Parse(payload)
--     Ext.Resource.Get(dress.resource,"CharacterVisual").VisualSet.Slots = dress.dressed
-- end)