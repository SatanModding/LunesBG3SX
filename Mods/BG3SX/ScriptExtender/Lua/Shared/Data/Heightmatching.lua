---@class Heightmatching
---@field New fun(self:Heightmatching, moduleUUID:string, animName:string, fallbackTop:string, fallbackBottom:string|nil):Heightmatching
---@field SetAnimation fun(self:Heightmatching, bodyType1:string, bodyType2:string|nil, topAnimation:string, bottomAnimation:string|nil))
---@field NewGetAnimation fun(self:Heightmatching, character1:string, character2:string|nil):string, string
---@field GetInstanceByAnimName fun(moduleUUID:string, animName:string):Heightmatching
---@field GetEntityBody fun(uuid:string):string, string, string
---@field GetEntityBodyUnlocked fun(uuid:string):string, string
---@field BodyShapeOverrides table<string, number>
---@field matchingTable table<string, table<string, table<string, string>>>
---@field fallbackTop string
---@field fallbackBottom string|nil
Heightmatching = {}
Heightmatching.__index = Heightmatching
HeightmatchingInstances = {} -- Don't create it as Heightmatching.Instance so we don't replicate all instances for every instance:new()

---Retrieves a Heightmatching instance by its animation name.
---@param animName string - The animation name used as the unique identifier for the instance.
---@return table|nil - The Heightmatching instance if found, or nil if not found.
function Heightmatching.GetInstanceByAnimName(moduleUUID, animName)
    return HeightmatchingInstances[moduleUUID][animName]
end

------------------------------------------------------------------------------

--- Creates a new `Heightmatching` instance with initialized entries.
-- Initializes all possible body type combinations and gender-agnostic types.
-- Also sets up mixed-match entries based on body types, genders, agnostic types and modded ones in Heightmatching.Keys.
---@param animName string The name of the animation instance.
---@param fallbackTop string The default animation identifier for the top part.
---@param fallbackBottom string|nil The default animation identifier for the bottom part. If `nil`, no default is set.
---@return Heightmatching The newly created `Heightmatching` instance.
function Heightmatching:New(moduleUUID, animName, fallbackTop, fallbackBottom) -- TODO: Add possibility of inserting a table of possible additional fallbacks as 4th parameter which may get chosen randomly
    -- print("AnimationName ", animName)
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
-- 0 is Med - 1 is Strong - 2 is Small - 3 is Tiny
Heightmatching.BodyShapeOverrides = {
    -- Vanilla Overrides by BG3SX
    ["02e5e9ed-b6b2-4524-99cd-cb2bc84c754a"] = 1,   -- Dragonborn Strong -- May need to remove this tag if someone ever does medium Dragonborn or Orcs
    ["3311a9a9-cdbc-4b05-9bf6-e02ba1fc72a3"] = 1,   -- Half-Orc Strong
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
---@return string, string, string - A concatenated string representing the body shape and body type (e.g., "StrongM", "MedF").
function Heightmatching.GetEntityBody(uuid)
    --print("Heightmatching  for " , uuid )

    -- print("getting body type LOCKED")

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

    -- print("HEINGHTMATCHING")
    -- print(uuid, " has the body  bt = ", bt, " bs = ", bs , " g = ", g)
    return bs, bt, g  -- StrongM_P, MedF_V, etc.
end

function Heightmatching.GetEntityBodyUnlocked(uuid)
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

    -- print("HEINGHTMATCHING")
    -- print(uuid, " has the body  bt = ", bt, " bs = ", bs )
    return bs, bt  -- StrongM_P, MedF_V, etc.
end

-- Had an issue where the wanking anim prioritized "Strong_V" over "_P" for "Strong_P"
-- trying to give genital matches high scores
-- Custom scoring function
local function custom_score(char1, char2)
    if (char1 == "P" and char2 == "P") or  (char1 == "V" and char2 == "V") then -- (char1 == "_" and char2 == "_") or 
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
    {score = 1, str = "StrongM_P"},
    {score = 2, str = "StrongF_P"}
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
-- gortash might have been considered Strong with shart?
function Heightmatching:NewGetAnimation(character1, character2, unlocked)
    local matchingTable = self.matchingTable

    if Table.TableSize(matchingTable) == 0 then
      return self.fallbackTop, self.fallbackBottom
    end

    -- === Construct first body ===
    local bs,bt,g = 0,0,"__"
    if unlocked then
        -- print("is unlocked true ", unlocked)
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

    -- === If no second entity, get solo animation ===
    if not character2 or Helper.StringContainsOne(character1, character2) then
        print("BEST MATCH IS " .. bestHMEntityOne .. " with animation " , matchingTable[bestHMEntityOne].Solo)
        return matchingTable[bestHMEntityOne].Solo
    else
        -- print("BEST MATCH IS " .. bestHMEntityOne .. " with the animations ")
        -- _D(matchingTable[bestHMEntityOne])
    end

    -- === 2 Entities ===
    -- === Construct second body ===
    local bs2,bt2,g2 = 0,0, "__"
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