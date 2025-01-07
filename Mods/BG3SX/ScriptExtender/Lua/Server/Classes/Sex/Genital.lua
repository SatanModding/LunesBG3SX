


----------------------------------------------------------------------------------------------------
-- 
-- 									Dynamic Genital Modification
-- 
----------------------------------------------------------------------------------------------------

-- CONSTRUCTOR
--------------------------------------------------------------

-- TODO - many functions are now in the visual class


-- Saved genitals for better performance
local allGenitals = {}
local allVanillaVulvas = {}
local allVanillaPenises = {}
local allFunErections = {}
local allAdditionalGenitals = {}

----------------------------------------------------------------------------------------------------
-- 
-- 												Retrieve Genitals
-- 
----------------------------------------------------------------------------------------------------

-- Get all CharacterCreationAppearaceVisuals of type Private Parts loaded in the game
---@return	table	- list of CharacterCreationAppearaceVisual IDs for all genitals
local function collectAllGenitals()
	return Visual.getAllVisualsOfType("Private Parts", "CharacterCreationAppearanceVisual")
end


-- Get all vanilla genitals of specific type
---@param TYPE	string	- Type of genital to get
---@param default	any	- TODO
---@return table		- Table of requested genitals
local function getVanillaGenitals(TYPE, default)
    local tableToSearch = (TYPE == "PENIS" and Data.BodyLibrary.PENIS) or (TYPE == "VULVA" and Data.BodyLibrary.VULVA)
    if not tableToSearch then
		_P("[BG3SX][Genital.lua] - getVanillaGenitals(TYPE, default) - Invalid type specified. Please use 'PENIS', 'VULVA'.")
        return {}
    end

    local result = {}
	for _, entry in ipairs(tableToSearch) do -- Collect all genitalIDs from the selected table
        if default and entry.name == "Default" then
            table.insert(result, entry.genitalID)
        elseif not default and entry.name ~= "Default" then
            table.insert(result, entry.genitalID)
        end
    end
    return result
end


-- Collect all available MrFunSize erections bundled with the mod
---@return table - Table of MrFunSize erections
local function collectFunErections()
    local result = {}
    for _, entry in ipairs(Data.BodyLibrary.FunErections) do -- Collect all genitalIDs from the selected table
        table.insert(result, entry.genitalID)
    end
    return result
end



-- Get Mod Specific Genitals
-- TODO - prpbably needs to be reworked. Check how vilitio filters by mod in uninstaller
-- Mostly unfinished for now - if Norbyte implements a way to get Mod ID from genitals it can be simplified a lot
---@param modName string	- ModName (FolderName)
---@return table		- Table of CharacterCreationAppearaceVisual IDs genitals
function Genital.getModGenitals(modName)
	local modGenitals = {}
    for _, genital in pairs(allGenitals) do -- Rens Aasimar contains a Vulva without a linked VisualResource which might cause problems since it outputs nil
        local visualResource = Ext.StaticData.Get(genital, "CharacterCreationAppearanceVisual").VisualResource
		local resource = Ext.Resource.Get(visualResource, "Visual") -- Visualbank
	    local sourceFile = Helper.GetPropertyOrDefault(resource, "SourceFile", nil)
		if sourceFile then 
			if Helper.StringContains(sourceFile, modName) then
				table.insert(modGenitals, genital)
			end
		end
    end

    -- Failsafe for CC
	local additionalGenitals = allAdditionalGenitals
	for _, genital in ipairs(additionalGenitals) do
		table.insert(modGenitals, genital)
	end
    return modGenitals
end


-- TODO: Check if this can be removed
-- Get Mod that genital belongs to
--@param  			- genital ID
---return 			- Name of Mod (Folder Name)

-- local function getModByGenital(genital)

-- 	local visualResource = Ext.StaticData.Get(genital,"CharacterCreationAppearanceVisual").VisualResource
-- 	local sourceFile = Ext.Resource.Get(visualResource,"Visual").SourceFile

-- 	-- Use string.match to capture the required part of the path
-- 	-- Pattern explanation:
-- 	-- [^/]+ captures one or more characters that are not a slash (greedily matching as much as possible).
-- 	-- The pattern captures the fourth folder from the end by skipping three sets of "anything followed by a slash" sequences.
-- 	local modName = string.match(sourceFile, ".-([^/]+)/[^/]+/[^/]+/[^/]+$")

-- 	-- Quick error handling in case author places modfile too low
-- 	-- Check if value from Data.BodyLibrary.Races is contained within modName

-- 	if modName then
--         for _, race in pairs(Data.BodyLibrary.Races) do
-- 			if Helper.StringContains(modName, race) then
--                 _P("Error: Mod name matches a race name, which suggests improper directory structure.")
-- 				_P("Error: Spell will be added to \"Other Genitals\"")
--                 return "BG3SX_OtherGenitals"
--             end
--         end
--     end

-- 	return modName
-- end


---@param genital string --uuid
---@return boolean
function Genital.IsPenis(genital)

	local vulva = "a0738fdf-ca0c-446f-a11d-6211ecac3291"
    local penis = "d27831df-2891-42e4-b615-ae555404918b"

	local genitalTags =  Ext.StaticData.Get(genital, "CharacterCreationAppearanceVisual").Tags

	if Table.Contains(genitalTags, penis) then
		return true
	else
		return false
	end
	
end


-- Add Genital containers - Vanilla & MrFunSize are always added
function Genital.Initialize()
 

	-- Default gentials that come with BG3SX
	allGenitals = collectAllGenitals()
	allVanillaVulvas = getVanillaGenitals("VULVA")
	allVanillaPenises = getVanillaGenitals("PENIS")
	allFunErections = collectFunErections()

	local modGenitals = {}
	-- Filter allGenitals to find additional genitals
	for _,genital in ipairs(allGenitals) do
		if not allVanillaVulvas[genital] and not allVanillaPenises[genital] and not allFunErections[genital] then
				table.insert(modGenitals, genital)
		end
	end

	allAdditionalGenitals = modGenitals

end

----------------------------------------------------------------------------------------------------
-- 
-- 											Entity Genitals
-- 
----------------------------------------------------------------------------------------------------


-- Return whether an race is allowed to have genitals - added by modders requests
---@param uuid	string	- uuid of entity that will receive the genital
---@return boolean			- True/False
local function allowedToHaveGenitals(uuid)

	if Entity:IsWhitelisted(uuid) then
		return true
	else
		return false
	end
end


-- Get all allowed genitals for entity (Ex: all vulva for human)
---@param entity EntityHandle 	  
---@return table|nil				- Table of IDs of CharacterCreationAppearaceVisuals
function Genital.getPermittedGenitals(entity)

	-- Elf, Half elf and drow share genitals in vanilla
	local permittedGenitals = Visual.getPermittedVisual(entity, allGenitals, "CharacterCreationAppearanceVisual", true, true)
	
	if (#permittedGenitals == 0) then
		return nil
	else
		return permittedGenitals
	end
end


---@param modName string  		- name of the genital "class"
---@param listOfGenitals table	- List of genital Ids prefiltered by race/body
---@return table		   		- List of IDs of CharacterCreationAppearaceVisuals
function Genital.getFilteredGenitals(modName, listOfGenitals)
	local filteredGenitals = {}
	local modGenitals = {}

	-- Vanilla Spells
	if modName == "BG3SX_VanillaVulva" then
		modGenitals = allVanillaVulvas
	elseif modName == "BG3SX_VanillaFlaccid" then
		modGenitals = allVanillaPenises
	-- Modded Dicks (including MrFunSize)	
	elseif modName == "BG3SX_SimpleErections" then
		modGenitals = allFunErections
	-- Modded Dicks
	else
		modGenitals = Genital.getModGenitals(modName)
	end
	if not modGenitals then
		_P("[BG3SX][Genital.lua] Error, spell not configured correctly, cannot get genitals")
		return
	end

	-- Only keep genitals that are in both filtered (race/body) and Mod
    for _,genital in ipairs(listOfGenitals) do
        if Table.Contains(modGenitals, genital) then
            table.insert(filteredGenitals, genital)
        end
    end
	return filteredGenitals
end


-- Used for assigning genitals to chaarcters who did not have one before
---@param entity EntityHandle 		- uuid of entity that will receive the genital
---@return string	- ID of CharacterCreationAppearaceVisual
function Genital.GetFirstBestGenital(entity)

	local genitalsToSearch = {}

	local hasPenis = Entity:HasPenis(entity.Uuid.EntityUuid)
	local penises = getVanillaGenitals("PENIS")
	local vulvas = getVanillaGenitals("VULVA")
	local permittedVulvas = Visual.getPermittedVisual(entity, vulvas, "CharacterCreationAppearanceVisual", true, false)
	local permittedPenises = Visual.getPermittedVisual(entity, penises, "CharacterCreationAppearanceVisual", true, false)
	local allPermittedGenitals = Genital.getPermittedGenitals(entity)
	local permittedVanilla = Table.ConcatenateTables(permittedVulvas, permittedPenises)

	print("Has Penis ", hasPenis)

	if permittedVanilla then
		print("Vanilla genitals exist")
		genitalsToSearch = permittedVanilla
	elseif allPermittedGenitals then
		print("No Vanilla genitals exist, but modded ones")
		genitalsToSearch = permittedVanilla
	else
		Debug.Print("[BG3SX] No genitals available after filtering for this entity. Adding default human genitals")
		if hasPenis then
			return "2fe9e574-035b-44e7-b177-9eccdf83914e"
		else
			return "ebed5dbc-d9c8-4624-b666-07aa2ddebf4c"

		end
	end
	

	for _, genital in pairs(genitalsToSearch) do
		-- alternatively if hasPenis == false and IsPenis == false, also reuturn (both are/have vulva)
		if hasPenis == Genital.IsPenis(genital) then
			print("hasPenis ", hasPenis, " and ", genital, " ispenis ", Genital.IsPenis(genital))
			return genital
		end
	end
	
end


function Genital.IsSwapToSexGenitalAllowed(character)

-- b) has the autoerection setting on, or it is on default (nil)
	local autoerection =  Mods.BG3SX.SexUserVars.GetAutoSexGenital(character)
	if autoerection then
		return true
	end
	return false
end



-- Get the current genital of the entity
---@param entity EntityHandle	- uuid of entity that has a genital
---@return string		        - table of IDs of CharacterCreationAppearaceVisual
function Genital.GetCurrentGenital(entity)
	local allGenitals =  Visual.getCurrentVisualOfType(entity, "Private Parts", "CharacterCreationAppearanceVisual")
	if (allGenitals) and (#allGenitals > 0) then
		return allGenitals[1]
	end
end


---@param entity EntityHandle
function Genital.GetDefaultErection(entity)

	local genitalsToSearch = {}

	local erections = allFunErections
	local permittedFunErections = Visual.getPermittedVisual(entity, erections, "CharacterCreationAppearanceVisual", true, false)
	local allPermittedGenitals = Genital.getPermittedGenitals(entity)


	if (#permittedFunErections == 0) then
		Debug.Print("[BG3SX] No genitals available after filtering for this entity. Adding default human genitals")
		return "beb19008-1fee-4abb-a15d-5c89247e751a"
	else
		return permittedFunErections[1]

	end
	
end

----------------------------------------------------------------------------------------------------
-- 
-- 										Transformations
-- 
----------------------------------------------------------------------------------------------------


-- TODO - really have to check with shapeshifts and Apeparance Edit enhanced/resculpt
-- Override the current genital with the new one
---@param newGenital	string      	- UUID of CharacterCreationAppearaceVisual of type PrivateParts
---@param entity		EntityHandle	- entity that will receive the genital
function Genital.OverrideGenital(newGenital, entity)

	if allowedToHaveGenitals(entity.Uuid.EntityUuid) then
		Visual.overrideVisual(newGenital, entity, "Private Parts")
	else
		Debug.Print(entity.Uuid.EntityUuid.. " is not whitelisted to receive genitals")
	end

	print("overriding genitals with " , newGenital)

	Visual.Replicate(entity)
end


-- Add a genital to a non NPC if they do not have one (only penises)
---@param entity EntityHandle	- uuid of entity that will receive the genital
function Genital.AddGenitalIfHasNone(entity)

	-- TODO - something is fucky wuck here. Shart gets a penis, and gale gets 2
	local toBeAdded
	local currentGenital = Genital.GetCurrentGenital(entity)

	print("curretGenital for ", entity.Uuid.EntityUuid, " " ,currentGenital)

	if (allowedToHaveGenitals(entity.Uuid.EntityUuid)) and (not currentGenital) then

		local favorite = SexUserVars.GetGenital("BG3SX_OutOfSexGenital", entity)

		if favorite then
			print("a facorited genital exists. Adding ", favorite)
			toBeAdded = favorite
		else
			print("no genital exists. Getting a random one")
			toBeAdded = Genital.GetFirstBestGenital(entity)
			print("fetched ", toBeAdded)
		end


		Visual.BetterAddVisualOverride(entity, toBeAdded)
		Visual.Replicate(entity)
		SexUserVars.AssignGenital("BG3SX_OutOfSexGenital", toBeAdded, entity)
		
	end
end


----------------------------------------------------------------------------------------------------
-- 
-- 										Genital UserVars
-- 
----------------------------------------------------------------------------------------------------



---@param entity EntityHandle	- uuid of entity that will receive the genital
function Genital.AssignDefaultIfHasNotYet(entity)

	local currentSetting = SexUserVars.GetGenital("BG3SX_OutOfSexGenital", entity)

	if not currentSetting then
		local currentGenital = Genital.GetCurrentGenital(entity)
		SexUserVars.AssignGenital("BG3SX_OutOfSexGenital", currentGenital, entity)
	end
end






----------------------------------------------------------------------------------------------------
-- 
-- 									Erections / Sex Genitals)
-- 
----------------------------------------------------------------------------------------------------




---@param entity	EntityHandle	-The character to give an erection to
function Genital.GiveSexGenital(entity)

	local sexGenital = SexUserVars.GetGenital("BG3SX_SexGenital", entity)
	local autoerection = Entity:TryGetEntityValue(entity.Uuid.EntityUuid, nil, {"Vars", "BG3SX_AutoSexGenital"})
	local currentGenital = Genital.GetCurrentGenital(entity)
	local hasPenis = Entity:HasPenis(entity.Uuid.EntityUuid)
	local hasVisuals = Visual.HasCharacterCreationAppearance(entity)


	if not hasVisuals then
		Visual.GiveVisualComponentIfHasNone(entity)
	end


	print("giving genitals")
	if not sexGenital then
		print("NO SEX GENITAL HAS BEEN SET")
		if not hasPenis then
			print("NO PENIS")
			if currentGenital then
				-- if already has vulva, no need to add another
				print("ALREADY HAS VULVA. RETURNING")
				SexUserVars.AssignGenital("BG3SX_SexGenital", currentGenital, entity)
				return
			else
				sexGenital = Genital.GetFirstBestGenital(entity)
				print("CHOSE VULVA ", sexGenital)
			end
		else
			print("CHOOSING SIMPLE ERECTION")
			sexGenital = Genital.GetDefaultErection(entity)
		end
	end


	_P("CHOSEN GENITAL ", sexGenital, " FOR ", entity.Uuid.EntityUuid)

	SexUserVars.AssignGenital("BG3SX_SexGenital", sexGenital, entity)

	if ((autoerection == nil) or (autoerection == true)) then
		-- change genitals
		Visual.overrideVisual(sexGenital, entity, "Private Parts")
		Visual.Replicate(entity)
	end

	
end

	
-- removes erections from all characters in the list, if applicable
---@entity EntityHandle
function  Genital.RemoveSexGenital(entity)
	
	local normalGenital = SexUserVars.GetGenital("BG3SX_OutOfSexGenital", entity)
	Genital.OverrideGenital(normalGenital, entity)
	
end
