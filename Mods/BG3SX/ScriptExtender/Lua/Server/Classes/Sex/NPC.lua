----------------------------------------------------------------------------------------------------
-- 
--                        NPC Stripping/Redressing and Genital Application/Removal
-- 
----------------------------------------------------------------------------------------------------

-- USE Entity:IsPlayable TO CHECK IF PLAYABLE


NPC = {}

SLOTS_TO_BE_REMOVED_FOR_SEX = {
    ["Footwear"] = true,
    ["Body"] = true,
    ["Gloves"] = true,
    ["Cloak"] = true,
    ["Underwear"] = true
}


----------------------------------------------------------------------------------------------------
-- 
-- 								    	Stripping
-- 
----------------------------------------------------------------------------------------------------


---@param entity EntityHandle
---@return table
function NPC.StripNPC(entity)

    removed = {}

    for type,_ in pairs(SLOTS_TO_BE_REMOVED_FOR_SEX) do
        
        local removedEntry = Visual.removeVisualSetBySlot(entity, type)
        table.insert(removed, removedEntry)
    end

    Visual.Replicate(entity)

    local payload = {uuid = entity.Uuid.EntityUuid}

    Ext.Net.BroadcastMessage("BG3SX_NPCStrip",Ext.Json.Stringify(payload))

    return removed

end

---@param entity EntityHandle
---@param toBeRestored table
function NPC.Redress(entity, toBeRestored)


    for _, entry in pairs(toBeRestored) do
        Visual.addVisualSetSlot(entity, entry)
    end

    Visual.Replicate(entity)

    local payload = {uuid = entity.Uuid.EntityUuid}
    Ext.Net.BroadcastMessage("BG3SX_NPCDress",Ext.Json.Stringify(payload))

end


----------------------------------------------------------------------------------------------------
--  
-- 								    	Genitals
-- 
----------------------------------------------------------------------------------------------------


---@param entity EntityHandle
function NPC.GiveGenitals(entity)

    -- Create Slot for genitals
    Visual.GiveVisualComponentIfHasNone(entity)
    Genital.AddGenitalIfHasNone(entity)

end


-- Remove the genital
---@param  entity EntityHandle 
function NPC:RemoveGenitals(entity)
    local genital = Genital.GetCurrentGenital(entity)
    if genital then
        Visual.BetterRemoveVisualOvirride(entity, genital)
        Visual.Replicate(entity)
    end
end


-- TODO: function giveHair for helmet havers
-- When removing helmer slots, NPCs don't have hair anymore
-- @param           - uuid of the NPC
local function addHairIfNecessary(uuid)
end


UIEvents.RequestStripNPC:SetHandler(function (payload)
    local entity = Ext.Entity.Get(payload.uuid)
    if not entity then
        Debug.Print(payload.uuid .. " is not an entity")
    end

    local clothes = NPC.StripNPC(entity)
    SexUserVars.SetNPCClothes(clothes, entity)

end)



UIEvents.RequestDressNPC:SetHandler(function (payload)
    local entity = Ext.Entity.Get(payload.uuid)
    if not entity then
        Debug.Print(payload.uuid .. " is not an entity")
    end


    local clothes = SexUserVars.GetNPCClothes(entity)
    NPC.Redress(entity, clothes)
    SexUserVars.SetNPCClothes(nil, entity)
end)
