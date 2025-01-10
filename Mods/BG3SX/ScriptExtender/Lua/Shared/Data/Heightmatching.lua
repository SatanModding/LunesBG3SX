Heightmatching = {}
Heightmatching.__index = Heightmatching
HeightmatchingInstances = {} -- Don't create it as Heightmatching.Instance so we don't replicate all instances for every instance:new()

-- TODO: Move some table functions over to Table.

---Retrieves a Heightmatching instance by its animation name.
---@param animName string - The animation name used as the unique identifier for the instance.
---@return table|nil - The Heightmatching instance if found, or nil if not found.
function Heightmatching.GetInstanceByAnimName(moduleUUID, animName)
    return HeightmatchingInstances[moduleUUID][animName]
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
function Heightmatching:New(moduleUUID, animName, fallbackTop, fallbackBottom) -- TODO: Add possibility of inserting a table of possible additional fallbacks as 4th parameter which may get chosen randomly
    local instance = setmetatable({}, self)
    instance.fallbackTop = fallbackTop
    instance.fallbackBottom = fallbackBottom or nil
    instance.matchingTable = {}

    -- instance:initializeTable() -- This was used to pre-create the table structure based on all the code above which we now do dynamically

    if not HeightmatchingInstances[moduleUUID] then
        HeightmatchingInstances[moduleUUID] = {}
    end
    HeightmatchingInstances[moduleUUID][animName] = instance
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
    bodyType2 = bodyType2 or nil
    bottomAnimation = bottomAnimation or nil
    if not bodyType2 then
        if bottomAnimation then
            --Debug.Print("Error while setting up a heightmatching entry - A bottomAnimation was added without an identifier for a second entities bodytype")
        end
    end
    if bodyType2 then
        if not bottomAnimation then
            --Debug.Print("Error while setting up a heightmatching entry - A second entity bodytype identifier was added but no corresponding bottomAnimation")
        end
    end
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
    -- Vanilla Overrides by BG3SX
    ["02e5e9ed-b6b2-4524-99cd-cb2bc84c754a"] = 1,   -- Dragonborn Tall -- May need to remove this tag if someone ever does medium Dragonborn or Orcs
    ["3311a9a9-cdbc-4b05-9bf6-e02ba1fc72a3"] = 1,   -- Half-Orc Tall
    ["486a2562-31ae-437b-bf63-30393e18cbdd"] = 2,   -- Dwarf Small
    ["1f0551f3-d769-47a9-b02b-5d3a8c51978c"] = 3,   -- Gnome Tiny
    ["b99b6a5d-8445-44e4-ac58-81b2ee88aab1"] = 3,   -- Halfling Tiny
    -- Modded
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
        if Table.Contains(raceTags, tag) then
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
---@return string, string, string - A concatenated string representing the body shape and body type (e.g., "TallM", "MedF").
function Heightmatching.GetEntityBody(uuid)

    --print("Heightmatching  for " , uuid )

    print("getting body type LOCKED")

    local entity = Ext.Entity.Get(uuid)
    local raceTags = Entity:TryGetEntityValue(uuid, nil, {"ServerRaceTag", "Tags"})
    local bs = 0 -- Default Medium bodyShape
    local bt = entity.BodyType.BodyType
    local g
    
    if Entity:IsNPC(uuid) == false then
        if Entity:HasPenis(uuid) then
            g = "_P" -- Penis
        else
            g = "_V" -- Vulva
        end
        bs = entity.CharacterCreationStats.BodyShape
    end

    -- Apply body shape overrides based on race tags
    local bsOverride = bodyShapeOverrides(raceTags)
    if bsOverride ~= nil then
        bs = bsOverride
    end

    -- Translate to Human-readable
    bs = Data.BodyLibrary.BodyShape[bs]
    bt = Data.BodyLibrary.BodyType[bt]

    --Debug.Print("bt = ".. bt.. " bs = ".. bs .. " g = " .. g )

    -- Performs a check on the entity if its an NPC and either gets its current UserVars or sets the genital to a default 
    if Entity:IsNPC(uuid) then
        local vulva = "a0738fdf-ca0c-446f-a11d-6211ecac3291"
        local genital = SexUserVars.GetGenital("BG3SX_OutOfSexGenital", entity)
        
        if genital then
        -- genital has been set once before (for example by user)
            local genitalTags =  Ext.StaticData.Get(genital, "CharacterCreationAppearanceVisual").Tags
            if Table.Contains(genitalTags, vulva) then
                g = "_V"
            else
                g = "_P"
            end
        else
            -- genital has not been assigned, assume penises for all masc bodytypes
            if bt == "M" then
                g = "_P"
            else
                g = "_V"
            end
        end
    end

    print("HEINGHTMATCHING")
    print(uuid, " has the body  bt = ", bt, " bs = ", bs , " g = ", g)
    return bs, bt, g  -- TallM_P, MedF_V, etc.
end


function Heightmatching.GetEntityBodyUnlocked(uuid)

    print("Getting bodytype UNLOCKED")

    --print("Heightmatching for " , uuid )

    local entity = Ext.Entity.Get(uuid)
    local raceTags = Entity:TryGetEntityValue(uuid, nil, {"ServerRaceTag", "Tags"})
    local bs = 0 -- Default Medium bodyShape
    local bt = entity.BodyType.BodyType

    
    if Entity:IsNPC(uuid) == false then
        bs = entity.CharacterCreationStats.BodyShape
    end

    -- Apply body shape overrides based on race tags
    local bsOverride = bodyShapeOverrides(raceTags)
    if bsOverride ~= nil then
        bs = bsOverride
    end

    -- Translate to Human-readable
    bs = Data.BodyLibrary.BodyShape[bs]
    bt = Data.BodyLibrary.BodyType[bt]

    --Debug.Print("bt = ".. bt.. " bs = ".. bs .. " g = " .. g )

    print("HEINGHTMATCHING")
    print(uuid, " has the body  bt = ", bt, " bs = ", bs )
    return bs, bt  -- TallM_P, MedF_V, etc.
end




--- Retrieves the appropriate animations for a given body type pairing or solo entry.
-- If both entity and entity2 are provided, it returns the top and bottom animations for that specific pair.
-- The function checks for multiple levels of specificity: the exact bodyshape pairing, then general gender pairing, and finally general body shape pairing.
-- If only entity is provided, it returns the solo animation for that body type.
-- If the specific pair or solo entry does not exist, it defaults to the provided fallback animations.
---@param entity string - UUID of the first entity.
---@param entity2 string|nil - (Optional) The UUID of the second entity. If nil, this retrieves the solo animation for entity.
---@return string, string - Returns the top and bottom animations if both entities are provided, or the solo animation if only the first entity is provided.
-- function Heightmatching:GetAnimation(entity, entity2)

--     local entity2 = entity2 or nil
--     local bs1, bt1, g1 = Heightmatching_GetEntityBody(entity)
--     local eB1 = bs1 .. bt1 .. g1
--     Debug.Print("Entity 1 Body: " .. eB1)

--     if entity2 then
--         Debug.Print("Entity 2 found for Heightmatching")
--         -- Get body type, shape, and genital for entity2
--         local bs2, bt2, g2 = Heightmatching_GetEntityBody(entity2)
--         local eB2 = bs2 .. bt2 .. g2
--         Debug.Print("Entity 2 Body: " .. eB2)

--         -- 1. Exact match for both entities (BS + BT + G)
--         if self.matchingTable[eB1] and self.matchingTable[eB1][eB2] then
--             local match = self.matchingTable[eB1][eB2]
--             Debug.Dump(match)
--             return match.Top, match.Bottom
        
--         -- 1.1 Former Common Match Type: TallM + MedF - Relied on Genital so we prioritize Tall_P + Med_V now
--         elseif self.matchingTable[bs1..g1] and self.matchingTable[bs1..bt1][bs2..g2] then
--             local match = self.matchingTable[bs1..bt1][bs2..g2]
--             Debug.Dump(match)
--             return match.Top, match.Bottom

--         -- 1.2 Former Common Match Type: Tall + Med
--         elseif self.matchingTable[bs1] and self.matchingTable[bs1][bs2] then
--             local match = self.matchingTable[bs1][bs2]
--             Debug.Dump(match)
--             return match.Top, match.Bottom

--         -- 1.3 Former Common Match Type: M + F - Relied on Genital so we prioritize _P + _V
--         elseif self.matchingTable[g1] and self.matchingTable[g1][g2] then
--             local match = self.matchingTable[g1][g2]
--             Debug.Dump(match)
--             return match.Top, match.Bottom

--         -- 2. Entity1: Full match (BS + BT + G), Entity2: Match by BS
--         elseif self.matchingTable[eB1] and self.matchingTable[eB1][bs2] then
--             return self.matchingTable[eB1][bs2].Top, self.matchingTable[eB1][bs2].Bottom
        
--         -- 3. Entity1: Full match (BS + BT + G), Entity2: Match by BT + G
--         elseif self.matchingTable[eB1] and self.matchingTable[eB1][bt2 .. g2] then
--             return self.matchingTable[eB1][bt2 .. g2].Top, self.matchingTable[eB1][bt2 .. g2].Bottom
        
--         -- 4. Entity1: Full match (BS + BT + G), Entity2: Match by BS + BT
--         elseif self.matchingTable[eB1] and self.matchingTable[eB1][bs2 .. bt2] then
--             return self.matchingTable[eB1][bs2 .. bt2].Top, self.matchingTable[eB1][bs2 .. bt2].Bottom
        
--         -- 5. Entity1: Full match (BS + BT + G), Entity2: Match by BT
--         elseif self.matchingTable[eB1] and self.matchingTable[eB1][bt2] then
--             return self.matchingTable[eB1][bt2].Top, self.matchingTable[eB1][bt2].Bottom
        
--         -- 6. Entity1: Full match (BS + BT + G), Entity2: Match by G
--         elseif self.matchingTable[eB1] and self.matchingTable[eB1][g2] then
--             return self.matchingTable[eB1][g2].Top, self.matchingTable[eB1][g2].Bottom
        
--         -- 7. Entity1: Match by BS + BT, Entity2: Full match (BS + BT + G)
--         elseif self.matchingTable[bs1 .. bt1] and self.matchingTable[bs1 .. bt1][eB2] then
--             return self.matchingTable[bs1 .. bt1][eB2].Top, self.matchingTable[bs1 .. bt1][eB2].Bottom
        
--         -- 8. Entity1: Match by BS + BT, Entity2: Match by BS + BT
--         elseif self.matchingTable[bs1 .. bt1] and self.matchingTable[bs1 .. bt1][bs2 .. bt2] then
--             return self.matchingTable[bs1 .. bt1][bs2 .. bt2].Top, self.matchingTable[bs1 .. bt1][bs2 .. bt2].Bottom
        
--         -- 9. Entity1: Match by BS + G, Entity2: Full match (BS + BT + G)
--         elseif self.matchingTable[bs1 .. g1] and self.matchingTable[bs1 .. g1][eB2] then
--             return self.matchingTable[bs1 .. g1][eB2].Top, self.matchingTable[bs1 .. g1][eB2].Bottom
        
--         -- 10. Entity1: Match by BS + G, Entity2: Match by BS + BT
--         elseif self.matchingTable[bs1 .. g1] and self.matchingTable[bs1 .. g1][bs2 .. bt2] then
--             return self.matchingTable[bs1 .. g1][bs2 .. bt2].Top, self.matchingTable[bs1 .. g1][bs2 .. bt2].Bottom
        
--         -- 11. Entity1: Match by BT + G, Entity2: Full match (BS + BT + G)
--         elseif self.matchingTable[bt1 .. g1] and self.matchingTable[bt1 .. g1][eB2] then
--             return self.matchingTable[bt1 .. g1][eB2].Top, self.matchingTable[bt1 .. g1][eB2].Bottom
        
--         -- 12. Entity1: Match by BT + G, Entity2: Match by BS + BT
--         elseif self.matchingTable[bt1 .. g1] and self.matchingTable[bt1 .. g1][bs2 .. bt2] then
--             return self.matchingTable[bt1 .. g1][bs2 .. bt2].Top, self.matchingTable[bt1 .. g1][bs2 .. bt2].Bottom
        
--         -- 13. Entity1: Match by BT, Entity2: Full match (BS + BT + G)
--         elseif self.matchingTable[bt1] and self.matchingTable[bt1][eB2] then
--             return self.matchingTable[bt1][eB2].Top, self.matchingTable[bt1][eB2].Bottom
        
--         -- 14. Entity1: Match by BT, Entity2: Match by BS + BT
--         elseif self.matchingTable[bt1] and self.matchingTable[bt1][bs2 .. bt2] then
--             return self.matchingTable[bt1][bs2 .. bt2].Top, self.matchingTable[bt1][bs2 .. bt2].Bottom
        
--         -- 15. Entity1: Match by BS, Entity2: Full match (BS + BT + G)
--         elseif self.matchingTable[bs1] and self.matchingTable[bs1][eB2] then
--             return self.matchingTable[bs1][eB2].Top, self.matchingTable[bs1][eB2].Bottom
        
--         -- 16. Entity1: Match by BS, Entity2: Match by BS + BT
--         elseif self.matchingTable[bs1] and self.matchingTable[bs1][bs2 .. bt2] then
--             return self.matchingTable[bs1][bs2 .. bt2].Top, self.matchingTable[bs1][bs2 .. bt2].Bottom
        
--         -- 17. Entity1: Match by BS, Entity2: Match by BS
--         elseif self.matchingTable[bs1] and self.matchingTable[bs1][bs2] then
--             return self.matchingTable[bs1][bs2].Top, self.matchingTable[bs1][bs2].Bottom
--         end
--     else
    
--         --Debug.Print("Only one entity in scene")
--         local mt = self.matchingTable
--         --Debug.Dump(mt)
--         return mt[eB1] and mt[eB1].Solo or -- Return Solo Animation for fullbody match TallM_P
--         mt[bs1..g1] and mt[bs1..g1].Solo or -- Return Solo Animation for BodyShape+Genital match Tall_P or Med_V
--         mt[g1] and mt[g1].Solo or -- Return Solo Animation for Genital match _P or _V
--         mt[bs1] and mt[bs1].Solo or -- Return Solo Animation for BodyShape(Height) match Tall or Med
--         self.fallbackTop
--     end
-- end


-- Heightmatching:new, basically creates a table somewhat like this
-- Technically the table structure is completely empty and always defaults to the fallbackTop/Bottom if we didn't manually create a match with :SetAnimation
----------------------------------------------------------------
-- instance.matchingTable = {
--     TallM_P = {
--         TallM = { Top = "fallbackTop", Bottom = "fallbackBottom" },
--         TallF_P = { Top = "fallbackTop", Bottom = "fallbackBottom" },
--         MedM  = { Top = "fallbackTop", Bottom = "fallbackBottom" },
--         MedF  = { Top = "fallbackTop", Bottom = "fallbackBottom" },
--         SmallM_V = { Top = "fallbackTop", Bottom = "fallbackBottom" },
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


-- TODO - test with other functions and see if values need to be tweaked

-- Had an issue where the wanking anim prioritized "Tall_V" over "_P" for "Tall_P"
-- trying to give genital matches high scores
-- Custom scoring function
local function custom_score(char1, char2)

    if char1 == "_" and char2 == "_" or char1 == "P" and char2 == "P" or  char1 == "V" and char2 == "V" then
        return 100000 -- Prioritize matching "_" with "P" or "V"
        -- ridiculously high score for testing
    elseif char1 == char2 then
        return 1 -- High score for match
    else
        return -2 -- Penalty for mismatches
    end
end


--- Performs global sequence alignment using the Needleman-Wunsch algorithm.
-- Aligns two sequences, `str1` and `str2`, using dynamic programming to calculate the optimal
-- alignment by considering matches, mismatches, and gaps. It returns the aligned sequences
-- and the final alignment score.
---@param str1 string The first sequence to align.
---@param str2 string The second sequence to align.
---@return string The first aligned sequence.
---@return string The second aligned sequence.
---@return number The final alignment score, calculated based on match, mismatch, and gap penalties.
function Helper.NeedlemanWunsch(str1, str2)

    local gp = -1 -- Small gap penalty since we want to prioritize matching certain characters (for example the last2).
    local m, n = #str1, #str2
    -- Initialize score matrix
    local score = {}
    for i = 0, m do
        score[i] = {}
        score[i][0] = i * gp -- Gap penalty for first column
    end
    for j = 0, n do
        score[0][j] = j * gp -- Gap penalty for first row
    end

  -- Fill in the score matrix
    for i = 1, m do
        for j = 1, n do
            local char1, char2 = str1:sub(i, i), str2:sub(j, j)
            local match = score[i-1][j-1] + custom_score(char1, char2)
            local delete = score[i-1][j] + gp
            local insert = score[i][j-1] + gp

            -- Determine the winning operation
            if match >= delete and match >= insert then
                score[i][j] = match
            elseif delete >= insert then
                score[i][j] = delete
            else
                score[i][j] = insert
            end
        end
    end



    -- Traceback to determine the alignment
    local aligned1, aligned2 = "", ""
    local i, j = m, n
    while i > 0 or j > 0 do
        local current = score[i][j]
        if i > 0 and j > 0 and current == score[i-1][j-1] + custom_score(str1:sub(i, i), str2:sub(j, j)) then
            aligned1 = str1:sub(i, i) .. aligned1
            aligned2 = str2:sub(j, j) .. aligned2
            i, j = i - 1, j - 1
        elseif i > 0 and current == score[i-1][j] + gp then
            aligned1 = str1:sub(i, i) .. aligned1
            aligned2 = "-" .. aligned2
            i = i - 1
        else
            aligned1 = "-" .. aligned1
            aligned2 = str2:sub(j, j) .. aligned2
            j = j - 1
        end
    end

    return aligned1, aligned2, score[m][n]
end




-- compares all scores and returns the string of the highest
---@param scores table
---@return string
--[[
scores is a table that contains the scores and the corresponding string
example:  
myScores = {
    {score = 1, str = "TallM_P"},
    {score = 2, str = "TallF_P"}
}
]]--
local function getBestValueOfAllScores(scores)

    local bestScore = -math.huge
    local bestString = "NO MATCH FOUND"

    for _, entry in pairs(scores) do

        -- Debug thingy
        if entry.score == bestScore then
            Debug.Print("The same score was found for ".. entry.str .. " and " .. bestString)
            Debug.Print("Please check your files")

        elseif entry.score > bestScore then
            bestScore = entry.score
            bestString = entry.str
        end

    end


    return bestString
end

-- TODO - test if the "unlocked" works
-- TODO - check if this correctly assigns NPC bodytype.
-- gortash might have been considered tall with shart?
function Heightmatching:NewGetAnimation(character1, character2, unlocked)

    print("Heightmatching for ", character1, "and ", character2, "unlocked: ", unlocked)

    local matchingTable = self.matchingTable

    --print("Dumping matchingtable ")

    --_D(matchingTable)

    if Table.TableSize(matchingTable) == 0 then
      return self.fallbackTop, self.fallbackBottom
    end

    bs,bt,g = 0,0, "__" 
    if unlocked then
        print("is unlocked true ", unlocked)
        bs, bt = Heightmatching.GetEntityBodyUnlocked(character1)
    else
        bs, bt, g = Heightmatching.GetEntityBody(character1)
    end

    local body = bs..bt..g

    local scoresEntityOne = {}
    
    for bodyIdentifier1,_ in pairs(matchingTable) do
        local aligned1, aligned2, score = Helper.NeedlemanWunsch(body, bodyIdentifier1)
        table.insert(scoresEntityOne, {score = score, str = bodyIdentifier1})
    end
    local bestHMEntityOne = getBestValueOfAllScores(scoresEntityOne)


    -- if Masturbation
    if not character2 then
        print("BEST MATCH IS " .. bestHMEntityOne .. " with animation " , matchingTable[bestHMEntityOne].Solo)
        return matchingTable[bestHMEntityOne].Solo
    else
        print("BEST MATCH IS " .. bestHMEntityOne .. " with the animations ")
        _D(matchingTable[bestHMEntityOne])
    end

    -- if Sex
    bs2,bt2,g2 = 0,0, "__" 
    if unlocked then
        bs2, bt2 = Heightmatching.GetEntityBodyUnlocked(character2)
    else
        bs2, bt2, g = Heightmatching.GetEntityBody(character2)
    end

    local body2 = bs2..bt2..g2

    local secondEntityTable = matchingTable[bestHMEntityOne]
    local scoresEntityTwo = {}
    for bodyIdentifier2,_ in pairs(secondEntityTable) do
        local _, _, score = Helper.NeedlemanWunsch(body2, bodyIdentifier2)
        table.insert(scoresEntityTwo, {score = score, str = bodyIdentifier2})
    end

    local bestHMEntityTwo = getBestValueOfAllScores(scoresEntityTwo)
    print("BEST MATCH IS " .. bestHMEntityTwo .. " with animation " , matchingTable[bestHMEntityOne][bestHMEntityTwo].Bottom)

    local animationSet = matchingTable[bestHMEntityOne][bestHMEntityTwo]

    return animationSet.Top, animationSet.Bottom
    
end




