--
-------------------------------------------------------------------------------------------------------
-- 	                        All purpose Visual maipualation
--
--
---------------------------------------------------------------------------------------------------------



function Visual.new()
    local instance = setmetatable({}, Visual)
    return instance
end




--[[
                     #@%%%%%%%%%%%%#    %%%%%%%%%%%%%
                %%%%#****##***####**#%#********######*#%%%%
             #%%#***##=*%=@@@@+.....-*#****+-*@-#@@@#..:+#%@@
           #%#***##:..+@@@@+.%@=.......@+...-@@%@#:%@*.....-@
         %%*****%-....*@@@@@@@@+......+:....=@@@@@@@@*.....#%
       @#*********##:.:%@@@@@@=.....-##=.....#@@@@@@=..:+#%@
     @%***************####**++*####******#############**%@
   @@#*******%#****#%%%#********************************@
 @@#********#%*************###%###*****************##%%#*#@
@%*************%%#****###************############********%@
#*****************#%%#********####*****************####%#@@
***********************##%%#***************************##*@@
*****************************##%%%%%%######**********%%#**#@%
***********************************************************#@
********************************%###%#**********************%
*********************************%#**%***********************
*********************************%#**%***********************
*********************************%#*#%***********************
********************************#%**#%***********************
******************************#%#***%%%%#********************
****************************#%***********#%%*****************
**************************#%#*************%#*****************
*************************#%*************#@#******************
************************%#***************#%******************
**********************#%*******#********%#*******************
********************#%#*****#%#*#%%%%%%#*********************
******************#%******#%#********************************
***************#%#******#%#**********************************
*************%#*******#%#************************************
]]--



-------------------------------------------------------------------------------------------------------
--
--		 	                            NOsi version of Osi functions
--					        Faster and less flickering since they are not replicated
--		 			 -> Have to call the Visual.Replicate function after all changes are done
--		 			Supports Visual manipulation of Shapeshifted entitys/NPCs out of the box
--						   		-> Necessary for Appearance Edit Enhanced
--
--										"This is my Opus Magnum - https://i.imgur.com/WzVilXP.png"
--                                         - Satan, 31.December 2024
--
--                                      "WTF"
--                                         - Skiz, 01. January, 2025
--
---------------------------------------------------------------------------------------------------------


-- When using the "Better" functions, replication has to be called manuall
-- This reduces flickering when adding multiple visuals at once
-- If a lot of changes are made, especially when having to add components to
-- shapeshifted entitys, sometimes a timer before replication is necessary
---@param entity EntityHandle
---@param delay number|nil -- numer in ms
function Visual.Replicate(entity, delay)

	delay = delay or nil

    local function func()

        entity:Replicate("CharacterCreationAppearance")
        entity:Replicate("GameObjectVisual")
    end

    Helper.OptionalDelay(func, delay)
end

function Visual.ReplicateBySatanSync(entity, componentPath, newValue)
    Helper.SatanSync(entity, componentPath, newValue)
end


-- I kept the typo for consistency, and because it's funny
---@param entity EntityHandle  - uuid
---@param visual string - uuid
function Visual.BetterRemoveVisualOvirride(entity, visual)

    local visuals = {}

    for _, entry in pairs(entity.CharacterCreationAppearance.Visuals) do
        if not (entry == visual) then
            table.insert(visuals,entry)
        end
    end

    entity.CharacterCreationAppearance.Visuals = visuals
end

---@param entity EntityHandle  - uuid
---@param visual string - uuid
---@param delay number|nil -- numer in ms
function Visual.BetterAddVisualOverride(entity, visual, delay)


    local function func()

        local visuals = {}

        for _, entry in pairs(entity.CharacterCreationAppearance.Visuals) do
            table.insert(visuals,entry)
        end

        table.insert(visuals, visual)
        entity.CharacterCreationAppearance.Visuals = visuals
    end

    Helper.OptionalDelay(func, delay)

    return entity.CharacterCreationAppearance.Visuals

end


-- adds a whole list of visuals with Osi.AddCustomVisualOverride for convenience
---@param entity EntityHandle
---@param listToAdd table
function Visual.AddListOfVisuals(entity, listToAdd)

    if listToAdd then

        if Shapeshift.IsShapeshifted(entity) then
            Shapeshift.MakeEditable(entity)
            Shapeshift.AddListOfVisuals(entity, listToAdd)
            Shapeshift.RevertEditability(entity, 0)
        else
            for _, entry in pairs(listToAdd) do
                Visual.BetterAddVisualOverride(entity, entry)
            end
        end
    end
end


-- removes a whole list of visuals for convenience
---@param entity EntityHandle
---@param listToRemove table
function Visual.RemoveListOfVisuals(entity, listToRemove)

    if listToRemove then

        if Shapeshift.IsShapeshifted(entity) then
            Shapeshift.MakeEditable(entity)
            Shapeshift.RemoveListOfVisuals(entity, listToRemove)
            Shapeshift.RevertEditability(entity, 0)
        else

            for _, entry in pairs(listToRemove) do
                Visual.BetterRemoveVisualOvirride(entity, entry)
            end
        end
    end
end



---@param entity EntityHandle  - uuid
---@return table
function Visual.GetAllVisuals(entity)

    -- if they don't have a CCA entry, they are an NPC and need to have one created
    local cca = Helper.GetPropertyOrDefault(entity,"CharacterCreationAppearance", nil)

    if Shapeshift.IsShapeshifted(entity) then
        return Shapeshift.GetAllVisuals(entity)
    else

        if cca then
            return cca.Visuals
        end
    end
end




----------------------------------------------------------------------------------------------------
--
-- 									Visual Type Identification
--
----------------------------------------------------------------------------------------------------

-- Get type of uuid
---@param uuid	string	- uuid of visual
---@return string  	    - "CharacterCreationAppearanceVisual" or CharacterCreationSharedVisual"
function Visual.getType(uuid)

    local ccav = Ext.StaticData.Get(uuid,"CharacterCreationAppearanceVisual")
    local ccsv = Ext.StaticData.Get(uuid,"CharacterCreationSharedVisual")

    if ccav then
        return "CharacterCreationAppearanceVisual" --, ccav.SlotName
    elseif ccsv then
        return "CharacterCreationSharedVisual" --, ccsv.SlotName
    end
end

----------------------------------------------------------------------------------------------------
--
-- 									Get the cumulated information
--
----------------------------------------------------------------------------------------------------

-- Get all visuals of one type for an entity with their names
---@param type			string	        - The visual type (ex: Private Parts)
---@param entity		EntityHandle
---@param visualType	string	        - "CharacterCreationAppearanceVisual" or "CharacterCreationSharedVisual"
---@param filter        boolean         - Whether to filter for bodytype, bodyshape, race
---@return table		                - List of entityCreationAppearaceVisual IDs for all Visual
function Visual.getVisualsWithName(type, entity, visualType, filter)
	local permittedVisuals = {}
    local allVisualsOfType = Visual.getAllVisualsOfType(type, visualType)
    permittedVisuals = Visual.getPermittedVisual(entity, allVisualsOfType, visualType, filter, false)
    local visualsWithName = Visual.addName(entity, permittedVisuals, visualType, type)
    return visualsWithName
end


-- returns all visuals of a type for an entity : both CCAV and CCSV
---@param type	 string	        - Type of the visual (ex: Private Parts)
---@param entity EntityHandle	-  entity who will receive visual
---@param filter boolean        - Whether to filter for bodytype, bodyshape, race
---@return table	            - List of IDs of CCAV and CCSV
function Visual.getAllVisualsWithName(type,entity, filter)
    local allCCAV = Visual.getVisualsWithName(type, entity,"CharacterCreationAppearanceVisual", filter)
    local allCCSV = Visual.getVisualsWithName(type, entity, "CharacterCreationSharedVisual", filter)
	local allVisuals = Table.ConcatenateTables(allCCAV, allCCSV)
    return allVisuals
end

----------------------------------------------------------------------------------------------------
--
-- 									Static Data Handling
-- 				        read information saved in xml files from game
--
----------------------------------------------------------------------------------------------------


-- Get all entityCreationAppearaceVisuals loaded in the game
---@param visualType string     - "CharacterCreationAppearanceVisual" or "CharacterCreationSharedVisual"
---@return table				- list of entityCreationAppearaceVisual IDs for all Visual
function Visual.getAllVisuals(visualType)
    local allVisuals = Ext.StaticData.GetAll(visualType)
	return allVisuals
end


-- Get all entityCreationAppearaceVisuals of type x loaded in the game
---@param type string            - The visual type (ex: Private Parts)
---@param visualType string      - "CharacterCreationAppearanceVisual" or "CharacterCreationSharedVisual"
---@return table 				 - list of entityCreationAppearaceVisual IDs for all Visual of type x
function Visual.getAllVisualsOfType(type, visualType)
	local allVisuals = Visual.getAllVisuals(visualType)
    local visualOfType = {}
	for i, visual in pairs(allVisuals)do
		local contents = Ext.StaticData.Get(visual, visualType)
		local slotName = contents.SlotName
		if slotName and slotName == type then
			table.insert(visualOfType, visual)
		end
	end
	return visualOfType
end


-- Get all entityCreationAppearaceVisuals loaded in the game
---@param visual string     - uuid
---@return string
function Visual.GetName(visual)
    local type = Visual.getType(visual)
    local stats =  Ext.StaticData.Get(visual, type)
	local handle = stats.DisplayName.Handle.Handle
	local name = Ext.Loca.GetTranslatedString(handle)
	return name
end


----------------------------------------------------------------------------------------------------
--
-- 				                     Entity Visuals
--
----------------------------------------------------------------------------------------------------


function Visual.HasCharacterCreationStats(entity)

    local E = Helper.GetPropertyOrDefault(entity,"CharacterCreationStats", nil)

	if E then
		return true
    else
        return false
    end
end


function Visual.HasCharacterCreationAppearance(entity)

    local E = Helper.GetPropertyOrDefault(entity,"CharacterCreationAppearance", nil)

	if E then
		return true
    else
        return false
    end
end

-- Get all allowed Visual for entity (Ex: all vulva for human)
---@param entity EntityHandle
---@return integer,integer,string	  - bodytype, bodyshape, race
function Visual.getEntityProperties(entity)
	-- Get the properties for the entity

    local halsin = "S_GLO_Halsin_7628bc0e-52b8-42a7-856a-13a6fd413323"
    local human = "0eb594cb-8820-4be6-a58d-8be7a1a98fba"

	local bt =  entity.BodyType.BodyType
    local bs = 0

	if Visual.HasCharacterCreationStats(entity) then
		bs = entity.CharacterCreationStats.BodyShape
	end

	-- NPCs only have race tags
	local raceTags = entity:GetAllComponents().ServerRaceTag.Tags

	local race
	for _, tag in pairs(raceTags) do
		if Data.BodyLibrary.RaceTags[tag] then
			race = Table.GetKey(Data.BodyLibrary.Races, Data.BodyLibrary.RaceTags[tag])
			break
		end
	end


	if not Data.BodyLibrary.Races[race] then
		race = human
	end

	-- Special Cases

	-- Halsin is special boy
	if entity.Uuid.EntityUuid == halsin then
		race = human
	end

	return bt, bs, race
end



local function getParent(race)

    local helf = "45f4ac10-3c89-4fb2-b37d-f973bb9110c0"
    local drow = "45f4ac10-3c89-4fb2-b37d-f973bb9110c0"
    local elf = "6c038dcb-7eb5-431d-84f8-cecfaf1c0c5a"

    if (race == helf) or (race == drow) then
        return elf
    end
end


local function tableContainsNameAlready(tableOfGenitals, genital)
	local genitalName = Visual.GetName(genital)
		for _, uuid in pairs(tableOfGenitals) do
			local name = Visual.GetName(uuid)
			if name == genitalName then
				return true
			end
		end
	return false
end


-- Get all allowed Visual for entity (Ex: all vulva for human)
---@param entity EntityHandle
---@param allVisual table       - table of all visuals to filter
---@param visualType string     - "CharacterCreationAppearanceVisual" or "CharacterCreationSharedVisual"
---@param filter boolean  	    - whether to filter for bodytype, bodyshape, race - false disables race filter
---@param useParentRace boolean - Toggle to show parent visuals instead of subracevisuals
---@return table 			    - List of IDs of entityCreationAppearaceVisuals
function Visual.getPermittedVisual(entity, allVisual, visualType, filter, useParentRace)
    local permittedVisual = {}

	-- Bodytype, Bodyshape, Race
	local bt,bs,race = Visual.getEntityProperties(entity)


    -- TODO - check if this is necessary for other races/usecases too
    if useParentRace then
        local newRace = getParent(race)

        if newRace then
            race = newRace
        end
    end

	-- Get Visual with same stats
	for _, visual in pairs(allVisual) do

		local G = Ext.StaticData.Get(visual, visualType)

		local gbt = Helper.GetPropertyOrDefault(G, "BodyType", bt)
		local gbs = Helper.GetPropertyOrDefault(G, "BodyShape", bs)
		local gru = Helper.GetPropertyOrDefault(G, "RaceUUID", race)

		if not filter then
			gru = race
		end

		if (bt == gbt) and (bs == gbs) and (race == gru) then

            if useParentRace then
                -- Have to use unique names, since Larian uses the same RaceUUID for different subraces
                --(╯°□°)╯︵ ┻━┻

                if not tableContainsNameAlready(permittedVisual, visual) then
                    table.insert(permittedVisual, visual)
                end

            else
			    table.insert(permittedVisual, visual)
            end
		end
    end

	-- TODO - only for genitals
    -- TODO - Clean up
    -- Some lazy filtering to filter out default Visual (for genitals only)

    local result = {}
      for _, visual in ipairs(permittedVisual) do

        local content = Ext.StaticData.Get(visual,visualType)
        local handle = content.DisplayName.Handle.Handle
        local name = Ext.Loca.GetTranslatedString(handle)
        if name ~= "Default" then
            table.insert(result, visual)
        end
    end

	return result
end


-- Get the current Visual of the entity
---@param entity EntityHandle 	    - uuid of entity that has a Visual
---@return table			        - table of IDs of entityCreationAppearaceVisual
function Visual.getCurrentVisual(entity)
    if not Visual.HasCharacterCreationAppearance(entity) then
        return
    end

	local entityVisuals =  entity.CharacterCreationAppearance.Visuals
    return entityVisuals
end



-- Get the current Visual of the entity of a specific type
---@param entity EntityHandle
---@param type string 	   	     - The visual type (ex: Private Parts)
---@param visualType string      - "CharacterCreationAppearanceVisual" or "CharacterCreationSharedVisual"
---@return table			     - table of IDs of entityCreationAppearaceVisual
function Visual.getCurrentVisualOfType(entity, type, visualType)

	local currentVisual = Visual.getCurrentVisual(entity)
	local VisualOfType = Visual.getAllVisualsOfType(type, visualType)

    local visualsOfType = {}

    if not currentVisual then
        return
    end

	for _, visual in pairs(currentVisual)do
        if Table.Contains(VisualOfType, visual) then
            table.insert(visualsOfType, visual)
		end
    end
    return visualsOfType
end

----------------------------------------------------------------------------------------------------
--
-- 									Transformations
--
----------------------------------------------------------------------------------------------------


---@param entity EntityHandle  - uuid
function Visual.GiveVisualComponentIfHasNone(entity)

    -- if they don't have a CCA entry, they are an NPC and need to have one created
    local cca = Helper.GetPropertyOrDefault(entity,"CharacterCreationAppearance", nil)

    if not cca then
        entity:CreateComponent("CharacterCreationAppearance")
    end
end

-- Override the current Visual with the new one
---@param newVisual	string          - ID of entityCreationAppearaceVisual
---@param type string               - ex: PrivateParts
---@param entity EntityHandle 	    - uuid of entity that will receive the Visual
function Visual.overrideVisual(newVisual, entity, type)

	local currentCCAV = Visual.getCurrentVisualOfType(entity, type, "CharacterCreationAppearanceVisual")
	local currentCCSV = Visual.getCurrentVisualOfType(entity, type, "CharacterCreationSharedVisual")
	local currentVisuals = Table.ConcatenateTables(currentCCAV, currentCCSV)


    if not Visual.HasCharacterCreationAppearance(entity) then
        Visual.OverrideVisualSetSlot(newVisual, entity, type)
        return
    end


    for _, visual in pairs(currentVisuals) do
        -- TODO - why is this check necessary?
	    if not (visual == newVisual) then
            if Shapeshift.IsShapeshifted(entity) then
                Shapeshift.MakeEditable(entity)
                Shapeshift.RemoveCustomVisualOvirride(entity, visual)
                Shapeshift.RevertEditability(entity,200)
            end

            Visual.BetterRemoveVisualOvirride(entity, visual)
	    end
	end

	if newVisual then
        if Shapeshift.IsShapeshifted(entity) then
            Shapeshift.MakeEditable(entity)
            Shapeshift.AddCustomVisualOverride(entity, newVisual)
            Shapeshift.RevertEditability(entity,200)
        end
        Visual.BetterAddVisualOverride(entity, newVisual)
	end


    return entity.CharacterCreationAppearance.Visuals
end

------------------------------------------------------------------------------------------------------------------------------
--
--                                         Visual Set Slots
--                                  Those are the ones for NPCs
--
---------------------------------------------------------------------------------------------------------------------------


 -- get VisualResourceID from uuid
 ---@param  entity EntityHandle          - the NPC
 ---@return string                       - VisualResourceID
function Visual.getVisualResourceID(entity)
    local vrID
    if Ext.IsServer() then
        vrID = entity.ServerCharacter.Template.CharacterVisualResourceID
    elseif Ext.IsClient() then
        vrID = entity.ClientCharacter.Template.CharacterVisualResourceID
    end
    return vrID
 end


-- returns the VisualSet.Slots
---@param  entity EntityHandle - uuid of the entity possibly wearing a visual
function Visual.getSlots(entity)
    local vrID
    if Ext.IsServer() then
        vrID = entity.ServerCharacter.Template.CharacterVisualResourceID
    elseif Ext.IsClient() then
        vrID = entity.ClientCharacter.Template.CharacterVisualResourceID
    end
    local slots = Ext.Resource.Get(vrID, "CharacterVisual").VisualSet.Slots
    return slots
end


---@param entity EntityHandle  - uuid of the entity
---@param uuid string - uuid to remove
---@return table - visual that has been removed
function Visual.removeVisualSetSlot(entity, uuid)

    local slots = Visual.getSlots(entity)
    local removed = {}

    for i, entry in pairs(slots) do

        if  entry.VisualResource == uuid then
            entry.VisualResource = ""

            table.insert(removed, {uuid = entry.VisualResource, index = i})
        end
    end

	return removed

end


---@param entity EntityHandle  - uuid of the entity
---@param type string - type of the visual to remove
---@return table - visual that has been removed
function Visual.removeVisualSetBySlot(entity, type)

    local slots = Visual.getSlots(entity)
    local removed = {}

    for i, entry in pairs(slots) do

        if  entry.Slot == type then
            table.insert(removed, {uuid = entry.VisualResource, index = i})
            entry.VisualResource = ""
        end
    end

	return removed

end

---@param entity EntityHandle  - uuid of the entity
---@param toBeAdded table - entries to be added . Format: {uuid = entry.VisualResource, index = i}
function Visual.addVisualSetSlot(entity, toBeAdded)
    -- _P("Adding")
    -- _D(toBeAdded)
    local slots = Visual.getSlots(entity)

    for i, entry in pairs(slots) do
        for _, tba in pairs(toBeAdded) do

            if i == tba.index  then
                entry.VisualResource = tba.uuid
            end
        end
    end
end


function Visual.OverrideVisualSetSlot(newVisual, entity, type)

    Visual.removeVisualSetBySlot(entity, type)
    Visual.addVisualSetSlot(entity, newVisual)

end



 -- get Slots (contain body, hair, gloves, tails etc.)
 -- serialize them because else they expire
 ---@param   entity EntityHandle         - uuid of the NPC
 ---@return  table         - Slots (Table)
function Visual.serializeVisualSetSlots(entity)
    local visualSet = Ext.Resource.Get(Visual.getVisualResourceID(entity), "CharacterVisual").VisualSet.Slots
    local serializedSlots = {}
    for _, slot in ipairs(visualSet) do
        -- Only copy the data you need, and ensure it's in a Lua-friendly format
        table.insert(serializedSlots, {Bone = slot.Bone, Slot = slot.Slot, VisualResource = slot.VisualResource})
    end
    return serializedSlots
end
