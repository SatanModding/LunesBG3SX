----------------------------------------------------------------------------------------
--
--                               For handling Helpers
--
----------------------------------------------------------------------------------------

-- CONSTRUCTOR
--------------------------------------------------------------


-- Options
--------------------------------------------------------------

-- Options for stringifying
STRINGIFY_OPTIONS = {
    StringifyInternalTypes = true,
    IterateUserdata = true,
    AvoidRecursion = true
    }

-- METHODS
--------------------------------------------------------------

-- TODO: Check if that even works
-- Generates a new UUID
function Helper.GenerateUUID()
    local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    return string.gsub(template, '[xy]', function (c)
        local v = (c == 'x') and math.random(0, 0xf) or math.random(8, 0xb)
        return string.format('%x', v)
    end)
end


-- Checks if a number is even
---@param n int - The number to check
---@example
-- for i = 1, 10 do
--    if isEven(i) then
--        _P(i .. " is even")
--    else
--        _P(i .. " is odd")
--    end
-- end
function Helper.isEven(n)
    return n % 2 == 0
end


-- Checks if a number is odd
---@param n int - The number to check
function Helper.isOdd(n)
    return n % 2 ~= 0
end


--Credit: Yoinked from Morbyte (Norbyte?)
-- TODO: Description
---@param srcObject any
---@param dstObject any
function Helper.TryToReserializeObject(srcObject, dstObject)
    local serializer = function()
        local serialized = Ext.Types.Serialize(srcObject)
        Ext.Types.Unserialize(dstObject, serialized)
    end
    local ok, err = xpcall(serializer, debug.traceback)
    if not ok then
        return err
    end
    return nil
end


-- Function to clean the prefix and return only the ID
---@return string   - UUID
function Helper.CleanPrefix(fullString)
    -- Use pattern matching to extract the ID part
    local id = fullString:match(".*_(.*)")

    if not id then
        return fullString
    end
    return id
end


-- Function to check if not all values are false
function Helper.NotAllFalse(data)
    for _, value in pairs(data) do
        if value then
            return true
        end
    end
    return false
end


-- Checks if the substring 'sub' is present within the string 'str'.
---@param str string 	- The string to search within.
---@param sub string 	- The substring to look for.
---@return bool			- Returns true if 'sub' is found within 'str', otherwise returns false.
function Helper.StringContains(str, sub)
    -- Make the comparison case-insensitive
    str = str:lower()
    sub = sub:lower()
    return (string.find(str, sub, 1, true) ~= nil)
end

function Helper.ResetWhitelistToDefault()
end

-- Retrieves the value of a specified property from an object or returns a default value if the property doesn't exist.
---@param obj           - The object from which to retrieve the property value.
---@param propertyName  - The name of the property to retrieve.
---@param defaultValue  - The default value to return if the property is not found.
---@return any           - The value of the property if found; otherwise, the default value.
function Helper.GetPropertyOrDefault(obj, propertyName, defaultValue)
    local success, value = pcall(function() return obj[propertyName] end)
    if success then
        return value or defaultValue
    else
        return defaultValue
    end
end


-- Creates a helper object to later find a position with
---@param uuid  string  - The UUID to create a Marker for
---@return      entity  - The Marker entity (invisible, save with a new name or in a table to use)
function Helper.CreateLocationMarker(uuid)
    local Marker = {}
    Marker.x, Marker.y, Marker.z = Osi.GetPosition(uuid)
    -- returns GUIDstring
    Marker.obj = Osi.CreateAtObject("06f96d65-0ee5-4ed5-a30a-92a3bfe3f708", uuid, 1, 0, "", 1)
    return Marker
end


-- Destroys a marker
---@param marker    string  - The Marker UUID to destroy 
function Helper.DestroyMarker(marker)
    Osi.RequestDelete(marker) -- Check if we don't need Osi.RequestDeleteTemporary
end


-- Credit to FallenStar  https://github.com/FallenStar08/SharedCode
-- Slightly modified version
---@return goodies  - Table of all summons, avatars and Origins
function Helper.GetEveryoneThatIsRelevant()
    local goodies = {}
    local avatarsDB = Osi.DB_Avatars:Get(nil)
    local originsDB = Osi.DB_Origins:Get(nil)
    local summonsDB = Osi.DB_PlayerSummons:Get(nil)

    for _, avatar in pairs(avatarsDB) do
        goodies[#goodies + 1] = avatar[1]
    end

    for _, origin in pairs(originsDB) do
        goodies[#goodies + 1] = origin[1]
    end

    for _, summon in pairs(summonsDB) do
        goodies[#goodies + 1] = summon[1]
    end

    return goodies
end


-- Returns a table of all summons/followers
---@return PlayerSummons    - Table of player summons
function Helper.GetPlayerSummons()
    return Osi.DB_PlayerSummons:Get(nil)
end



function Helper.GetComponentValue(uuid, something, path)
    -- Redo Entity.TryGetEntityValue() maybe?
end


---@return EntityHandle|nil
function Helper.GetLocalControlledEntity()
    for _, entity in pairs(Ext.Entity.GetAllEntitiesWithComponent("ClientControl")) do
        if entity.UserReservedFor.UserID == 1 then
            return entity
        end
    end
end



-- By Aahz  https://next.nexusmods.com/profile/Aahz07?gameId=3474

---NetMessage user is actually peerid, convert using this
---@param p integer peerid
---@return integer userid
function Helper.PeerToUserID(p)
    -- all this for userid+1 usually smh
    return (p & 0xffff0000) | 0x0001
end

---Probably unreliable/unnecessary
---@param u integer userid
---@return integer peerid
function Helper.UserToPeerID(u)
    return (u & 0xffff0000)
end


-- local function blacklist()
--     Entity:IsBlacklistedEntity(Osi.GetHostCharacter())
-- end
-- Ext.RegisterConsoleCommand("racewhitelist", racewhitelist);




function pairsByKeys (t, f)
    local a = {}
    for n in pairs(t) do table.insert(a, n) end
        table.sort(a, f)
        local i = 0      -- iterator variable
        local iter = function ()   -- iterator function
        i = i + 1
        if a[i] == nil then
            return nil
        else
            return a[i], t[a[i]]
        end
    end
    return iter
end


---@By @Aahz - https://i.imgur.com/zfwND3b.gif
---Gets a table of entity uuid's for current party
---@return table<string>|nil
function Helper.GetCurrentParty()
    if Ext.IsServer() then
        local party = Osi.DB_PartyMembers:Get(nil)
        local partymembers = {}
        for k, v in pairs(party) do
            local g = Helper.Object:GetGuid(v[1])
            if g ~= nil then
                table.insert(partymembers, g)
            else
                -- don't count summons...?
                -- Debug.Print("Unable to get party member (%s), remember to delay slightly after party changes.", v[1])
            end
        end
        return partymembers
    else
        local party = Ext.Entity.GetAllEntitiesWithComponent("PartyMember")
        local partyMembers = {}
        for k,v in pairs(party) do
            local g = Helper.Object:GetGuid(v)
            if g ~= nil then
                table.insert(partyMembers, g)
            else
                Debug.Print("Can't get UUID for party member: %s", v)
            end
        end
        return partyMembers
    end
end


-- Takes a comma separated string and returns a table of the single entries
-- Example:  "Straight, Lesbian, Vaginal, Anal" returns
-- {"Straight","Lesbian","Vaginal","Anal"}
---@param str string
---@return table
function Helper.StringToTable(str)
    -- Create an empty table to store the results
    local result = {}

    -- Use a pattern to match each value between commas
    for entry in string.gmatch(str, "([^,]+)") do
        -- Trim leading and trailing spaces and insert into the result table
        table.insert(result, entry:match("^%s*(.-)%s*$"))
    end

    return result
end

function Helper.GetName(uuid)
    local translate = Ext.Loca.GetTranslatedString
    local entity = Ext.Entity.Get(uuid)
    local displayName

    if not entity then
        -- Debug.Print("No entity found on Server / No character template found on client")
        return "Name not Found"
    end

    if entity.CustomName and entity.CustomName.Name then -- PlayerCharacter Name
        return entity.CustomName.Name
    end

    if Ext.IsClient() then
        displayName = entity.ClientCharacter.Template.DisplayName

    elseif Ext.IsServer then
        displayName = entity.DisplayName.Name or entity.DisplayName.NameKey
    end

    if displayName then
        return translate(displayName.Handle.Handle) or translate(displayName.Handle.Handle)
    else
        return "No Name"
    end
 
end

function Helper.IsUUID(val)
    local uuid_pattern = "^[0-9a-fA-F]{8}%-[0-9a-fA-F]{4}%-[1-5][0-9a-fA-F]{3}%-[89abAB][0-9a-fA-F]{3}%-[0-9a-fA-F]{12}$"
    return type(val) == "string" and val:match(uuid_pattern) ~= nil
end
    

function Helper.GetAllClients()

    local clients = {}

    local partymembers = Ext.Entity.GetAllEntitiesWithComponent("PartyMember")

    for _, partymember in pairs(partymembers) do
        if Ext.Entity.Get(partymember).ClientControl then
            table.insert(clients, partymember)
        end
        
    end

    return clients
end




---@param func function
---@param delay number|nil
function Helper.OptionalDelay(func, delay)

    if not delay then
        func()
    else
        Ext.Timer.WaitFor(delay, function() 
            func()
        end)
    end
end

function Helper.SortWithPrio(tableToSort, prioTable)
    local keys = {}
    for key in pairs(tableToSort) do
        table.insert(keys, key)
    end

    table.sort(keys, function(a, b)
        local aInPriority = prioTable[a] or false
        local bInPriority = prioTable[b] or false
        
        if aInPriority and not bInPriority then
            return true
        end
        
        if not aInPriority and bInPriority then
            return false
        end
        
        return a < b
    end)

    local sortedTable = {}
    for _, key in ipairs(keys) do
        sortedTable[key] = tableToSort[key]
    end

    return sortedTable
end

function Helper.IsUpperCase(str)
    return str == string.upper(str)
end

function Helper.GetModInfo(moduleUUID)
    return Ext.Mod.GetMod(moduleUUID).Info
end
function Helper.GetModName(moduleUUID)
    return Ext.Mod.GetMod(moduleUUID).Info.Name
end
function Helper.GetModAuthor(moduleUUID)
    return Ext.Mod.GetMod(moduleUUID).Info.Author
end



function getControlledCharacter()

    if not Ext.IsClient() then
        Debug.Print("Cannot find controlled character on server")
    end



    local controlled = Ext.Entity.GetAllEntitiesWithComponent("ClientControl")
    
    for _,entity in pairs(controlled) do

            if entity.ClientCharacter and entity.ClientCharacter.OwnerUserID == 1 then
            return entity
            end

    end

    return nil
end

