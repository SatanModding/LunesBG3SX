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

