Heightmatching = {}
Heightmatching.__index = Heightmatching
HeightmatchingInstances = {} -- Don't create it as Heightmatching.Instance so we don't replicate all instances for every instance:new()

Heightmatching = {}
Heightmatching.__index = Heightmatching
HeightmatchingInstances = {} -- Don't create it as Heightmatching.Instance so we don't replicate all instances for every instance:new()

-- TODO: Move some table functions over to Table:

---Retrieves a Heightmatching instance by its animation name.
---@param animName string - The animation name used as the unique identifier for the instance.
---@return table|nil - The Heightmatching instance if found, or nil if not found.
function Heightmatching:GetInstanceByAnimName(animName)
    return HeightmatchingInstances[animName]
end

-- TODO: Maybe keep or remove - This was used to pre-create the table structure we now create dynamically during testing
------------------------------------------------------------------------------
--#region Old code
-- -- Overarching table for body types, agnostic types, etc.
-- Heightmatching.Keys = {
--     BodyTypes = {"TallM", "TallF", "MedM", "MedF", "SmallM", "SmallF", "TinyM", "TinyF"},
--     AgnosticTypes = {"Tall", "Med", "Small", "Tiny"},
--     Genders = {"M", "F"},
--     ModdedBodyTypes = {}  -- This can be extended by modders
-- }
-- -- Modders can use this snippet to add their own body types:
-- -- table.insert(Mods.BG3SX.Heightmatching.Keys.ModdedBodyTypes, "CustomType1")


-- -- Generates all combinations of keys from multiple tables.
-- function Heightmatching.generateAllCombinations(keysTable)
--     local allCombinations = {}

--     local function recursiveCombine(remainingKeys, currentCombination)
--         if #remainingKeys == 0 then
--             table.insert(allCombinations, currentCombination)
--         else
--             local currentKeys = remainingKeys[1]
--             for _, key in ipairs(currentKeys) do
--                 local newCombination = {}
--                 for k, v in pairs(currentCombination) do
--                     newCombination[k] = v
--                 end
--                 table.insert(newCombination, key)
--                 recursiveCombine({table.unpack(remainingKeys, 2)}, newCombination)
--             end
--         end
--     end

--     recursiveCombine(keysTable, {})
--     return allCombinations
-- end


-- --- Creates or updates an entry in the `matchingTable`.
-- -- If only a single key is provided, it creates or updates the `Solo` entry.
-- -- If two keys are provided, it creates or updates the specific combination entry.
-- ---@param key1 string The primary key or body type.
-- ---@param key2 string|nil The secondary key or body type. If `nil`, updates the `Solo` entry.
-- ---@param topAnim string The animation identifier for the top part. If `nil`, uses the fallback value.
-- ---@param bottomAnim string|nil The animation identifier for the bottom part. If `nil`, uses the fallback value.
-- function Heightmatching:createOrUpdateEntry(key1, key2, topAnimation, bottomAnimation)
--     if not self.matchingTable[key1] then
--         self.matchingTable[key1] = {}
--     end

--     if key2 then
--         self.matchingTable[key1][key2] = {
--             Top = topAnimation or self.fallbackTop,
--             Bottom = bottomAnimation or self.fallbackBottom
--         }
--     else
--         -- Handle solo entry case
--         self.matchingTable[key1].Solo = topAnimation or self.fallbackTop
--     end
-- end


-- function Heightmatching:initializeTable()
--     -- Generate all combinations of keys
--     local keys = Heightmatching.Keys
--     local allCombinations = Heightmatching.generateAllCombinations(keys)

--     -- Initialize entries based on the combinations
--     for _, combination in ipairs(allCombinations) do
--         if combination[2] then
--             self:createOrUpdateEntry(combination[1], combination[2], self.fallbackTop, self.fallbackBottom)
--         else
--             self:createOrUpdateEntry(combination[1], nil, self.fallbackTop)
--         end
--     end

--     -- Add solo entries for each key
--     for _, key in ipairs(keys.BodyTypes) do
--         self.matchingTable[key].Solo = self.fallbackTop
--     end
-- end
--#endregion
------------------------------------------------------------------------------

--- Creates a new `Heightmatching` instance with initialized entries.
-- Initializes all possible body type combinations and gender-agnostic types.
-- Also sets up mixed-match entries based on body types, genders, agnostic types and modded ones in Heightmatching.Keys.
---@param animName string The name of the animation instance.
---@param fallbackTop string The default animation identifier for the top part.
---@param fallbackBottom string|nil The default animation identifier for the bottom part. If `nil`, no default is set.
---@return Heightmatching The newly created `Heightmatching` instance.
function Heightmatching:New(animName, fallbackTop, fallbackBottom) -- TODO: Add possibility of inserting a table of possible additional fallbacks as 4th parameter which may get chosen randomly
    local instance = setmetatable({}, self)
    instance.fallbackTop = fallbackTop
    instance.fallbackBottom = fallbackBottom or nil
    instance.matchingTable = {}

    -- instance:initializeTable() -- This was used to pre-create the table structure based on all the code above which we now do dynamically

    HeightmatchingInstances[animName] = instance
    return instance
end


--- Sets or updates animations for specific body type combinations.
-- If only a single body type is provided, it updates the `Solo` entry for that body type.
-- If two body types are provided, it updates the animation for that specific combination.
---@param bodyType1 string The primary body type or gender.
---@param bodyType2 string|nil The secondary body type or gender. If `nil`, updates the `Solo` entry.
---@param topAnimation string The animation identifier for the top part. If `nil`, uses the default value.
---@param bottomAnimation string|nil The animation identifier for the bottom part. If `nil`, uses the default value.
function Heightmatching:SetAnimation(bodyType1, bodyType2, topAnimation, bottomAnimation)
    self.matchingTable[bodyType1] = self.matchingTable[bodyType1] or {} -- Creates the first level of the table if it doesn't exist, otherwise uses the existing one
    if bodyType2 then
        self.matchingTable[bodyType1][bodyType2] = self.matchingTable[bodyType1][bodyType2] or {} -- Do the same for the second level
        -- Set top and bottom animations
        self.matchingTable[bodyType1][bodyType2].Top = topAnimation or self.fallbackTop
        self.matchingTable[bodyType1][bodyType2].Bottom = bottomAnimation or self.fallbackBottom
    else
        -- Handle solo entry case
        self.matchingTable[bodyType1].Solo = topAnimation or self.fallbackTop
    end
end


-- For custom race modders, if you have a race that has a special bodyshape, but gets reconized as another one, you can add your tags by just typing this somewhere in your mod:
-- local bsOverrides = Mods.BG3SX.Heightmatching.BodyShapeOverrides
-- bsOverrides["Your Custom Race Tag"] = 0
-- 0 is Med - 1 is Tall - 2 is Small - 3 is Tiny
Heightmatching.BodyShapeOverrides = {
    ["02e5e9ed-b6b2-4524-99cd-cb2bc84c754a"] = 1,   -- Dragonborn Tall -- May need to remove this tag if someone ever does medium Dragonborn or Orcs
    ["3311a9a9-cdbc-4b05-9bf6-e02ba1fc72a3"] = 1,   -- Half-Orc Tall
    ["486a2562-31ae-437b-bf63-30393e18cbdd"] = 2,   -- Dwarf Small
    ["1f0551f3-d769-47a9-b02b-5d3a8c51978c"] = 3,   -- Gnome Tiny
    ["b99b6a5d-8445-44e4-ac58-81b2ee88aab1"] = 3,   -- Halfling Tiny
    ["7fa93b80-8ba5-4c1d-9b00-5dd20ced7f67"] = 0,   -- Githzerai Medium
    -- BodyShape Tags - Always list as last
    -- ["d3116e58-c55a-4853-a700-bee996207397"] = 1,   -- BodyShape Strong Tag -- TODO: Check if we need this at all, apparently only this tag exist
}

-- Checks a list of raceTags against any BodyShapeOverrides and returns an override if it finds one
---@param raceTags table -- Table of raceTags to check against Table of BodyShapeOverrides
---@return bs - BodyShapeOverride
local function bodyShapeOverrides(raceTags)
    local bs 
    for tag,value in pairs(Heightmatching.BodyShapeOverrides) do
        if Table:Contains(raceTags, tag) then
            bs = value
        end
    end
    -- Resolve loop first to pick potential direct bodyshape tags last and use these instead of race specific ones
    return bs
end

--- Retrieves the body type and shape of an entity based on its UUID.
-- Considers the entity's race and certain overrides to determine the correct body type and shape.
-- This function is designed to handle custom race tags like Githzerai, Dwarf, Gnome, and Halfling.
-- It returns a human-readable string that represents the body shape and body type combination.
---@param uuid string - The unique identifier of the entity.
---@return string - A concatenated string representing the body shape and body type (e.g., "TallM", "MedF").
function Heightmatching:GetEntityBody(uuid)
    local entity = Ext.Entity.Get(uuid)
    local raceTags = Entity:TryGetEntityValue(uuid, nil, {"ServerRaceTag", "Tags"})
    local bt = entity.BodyType.BodyType
    local bs = 0 -- Default Medium bodyShape
    local p = 0
    if Entity:IsNPC(uuid) == false then
        if Entity:HasPenis(uuid) then
            p = 0
        else
            p = 1
        end
        bs = entity.CharacterCreationStats.BodyShape
    end
    -- Apply body shape overrides based on race tags
    local bsOverride = bodyShapeOverrides(raceTags)
    if bsOverride ~= nil then
        bs = bsOverride
    end
    -- Translate to Human-readable
    bt = Data.BodyLibrary.BodyType[bt]
    bs = Data.BodyLibrary.BodyShape[bs]
    -- _P(uuid, " is of bt/bs ", bs .. bt)
    return bs, bt, g -- TallM, MedF, etc.
end



-- --- Splits a concatenated body type and shape string to extract either the body type or the body shape.
-- -- Depending on the type parameter, this function will return the body type or body shape component.
-- -- The function expects that the body shape is always prefixed, followed by the body type.
-- ---@param btsg string - The concatenated body type/shape/genital string (e.g., "TallM").
-- ---@param type string - Specifies whether to extract the body type ("BT") or the body shape ("BS").
-- ---@return string - The extracted body type or body shape, depending on the 'type' parameter.
-- local function splitBodyString(btsg, type)
--     -- Patterns for Regex - Generated through GetBodyType
--     local bt_pattern = "(Tall|Med|Small|Tiny)"  -- Matches 'Tall', 'Med', 'Small', 'Tiny' (case-sensitive)
--     local bs_pattern = "(F|M)"  -- Matches 'F' or 'M' (case-sensitive)
--     local g_pattern = "(_[PV])"  -- Matches '_P' or '_V' (case-sensitive)

--     local bt, bs, g

--     if btsg:match(bt_pattern) then
--         bt = btsg:match(bt_pattern)  -- Match body height type (Tall, Med, Small, Tiny)
--     end

--     if btsg:match(bs_pattern) then
--         bs = btsg:match(bs_pattern)  -- Match gendered bodyshape (F, M)
--     end

--     if btsg:match(g_pattern) then
--         g = btsg:match(g_pattern)  -- Match genital (_P, _V)
--     end

--     if type == "BT" then
--         if bt then
--             return bt
--         else
--             return Debug.Print("Heightmatching - No bodytype found on entity")
--         end
--     elseif type == "BS" then
--         if bs then
--             return bs
--         else
--             return Debug.Print("Heightmatching - No bodyshape found on entity")
--         end
--     elseif type == "G" then
--         if g then
--             return g
--         else
--             return Debug.Print("Heightmatching - No genital found on entity")
--         end
--     else
--         return Debug.Print("Heightmatching - Asking for unknown type")
--     end
-- end


--- Retrieves the appropriate animations for a given body type pairing or solo entry.
-- If both entity and entity2 are provided, it returns the top and bottom animations for that specific pair.
-- The function checks for multiple levels of specificity: the exact body type pairing, then general gender pairing, and finally general body shape pairing.
-- If only entity is provided, it returns the solo animation for that body type.
-- If the specific pair or solo entry does not exist, it defaults to the provided fallback animations.
---@param entity string - UUID of the first entity.
---@param entity2 string|nil - (Optional) The UUID of the second entity. If nil, this retrieves the solo animation for entity.
---@return string, string - Returns the top and bottom animations if both entities are provided, or the solo animation if only the first entity is provided.
function Heightmatching:GetAnimation(entity, entity2)
    local bs1, bt1, g1 = Heightmatching:GetEntityBody(entity)
    local eB1 = bs1 .. bt1 .. g1

    if entity2 then
        -- Get body type, shape, and genital for entity2
        local bs2, bt2, g2 = Heightmatching:GetEntityBody(entity2)
        local eB2 = bs2 .. bt2 .. g2

        -- 1. Exact match for both entities (BS + BT + G)
        if self.matchingTable[eB1] and self.matchingTable[eB1][eB2] then
            return self.matchingTable[eB1][eB2].Top, self.matchingTable[eB1][eB2].Bottom
        
        -- 2. Entity1: Full match (BS + BT + G), Entity2: Match by BS
        elseif self.matchingTable[eB1] and self.matchingTable[eB1][bs2] then
            return self.matchingTable[eB1][bs2].Top, self.matchingTable[eB1][bs2].Bottom
        
        -- 3. Entity1: Full match (BS + BT + G), Entity2: Match by BT + G
        elseif self.matchingTable[eB1] and self.matchingTable[eB1][bt2 .. g2] then
            return self.matchingTable[eB1][bt2 .. g2].Top, self.matchingTable[eB1][bt2 .. g2].Bottom
        
        -- 4. Entity1: Full match (BS + BT + G), Entity2: Match by BS + BT
        elseif self.matchingTable[eB1] and self.matchingTable[eB1][bs2 .. bt2] then
            return self.matchingTable[eB1][bs2 .. bt2].Top, self.matchingTable[eB1][bs2 .. bt2].Bottom
        
        -- 5. Entity1: Full match (BS + BT + G), Entity2: Match by BT
        elseif self.matchingTable[eB1] and self.matchingTable[eB1][bt2] then
            return self.matchingTable[eB1][bt2].Top, self.matchingTable[eB1][bt2].Bottom
        
        -- 6. Entity1: Full match (BS + BT + G), Entity2: Match by G
        elseif self.matchingTable[eB1] and self.matchingTable[eB1][g2] then
            return self.matchingTable[eB1][g2].Top, self.matchingTable[eB1][g2].Bottom
        
        -- 7. Entity1: Match by BS + BT, Entity2: Full match (BS + BT + G)
        elseif self.matchingTable[bs1 .. bt1] and self.matchingTable[bs1 .. bt1][eB2] then
            return self.matchingTable[bs1 .. bt1][eB2].Top, self.matchingTable[bs1 .. bt1][eB2].Bottom
        
        -- 8. Entity1: Match by BS + BT, Entity2: Match by BS + BT
        elseif self.matchingTable[bs1 .. bt1] and self.matchingTable[bs1 .. bt1][bs2 .. bt2] then
            return self.matchingTable[bs1 .. bt1][bs2 .. bt2].Top, self.matchingTable[bs1 .. bt1][bs2 .. bt2].Bottom
        
        -- 9. Entity1: Match by BS + G, Entity2: Full match (BS + BT + G)
        elseif self.matchingTable[bs1 .. g1] and self.matchingTable[bs1 .. g1][eB2] then
            return self.matchingTable[bs1 .. g1][eB2].Top, self.matchingTable[bs1 .. g1][eB2].Bottom
        
        -- 10. Entity1: Match by BS + G, Entity2: Match by BS + BT
        elseif self.matchingTable[bs1 .. g1] and self.matchingTable[bs1 .. g1][bs2 .. bt2] then
            return self.matchingTable[bs1 .. g1][bs2 .. bt2].Top, self.matchingTable[bs1 .. g1][bs2 .. bt2].Bottom
        
        -- 11. Entity1: Match by BT + G, Entity2: Full match (BS + BT + G)
        elseif self.matchingTable[bt1 .. g1] and self.matchingTable[bt1 .. g1][eB2] then
            return self.matchingTable[bt1 .. g1][eB2].Top, self.matchingTable[bt1 .. g1][eB2].Bottom
        
        -- 12. Entity1: Match by BT + G, Entity2: Match by BS + BT
        elseif self.matchingTable[bt1 .. g1] and self.matchingTable[bt1 .. g1][bs2 .. bt2] then
            return self.matchingTable[bt1 .. g1][bs2 .. bt2].Top, self.matchingTable[bt1 .. g1][bs2 .. bt2].Bottom
        
        -- 13. Entity1: Match by BT, Entity2: Full match (BS + BT + G)
        elseif self.matchingTable[bt1] and self.matchingTable[bt1][eB2] then
            return self.matchingTable[bt1][eB2].Top, self.matchingTable[bt1][eB2].Bottom
        
        -- 14. Entity1: Match by BT, Entity2: Match by BS + BT
        elseif self.matchingTable[bt1] and self.matchingTable[bt1][bs2 .. bt2] then
            return self.matchingTable[bt1][bs2 .. bt2].Top, self.matchingTable[bt1][bs2 .. bt2].Bottom
        
        -- 15. Entity1: Match by BS, Entity2: Full match (BS + BT + G)
        elseif self.matchingTable[bs1] and self.matchingTable[bs1][eB2] then
            return self.matchingTable[bs1][eB2].Top, self.matchingTable[bs1][eB2].Bottom
        
        -- 16. Entity1: Match by BS, Entity2: Match by BS + BT
        elseif self.matchingTable[bs1] and self.matchingTable[bs1][bs2 .. bt2] then
            return self.matchingTable[bs1][bs2 .. bt2].Top, self.matchingTable[bs1][bs2 .. bt2].Bottom
        
        -- 17. Entity1: Match by BS, Entity2: Match by BS
        elseif self.matchingTable[bs1] and self.matchingTable[bs1][bs2] then
            return self.matchingTable[bs1][bs2].Top, self.matchingTable[bs1][bs2].Bottom
    end

    -- Fallback logic for no entity2 (Solo Entry for Entity 1)
    -- 1. Check for Entity1's full combinations: BS + BT + G, BS + BT, BS, BT, G
    if self.matchingTable[eB1] then
        return self.matchingTable[eB1].Top, self.matchingTable[eB1].Bottom
    end
    -- 2. Check for Entity1's partial matches: BS + BT, BS + G, BT + G, etc.
    -- (Similar structure like the above cases for entity1's fallback checks)
end


-- Heightmatching:new, basically creates a table somewhat like this
-- Technically the table structure is completely empty and always defaults to the fallbackTop/Bottom if we didn't manually create a match with :SetAnimation
----------------------------------------------------------------
-- instance.matchingTable = {
--     TallM = {
--         TallM = { Top = "fallbackTop", Bottom = "fallbackBottom" },
--         TallF = { Top = "fallbackTop", Bottom = "fallbackBottom" },
--         MedM  = { Top = "fallbackTop", Bottom = "fallbackBottom" },
--         MedF  = { Top = "fallbackTop", Bottom = "fallbackBottom" },
--         SmallM = { Top = "fallbackTop", Bottom = "fallbackBottom" },
--         SmallF = { Top = "fallbackTop", Bottom = "fallbackBottom" },
--         TinyM = { Top = "fallbackTop", Bottom = "fallbackBottom" },
--         TinyF = { Top = "fallbackTop", Bottom = "fallbackBottom" },
--         Solo = "fallbackTop"
--     },
--     Tall = {
--         Tall = { Top = "fallbackTop", Bottom = "fallbackBottom" },
--         Med  = { Top = "fallbackTop", Bottom = "fallbackBottom" },
--         Small = { Top = "fallbackTop", Bottom = "fallbackBottom" },
--         Tiny = { Top = "fallbackTop", Bottom = "fallbackBottom" },
--         Solo = "fallbackTop"
--     },
--     M = {
--         M = { Top = "fallbackTop", Bottom = "fallbackBottom" },
--         F = { Top = "fallbackTop", Bottom = "fallbackBottom" },
--         Solo = "fallbackTop"
--     },
--     -- Etc.
--     -- Repeats for every bodytype, agnostictype and gender
--     -- Can create dynamic new combinations by using :SetAnimation and using parameter 1 or 2 with previously non-existent entry names
-- }