UIHelper = {}
UIHelper.__index = UIHelper

function getMouseover()
    local mouseover = Ext.UI.GetPickingHelper(1)
    if mouseover ~= nil then
    -- setSavedMouseover(mouseover)
        return mouseover
    else
        _P("[BG3SX] Not a viable mouseover!")
    end 
end

function getUUIDFromUserdata(mouseover)
    local entity = mouseover.Inner.Inner[1].GameObject
    if entity ~= nil then
        return Ext.Entity.HandleToUuid(entity)
    else
        _P("[BG3SX] getUUIDFromUserdata(mouseover) - Not an entity!")
    end
end

-- function adapted from Aahz  https://www.nexusmods.com/baldursgate3/mods/9832
---Gets a table of entity uuid's for current party
---@return table<string>|nil
function UIHelper.GetCurrentParty()
    local party = Ext.Entity.GetAllEntitiesWithComponent("PartyMember")
    local partyMembers = {}
    for _,partyMember in pairs(party) do
        local uuid = Ext.Entity.HandleToUuid(partyMember)
        if uuid ~= nil then
            table.insert(partyMembers, uuid)
        end
    end
    return partyMembers
end

local sceneTypes = {
    ["SoloFemale"] = {InvolvedEntities = 1, Penises = 0},
    ["SoloMale"] = {InvolvedEntities = 1, Penises = 1},
    ["Lesbian"] = {InvolvedEntities = 2, Penises = 0},
    ["Straight"] = {InvolvedEntities = 2, Penises = 1},
    ["Gay"] = {InvolvedEntities = 2, Penises = 2}
}
function Helper.DetermineSceneType(scene)
    local InvolvedEntities = 0
    local Penises = 0
    for _,entity in pairs(scene.entities) do
        InvolvedEntities = InvolvedEntities+1
        if Entity:HasPenis(entity) then
            Penises = Penises+1
        end
    end
    for _,entry in pairs(sceneTypes) do
        if InvolvedEntities == entry.InvolvedEntities and Penises == entry.Penises then
            return entry.sceneType
        end
    end
end