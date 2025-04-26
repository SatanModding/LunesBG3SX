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
-- 								    	Persistency
-- 
----------------------------------------------------------------------------------------------------

-- make NPCs added to the UI persistent (add them again whenever a save is loaded(UI built))

-- Yoinked from Muffin https://www.nexusmods.com/baldursgate3/mods/11437

function NPC:GetSavedNPCs()

    --print("retrieving saved NPCs")
    local modVars = Ext.Vars.GetModVariables(ModuleUUID)

    local npcs = {}

    --if modVars then
      --  print("modVars exist")
      --  _D(modVars)
       -- if modVars.BG3SX_AddedNPCs then
         --   print("added NPCs exist")
        --end
    --end

    if modVars and modVars.BG3SX_AddedNPCs then
        npcs = modVars.BG3SX_AddedNPCs
    end
    Ext.Vars.SyncModVariables(ModuleUUID)

    --_D(npcs)

    return npcs
end

-- cause of the dirty variables I think
function NPC:UpdateNPCs(npcs)
    --print("updating mod variable")
    Ext.Vars.GetModVariables(ModuleUUID).BG3SX_AddedNPCs = npcs
    _D(Ext.Vars.GetModVariables(ModuleUUID).BG3SX_AddedNPCs)
    Ext.Vars.SyncModVariables(ModuleUUID)
end


function NPC:SaveAddedNPC(npc, clientID)
    --print("saving NPC", npc, " for client ", clientID)

    local npcs = NPC:GetSavedNPCs()

    -- Create the subtable if it doesn't exist yet
    if not npcs[clientID] then
        npcs[clientID] = {}
    end

     -- Check for dupes
    if Table.Contains(npcs[clientID], npc) then
        --print("NPC already exists for this user")
    else
        -- Add the NPC
        table.insert(npcs[clientID], npc)
        --print("NPC ", npc, " added for user", clientID)
    end

    NPC:UpdateNPCs(npcs)
end

function NPC:RemoveRemovedNPC(npc, clientID)
    --print("removing NPC", npc, "for user", clientID)

    local npcs = NPC:GetSavedNPCs()

    -- Make sure the clientID exists in the table
    local userNPCs = npcs[clientID]
    if not userNPCs then
        --print("No NPCs found for this user. Dumping npc table")
        --_D(npcs)
        return
    end

    -- Search and remove the NPC
    local removed = false
    for i = #userNPCs, 1, -1 do
        if Helper.StringContainsOne(userNPCs[i],npc) then
            table.remove(userNPCs, i)
            removed = true
            break
        end
    end

    if removed then
        --print("NPC removed for user", clientID)
        NPC:UpdateNPCs(npcs)
    else
        --print("NPC not found for this user. Dumping")
        --_D(npcs)
    end
end

-- call this when UI is built
function NPC:RestoreNPCs()

    -- print("succesfully called restore NPCs")
    -- print("saved npcs")

    local allNPCs = NPC:GetSavedNPCs()
    -- print("saved NPCs")
    -- _D(allNPCs)

    for clientID,npcs in pairs(allNPCs) do
        if Ext.Entity.Get(clientID).ClientControl then
            Event.RestoreNPCTab:SendToClient({npcs = npcs}, clientID)
        end
    end
end

Event.AddedNPCToTab:SetHandler(function(payload)
    local id = payload.ID
    local npc = payload.npc
    NPC:SaveAddedNPC(npc, id)
end)

Event.RemovedNPCFromTab:SetHandler(function(payload)
    local id = payload.ID
    local npc = payload.npc
    NPC:RemoveRemovedNPC(npc, id)
end)

Event.FinishedBuildingNPCUI:SetHandler(function(payload)
    local id = payload.ID
    NPC:RestoreNPCs()
end)

----------------------------------------------------------------------------------------------------
-- 
-- 								    	Stripping
-- 
----------------------------------------------------------------------------------------------------

---@param entity EntityHandle
---@return table
function NPC.StripNPC(entity)
    local removed = {}
    for type,_ in pairs(SLOTS_TO_BE_REMOVED_FOR_SEX) do
        local removedEntry = Visual.removeVisualSetBySlot(entity, type)
        table.insert(removed, removedEntry)
    end
    if Ext.IsServer() then
        Visual.Replicate(entity)
    end
    
    return removed
end

---@param entity EntityHandle
---@param toBeRestored table
function NPC.Redress(entity, toBeRestored)
    for _, entry in pairs(toBeRestored) do
        Visual.addVisualSetSlot(entity, entry)
    end
    if Ext.IsServer() then
        Visual.Replicate(entity)
    end

    -- local payload = {uuid = entity.Uuid.EntityUuid}
    -- local payload = {Uuid = entity.Uuid.EntityUuid, Visuals = toBeRestored}

    -- Ext.Net.BroadcastMessage("BG3SX_NPCDress",Ext.Json.Stringify(payload))

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
function NPC.RemoveGenitals(entity)
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

-- on closing the game, template changes are yeeted.
-- To restore them, grab the uservars and strip all stripped NPCs
function NPC.RestoreNudity()
    local allNPCs = {}
    local allEntities = Ext.Entity.GetAllEntitiesWithComponent("ServerCharacter")
    for _,entity in pairs(allEntities) do
        if Entity:IsNPC(entity.Uuid.EntityUuid) then
        table.insert(allNPCs, entity)
        end
    end

    for _, npc in pairs (allNPCs) do
        local clothes = SexUserVars.GetNPCClothes(npc)
        --print("checking npc ", npc.Uuid.EntityUuid)
        if clothes then
            -- print("Stripping ", npc.Uuid.EntityUuid)
            NPC.StripNPC(npc)
            NPC.GiveGenitals(npc)
        end
    end
end


Event.RequestStripNPC:SetHandler(function (payload)
    local entity = Ext.Entity.Get(payload.uuid)
    if not entity then
        Debug.Print(payload.uuid .. " is not an entity")
    end

    local clothes = NPC.StripNPC(entity) -- Call on Server
    Event.SyncNPCStrip:Broadcast(entity.Uuid.EntityUuid) -- Call on Client

    -- safeguarding against overwriting the saved things with an empty table
    -- in case users strip twice

    local hasEmpty = false
    -- _D(clothes)
    for _,entry in pairs(clothes[1])do
        if (entry.uuid == "") then
            hasEmpty = true
        end
    end

    if hasEmpty == false then
        SexUserVars.SetNPCClothes(clothes, entity)
    end
end)


Event.RequestDressNPC:SetHandler(function (payload)
    local entity = Ext.Entity.Get(payload.uuid)
    if not entity then
        Debug.Print(payload.uuid .. " is not an entity")
    end

    local clothes = SexUserVars.GetNPCClothes(entity)

    if not clothes then
        print("no clothes saved for ", entity.Uuid.EntityUuid)
        return
    end

    NPC.Redress(entity, clothes)
    Event.SyncNPCDress:Broadcast({Uuid = entity.Uuid.EntityUuid, Visuals = clothes})

    SexUserVars.SetNPCClothes(nil, entity)
end)

Event.RequestGiveGenitalsNPC:SetHandler(function(payload)
    local uuid = payload.uuid
    local entity = Ext.Entity.Get(uuid)
    NPC.GiveGenitals(entity)
end) 
    
Event.RequestRemoveGenitalsNPC:SetHandler(function(payload)
    local uuid = payload.uuid
    local entity = Ext.Entity.Get(uuid)
    NPC.RemoveGenitals(entity)
end)