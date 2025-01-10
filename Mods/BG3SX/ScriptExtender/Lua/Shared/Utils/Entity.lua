----------------------------------------------------------------------------------------
--
--                               For handling Entities
--
----------------------------------------------------------------------------------------

-- CONSTRUCTOR
--------------------------------------------------------------

-- Variables
--------------------------------------------------------------

local availableAnimations = {}

-- METHODS
--------------------------------------------------------------

-- Sets an entities available custom animations
---@param uuid      string  - The entity UUID to check
function Entity:SetAvailableAnimations(uuid, animations)
    availableAnimations[uuid] = animations
end

-- Returns an entities available animations
---@param uuid      string  - The entity UUID to check
---@return          table   - Returns a saved table of animations
function Entity:GetAvailableAnimations(uuid)
    return availableAnimations[uuid]
end


-- Entity Movement
-----------------------------

-- Blocks the actors movement
---@param entity string  - uuid of entity
function Entity:ToggleMovement(entity)
    if Osi.HasAppliedStatus(entity, "ActionResourceBlock(Movement)") == 1 then
        Osi.RemoveBoosts(entity, "ActionResourceBlock(Movement)", 0, "", "")
    else
        Osi.AddBoosts(entity, "ActionResourceBlock(Movement)", "", "")
    end
end


-- Toggles WalkTrough
---@param entity string  - uuid of entity
function Entity:ToggleWalkThrough(entity)
    if Osi.HasAppliedStatus(entity, "CanWalkThrough(true)") then
        Osi.AddBoosts(entity, "CanWalkThrough(false)", "", "")
    else
        Osi.AddBoosts(entity, "CanWalkThrough(true)", "", "")
    end
end


-- Return Status
-------------------------------

--- Checks if entity is playable (PC or companion)
---@param uuid      string  - The entity UUID to check
---@return          boolean - Returns either 1 or 0
function Entity:IsPlayable(uuid)
    return Osi.IsTagged(uuid, "PLAYABLE_25bf5042-5bf6-4360-8df8-ab107ccb0d37") == 1
end


-- TODO swap out gender check to genital check when Genitals.lua TODO has been completed about giving polymorphed characters genitals
--- Checks if the entity has a penis as genital
---@param uuid      string  - The entity UUID to check
---@return          boolean - Returns either 1 or 0
function Entity:HasPenis(uuid)

    local entity = Ext.Entity.Get(uuid)


    local vulva = "a0738fdf-ca0c-446f-a11d-6211ecac3291"
    local penis = "d27831df-2891-42e4-b615-ae555404918b"

    -- Users can theoretically give the characters differen "flaccid" and "erect" genital
    -- this is why we need to ask specifically for the "erect" version, not just the
    -- current gential to get the correct animation
    local sexGenital = SexUserVars.GetGenital("BG3SX_SexGenital", entity)
    if sexGenital then
        print(uuid, " has sex genital. Determining genital type")
        local genitalTags =  Ext.StaticData.Get(sexGenital, "CharacterCreationAppearanceVisual").Tags
        if Table.Contains(genitalTags, vulva) then
            return false
        -- this gives up the option to set custom genital types. Liek tentacles
        elseif  Table.Contains(genitalTags, penis) then
            return true
        end
        
    end

    -- If entity is polymorphed (e.g., Disguise Self spell)
    if Osi.HasAppliedStatusOfType(uuid, "POLYMORPHED") == 1 then
        -- As of hotfix #17, the "Femme Githyanki" disguise has a penis for whatever reason.
        if Entity:TryGetEntityValue(uuid, nil, {"GameObjectVisual", "RootTemplateId"}) == "7bb034aa-d355-4973-9b61-4d83cf29d510" then
            return true
        end
        return Osi.GetGender(uuid, 1) ~= "Female"
    end

    -- Entities seem to have GENITAL_PENIS/GENITAL_VULVA ONLY if they are player chars or companions who can actually join the party.
    -- NPCs never get the tags. "Future" companions don't have them too.
    -- E.g., Halsin in Act 1 has no GENITAL_PENIS, he gets it only when his story allows him to join the active party in Act 2.
    if Entity:IsPlayable(uuid) then
        print(uuid, " is playable. Determining genital type")
        if Osi.IsTagged(uuid, "GENITAL_PENIS_d27831df-2891-42e4-b615-ae555404918b") == 1 then
            return true
        end
        if Osi.IsTagged(uuid, "GENITAL_VULVA_a0738fdf-ca0c-446f-a11d-6211ecac3291") == 1 then
            return false
        end
    else
        -- 0 = penis, 1 = vagina [This assumes that everyone is cis]
        local bodyType =  Ext.Entity.Get(uuid).BodyType.BodyType
        if bodyType == 1 then
            return false
        else
            return true
        end
    end

    -- Fallback for NPCs, "future" companions, etc.
    return Osi.IsTagged(uuid, "FEMALE_3806477c-65a7-4100-9f92-be4c12c4fa4f") ~= 1
end


-- Check if an entity has any equipment equipped
---@param uuid      string  - The entity UUID to check
---@return          bool    - Returns either true or false
function Entity:HasEquipment(uuid)
    local entity = Ext.Entity.Get(uuid)
    if Entity:GetEquipment(uuid) then
        return true
    end
    return false
end


-- Return Component
-------------------------------

-- NPCs don't have CharacterCreationStats
function Entity:IsNPC(uuid)
    local E = Helper.GetPropertyOrDefault(Ext.Entity.Get(uuid),"CharacterCreationStats", nil)
    if E then
        return false
    else
        return true
    end
end


-- Functions
-------------------------------

-- TODO: Description
---@param entityArg any
local function resolveEntityArg(entityArg)
    if entityArg and type(entityArg) == "string" then
        local e = Ext.Entity.Get(entityArg)
        if not e then
            -- _P("[BG3SX][Entity.lua] resolveEntityArg: failed resolve entity from string '" .. entityArg .. "'")
        end
        return e
    end
    return entityArg
end


--- Tries to copy an entities component to another entity
---@param uuid_1    string          - Source Entities UUID
---@param uuid_2    string          - Target Entities UUID
---@param componentName string      - Component to copy
function Entity:TryCopyEntityComponent(uuid_1, uuid_2, componentName)
    local srcEntity = Ext.Entity.Get(uuid_1)
    local trgEntity = Ext.Entity.Get(uuid_2)

    -- Find source component
    srcEntity = resolveEntityArg(srcEntity)
    if not srcEntity then
        return false
    end
    local srcComponent = srcEntity[componentName]
    if not srcComponent then
        return false
    end

    -- Find dest component or create if not existing
    trgEntity = resolveEntityArg(trgEntity)
    if not trgEntity then
        return false
    end
    local dstComponent = trgEntity[componentName]
    if not dstComponent then
        trgEntity:CreateComponent(componentName)
        dstComponent = trgEntity[componentName]
    end

    -- Copy stuff
    if componentName == "ServerItem" then
        for k, v in pairs(srcComponent) do
            if k ~= "Template" and k ~= "OriginalTemplate" then
                Helper.TryToReserializeObject(dstComponent[k], v)
            end
        end
    else
        local serializeResult = Helper.TryToReserializeObject(srcComponent, dstComponent)
        if serializeResult then
            _P("[BG3SX][Entity.lua] - TryCopyEntityComponent, with component: " .. componentName)
            _P("[BG3SX][Entity.lua] - Serialization fail")
            _P("[BG3SX][Entity.lua] - Result: " .. serializeResult)
            return false
        end
    end

    if componentName ~= "ServerIconList" and componentName ~= "ServerDisplayNameList" and componentName ~= "ServerItem" then
        trgEntity:Replicate(componentName)
    end
    return true
end


-- TODO: Remove this old function if we don't need this anymore -- I think it may be in Table.lua now?
-- Tries to get the value of an entities component
---@param uuid      string      - The entity UUID to check
---@param component Component   - The Component to get the value from
---@param field1    Field       - Field1 to check
---@param field2    Field       - Field2 to check
---@param field3    Field       - Field3 to check
---@return          Value       - Returns the value of a field within a component
---@example
-- local helmetIsInvisible = Entity:TryGetEntityValue(entity, "ServerCharacter", "PlayerData", "HelmetOption")
-- _P(helmetIsInvisible) -- Should return either 0 or 1
-- Its essentially like using Ext.Entity.Get(entity).ServerCharacter.PlayerData.HelmetOption
-- function Entity:TryGetEntityValue(uuid, component, field1, field2, field3)
--     local entity = Ext.Entity.Get(uuid)
--     local v, doStop
    
--     v = resolveEntityArg(entity)
--     if not v then
--         return nil
--     end

--     function GetFieldValue(obj, field)
--         if not field then
--             return obj, true
--         end
--         local newObj = obj[field]
--         return newObj, (newObj == nil)
--     end

--     v, doStop = GetFieldValue(v, component)
--     if doStop then
--         return v
--     end

--     v, doStop = GetFieldValue(v, field1)
--     if doStop then
--         return v
--     end

--     v, doStop = GetFieldValue(v, field2)
--     if doStop then
--         return v
--     end

--     v, doStop = GetFieldValue(v, field3)
--     return v
-- end


-- Tries to get the value of an entities component
---@param uuid              string      - The entity UUID to check
---@param previousComponent any|nil       - component of previous iteration
---@param components        table       - Sorted list of component path
---@return any                        - Returns the value of a field within a component
---@example
-- Entity:TryGetEntityValue("UUID", nil, {"ServerCharacter, "PlayerData", "HelmetOption"})
-- nil as previousComponent on first call because it iterates over this parameter during recursion
function Entity:TryGetEntityValue(uuid, previousComponent, components)
    local entity = Ext.Entity.Get(uuid)
    if #components == 1 then -- End of recursion
        if not previousComponent then
            local value = Helper.GetPropertyOrDefault(entity, components[1], nil)
            return value
        else
            local value = Helper.GetPropertyOrDefault(previousComponent, components[1], nil)
            return value
        end
    end

    local currentComponent
    if not previousComponent then -- Recursion
        currentComponent = Helper.GetPropertyOrDefault(entity, components[1], nil)
        -- obscure cases
        if not currentComponent then
            return nil
        end
    else
        currentComponent = Helper.GetPropertyOrDefault(previousComponent, components[1], nil)
    end

    table.remove(components, 1)

    -- Return the result of the recursive call
    return Entity:TryGetEntityValue(uuid, currentComponent, components)
end


-- Unequips all equipment from an entity
---@param uuid          string  - The entity UUID to unequip
---@return table   - Collection of every previously equipped item
function Entity:UnequipAll(uuid)
    --Osi.SetArmourSet(uuid, 0)
    
    local oldEquipment = {}
    for _, slotName in ipairs(Data.Equipment.Slots) do
        local gearPiece = Osi.GetEquippedItem(uuid, slotName)
        if gearPiece then
            Osi.LockUnequip(gearPiece, 0)
            Osi.Unequip(uuid, gearPiece)
            oldEquipment[#oldEquipment+1] = gearPiece
        end
    end
    return oldEquipment
end


-- Gets a table of equipped items
---@param uuid              string  - The entity UUID to unequip
---@return currentEquipment table   - Collection of every equipped items
function Entity:GetEquipment(uuid)    
    local currentEquipment = {}
    for _, slotName in ipairs(Data.Equipment.Slots) do
        local gearPiece = Osi.GetEquippedItem(uuid, slotName)
        if gearPiece then
            currentEquipment[#currentEquipment+1] = gearPiece
        end
    end
    return currentEquipment
end


-- Re-equips all equipment of an entity
---@param entity      string      - The entity UUID to equip
---@param armorset  ArmorSet    - The entities prior armorset
---@paran slots table -  Format: {uuid = entry.VisualResource, index = i}
function Entity:Redress(entity, oldArmourSet, oldEquipment, slots)


    if oldArmourSet and (type(oldArmourSet) == "number") then
        Osi.SetArmourSet(entity, oldArmourSet)
    end

    if oldEquipment then
        for _, item in ipairs(oldEquipment) do
            Osi.Equip(entity, item)
        end
    end

    oldArmourSet = nil
    oldEquipment = nil

    if slots then 
        local actualEntity = Ext.Entity.Get(entity)
        if not actualEntity then
            print("is not an entity ", entity)
        end

        NPC.Redress(actualEntity, slots) 
    end


end


-- Scales the entity
---@param uuid  string  - The entity UUID to scale
---@param value float   - The value to increase or decrease the entity scale with
function Entity:Scale(uuid, value)
    local entity = Ext.Entity.Get(uuid)
    if entity.GameObjectVisual then  -- Safeguard against someone trying scale Scenery NPCs
        entity.GameObjectVisual.Scale = value
        entity:Replicate("GameObjectVisual")
    end
end


-- TODO: Save them and reapply them back when a scene is destroyed
-- Removes any random status effects an eneity might have that manipulate scaling
---@param uuid  string  - The entity UUID to purge bodyscale statuses from
function Entity:PurgeBodyScaleStatuses(entity)
    local result = false
    if entity.CameraScaleDown then
        -- Need to purge all statuses affecting the body scale that could expire during sex,
        -- especially if we're going to scale the body down to bring the camera closer.
        for _, status in ipairs(Data.Statuses.BodyScaleStatuses) do
            if Osi.HasAppliedStatus(entity, status) == 1 then
                local statusToRemove = status
                if status == "MAG_GIANT_SLAYER_LEGENDARY_ENLRAGE" then
                    statusToRemove = "ALCH_ELIXIR_ENLARGE"
                end
                Osi.RemoveStatus(entity, statusToRemove, "")
                result = true
            end
        end
    end
    return result
end


-- Bodytype/race specific animations
--------------------------------------------------------------

-- returns bodytype and bodyshape of entity
--@param character string - uuid
--@param bt int           - bodytype  [0,1]
--@param bs int           - bodyshape [0,1]
local function getBody(character)
    -- Get the properties for the character
    local E = Helper.GetPropertyOrDefault(Ext.Entity.Get(character),"CharacterCreationStats", nil)
    local bt =  Ext.Entity.Get(character).BodyType.BodyType
    local bs = 0
    if E then
        bs = E.BodyShape
    end
    return bt, bs
end


-- returns the cc bodytype based on entity bodytype/bodyshape
--@param bodytype  int   - 0 or 1
--@param bodyshape int   - 0 or 1
--@param cc_bodytype int - [1,2,3,4]
local function getCCBodyType(bodytype, bodyshape)
    for _, entry in pairs(CC_BODYTYPE) do
        if (entry.type == bodytype) and (entry.shape == bodyshape) then
            return entry.cc
        end 
    end
end


-- returns race of character - if modded, return human
--@param character string - uuid
--@return race     string - uuid
local function getRace(character)
    local raceTags = Ext.Entity.Get(character):GetAllComponents().ServerRaceTag.Tags
    local race
    for _, tag in pairs(raceTags) do
        if Data.BodyLibrary.RaceTags[tag] then
            race = Table.GetKey(Data.BodyLibrary.Races, Data.BodyLibrary.RaceTags[tag])
            break
        end
    end
    -- fallback for modded races - mark them as humanoid
    if not Data.BodyLibrary.Races[race] then
        race = "0eb594cb-8820-4be6-a58d-8be7a1a98fba"
    end
    return race
end


-- use a helper object and Osi to make an entity rotate
---@param uuid string
---@return helper uuid - Helper object that the entity can later look towards with Osi.SteerTo
function Entity:SaveEntityRotation(uuid)
    local entityPosition = {}
    entityPosition.x,entityPosition.y,entityPosition.z = Osi.GetPosition(uuid)
    local entityRotation = {}
    entityRotation.x,entityRotation.y,entityRotation.z = Osi.GetRotation(uuid)
    local entityDegree = Math.DegreeToRadian(entityRotation.y)
    local distanceAwayFromEntity = 1 -- Can be changed
    local x = entityPosition.x + (distanceAwayFromEntity * math.cos(entityDegree))
    local y = entityPosition.y + (distanceAwayFromEntity * math.sin(entityDegree))
    local z = entityPosition.z

    -- Creates and returns the helper object spawned at a distance based on entity rotation to store it to later steer towards
    local helper = Osi.CreateAt("06f96d65-0ee5-4ed5-a30a-92a3bfe3f708", x, y, z, 0, 0, "")
    return helper
end


-- Finds the angle degree of an entity based on position difference to a target
---@param entity string - The entities uuid
---@param target string - The targets uuid
function Entity:FindAngleToTarget(entity, target)
    local entityPos = {}
    local targetPos = {}
    entityPos.y, entityPos.x,entityPos.z = Osi.GetPosition(entity)
    targetPos.y, targetPos.x,targetPos.z = Osi.GetPosition(target)
    local dif = {
        y = entityPos.y - targetPos.y,
        x = entityPos.x - targetPos.x,
        z = entityPos.z - targetPos.z,  
    }
    local degree = math.atan(dif.y, dif.x)
    return degree
end


-- use a helper object and Osi to make an entity rotate
---@param entity uuid
---@param helper uuid - helper object 
function Entity:RotateEntity(uuid, helper)
    Osi.SteerTo(uuid, helper, 1)
end


-- Transcribed from LaughingLeader
-- Written by Focus
-- Updated to actually work by Skiz
-- Clears an entities action queue
---@param character any
function Entity:ClearActionQueue(character)
    Osi.FlushOsirisQueue(character)
    Osi.CharacterMoveTo(character, character, "Walking", "")
end


-- Toggles companions moving back to their camp positions or staying put
---@param entity any
function Entity:ToggleCampFlag(entity)
    if Osi.GetFlag("161b7223-039d-4ebe-986f-1dcd9a66733f", entity) == 1 then
        Osi.ClearFlag("161b7223-039d-4ebe-986f-1dcd9a66733f", entity)
    else
        Osi.SetFlag("161b7223-039d-4ebe-986f-1dcd9a66733f", entity, 0,0)
    end
end
function Entity:HasCampFlag(entity)
    if Osi.GetFlag("161b7223-039d-4ebe-986f-1dcd9a66733f", entity) == 1 then
        return true
    end
end


function Entity:CopyDisplayName(entityToCopyFrom, targetEntity)
    local name = Osi.GetDisplayName(entityToCopyFrom)
    local trName = Ext.Loca.GetTranslatedString(name)
    Osi.SetStoryDisplayName(targetEntity, trName)
end


-- Returns the allowed animations for a character (based on whether they are an Origin, bodytype [and maybe race - waiting for test results])
---@param character any
local function getAllowedAnimations(character)
    -- General works for everyone. Origins get their special ones + general
    -- Everyone else gets General
    local allowedAnimations
    local generics = Data.Animations["any"]

    -- Origin animations
    for uuid, animationList in pairs(Data.Animations) do
        if uuid == character then
            allowedAnimations = Concat(generics, animationList)
        end
    end

    -- Tavs etc
    if allowedAnimations == nil then
        allowedAnimations = generics
    end

    local bt, bs = getBody(character)
    local cc_bodytype = getCCBodyType(bt, bs)
    local race = getRace(character)

    -- some animations are bodytype & race locked
    if prayingAllowed(cc_bodytype, race) then
        allowedAnimations = Concat(allowedAnimations, Data.Animations["pray"])
    end
    if thinkingAllowed(cc_bodytype, race) then
        allowedAnimations = Concat(allowedAnimations, Data.Animations["think"])
    end
    return allowedAnimations
end




-- gives shapeshifted entity a visual (like CCAV)
-- character string - UUID
-- visual string    - UUID
function Entity:GiveShapeshiftedVisual(character, visual)
    local entity = Ext.Entity.Get(character)        

    -- usually this component never exists. AAE creates one too
    if (not entity.AppearanceOverride) then
        -- print("Adding Component")
        entity:CreateComponent("AppearanceOverride") -- TODO: instead of timers subscribe to entity component
    end

    local visuals = {}
    -- Eralyne figured out that type has to be 2 for changes to be visible.
    -- We do not know why
    entity.GameObjectVisual.Type = 2

    -- _P("Overriding visuals of ", character)

    for _, entry in pairs(entity.AppearanceOverride.Visual.Visuals) do
        -- _P("inserting ", visual)
        table.insert(visuals,entry)
    end
    -- _P("visuals to be added ")
    -- _D(visuals)

    -- _P("Visuals before adding")
    -- _D(entity.AppearanceOverride.Visual.Visuals)

    table.insert(visuals, visual)
    entity.AppearanceOverride.Visual.Visuals = visuals
    entity:Replicate("AppearanceOverride")
    entity:Replicate("GameObjectVisual") 

    -- _P("Visuals after adding")
    -- _D(entity.AppearanceOverride.Visual.Visuals)

    -- revert to originial type to prevent weird things from happening
    -- Timer necessary because else the visual change doesn't show if we revert to 4 too fast. 
    Ext.Timer.WaitFor(100, function()
        entity.GameObjectVisual.Type = 4
    end)
end


-- Deletes a visual based on a type we are looking for
---@param character string  - UUID
---@param visual    string  - UUID
---@param type      string  - name (ex: Private Parts)
function Entity:DeleteCurrentVisualOfType(character, visual, type)
    local visualType = Visual:getType(visual) -- visualType = CCAV or CCSV
    -- print("Debug: visualType = " .. tostring(visualType))
    local entity = Ext.Entity.Get(character)


    -- all visuals except for the one to be removed
    local allowedVisuals= {}
    if entity.AppearanceOverride then
    -- if appearanceOverride then
        for _, currentVisual in pairs(entity.AppearanceOverride.Visual.Visuals) do
            Debug.Print( " currentVisual = " .. tostring(currentVisual))
            local contents = Ext.StaticData.Get(currentVisual, visualType)
            -- print("Debug: contents = " .. tostring(contents))

            if contents then
                local slotName = contents.SlotName
                Debug.Print("slotname " .. slotName)
                -- print("Debug: slotName = " .. tostring(slotName))
                if slotName and slotName ~= type then -- Only add
                Debug.Print("type is not ".. type .. " adding to list to keep")
                    table.insert(allowedVisuals, currentVisual)
                    -- print("Debug: added visual to allowedVisuals = " .. tostring(visual))
                end
            else
                Debug.Print("does not have contents " .. currentVisual)
                table.insert(allowedVisuals, currentVisual)

            end
        end
        -- print("Debug: allowedVisuals = " .. tostring(allowedVisuals))
        Debug.Print("setting visuals to")
        --Debug.Dump(allowedVisuals)
        entity.AppearanceOverride.Visual.Visuals = allowedVisuals
        -- print("Debug: updated entity.AppearanceOverride.Visual.Visuals = " .. tostring(entity.AppearanceOverride.Visual.Visuals))
    end
    local previousEntityType = entity.GameObjectVisual.Type
    entity.GameObjectVisual.Type = 2
    entity:Replicate("AppearanceOverride")
    -- Ext.Timer.WaitFor(500, function() entity:Replicate("GameObjectVisual") end)
    -- Entity:SetGameObjectVisualType(entity, previousEntityType)

    -- revert to originial type to prevent weird things from happening
    -- Timer necessary because else the visual change doesn't show if we revert to 4 too fast.
    

    Ext.Timer.WaitFor(100, function()
        entity.GameObjectVisual.Type = 4

    end)
end


-- Gives shapeshifted entity a visual (like CCAV) and 
-- Deletes any other visuals of the same type (ex: type = private parts)
-- Replicates edited components -- TODO: Remosve replication from the other functions or this one
---@param character string  - UUID
---@param visual    string  - UUID
---@param type      string  - name (ex: Private Parts)
function Entity:SwitchShapeshiftedVisual(character, visual, type)

    Ext.Timer.WaitFor(200, function ()
        Debug.Print("Removing " .. type .. " from " .. character .. " and adding " .. visual)
        Entity:DeleteCurrentVisualOfType(character, visual, type)
        Entity:GiveShapeshiftedVisual(character, visual)
        -- print("Debug: called Entity:GiveShapeshiftedVisual with character = " .. tostring(character) .. " and visual = " .. tostring(visual))
    end)
   
end



