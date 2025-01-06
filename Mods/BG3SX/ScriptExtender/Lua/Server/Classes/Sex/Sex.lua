-- TODO: remove this when UI is implemented



Ext.Osiris.RegisterListener("UsingSpellOnTarget", 6, "after", function(_, target, spell, _, _, _)


    if spell == "BG3SX_ManualErections" then
        Mods.BG3SX.SexUserVars.SetAutoSexGenital(false,target)
    end
    
    if spell == "BG3SX_AutoSexGenital" then
        Mods.BG3SX.SexUserVars.SetAutoSexGenital(true,target)
    end
end)




----------------------------------------------------------------------------------------
--
--                               For handling Sex functionalities
--
----------------------------------------------------------------------------------------

-- CONSTRUCTOR
--------------------------------------------------------------


-- METHODS
--------------------------------------------------------------

-- General
--------------------------------

-- Determines the scene type based on how many entities and penises are involved
---@param  scene Scene       - The scene to check
---@return sceneType string
function Sex:DetermineSceneType(scene)
    local involvedEntities = 0
    local penises = 0
    for _,entity in pairs(scene.entities) do
        involvedEntities = involvedEntities+1
        if Entity:HasPenis(entity) then
            penises = penises+1
        end
    end
    for _,entry in pairs(Data.SceneTypes) do
        if involvedEntities == entry.involvedEntities and penises == entry.penises then
            return entry.sceneType
        end
    end
end


-- Removes the sex spells on an entity when scene has ended
---@param entity    Entity  - The entity uuid to remove the spells from
function Sex:RemoveSexSceneSpells(entity)
    for _,spell in pairs(Data.Spells.SexSceneSpells) do -- Configurable in Shared/Data/Spells.lua
     Osi.RemoveSpell(entity, spell)
    end
end


-- Animations
--------------------------------

-- TODO: Add Height Check
-- TODO: Change animation and sound handling
-- Plays the appropriate animation and sound for a given actor based on their position in a scene.
-- @param actor         Actor   - The actor to play an animation and sound on
-- @param animationData table   - The chosen animations data table
-- @param position      string  - Specifies the actor's position (either "Top" or "Bottom") to determine the correct animation and sound
local function playAnimationAndSound(scene, animSpell)
    local newAnimation
    local newSound

    for _,actor in pairs(scene.entities) do
        --print("creating new animation class for ", actor, " with animation ", animSpell)
        newAnimation = Animation:New(actor, animSpell)
        newSound = Sound:new(actor, animSpell)
    end

    Ext.ModEvents.BG3SX.AnimationChange:Throw({newAnimation})
    Ext.ModEvents.BG3SX.SoundChange:Throw({newSound})
end


-- TODO: This might need to become its own class
-- Determines which type of scene the entity is part of and assigns the appropriate animations and sounds to the actors involved
---@param character    string  - The entity which used a new animation spell
---@param spell     string   - The chosen animations data table
function Sex:PlayAnimation(character, animSpell)

    -- TODO - make this dependant on actor instead of entity and refresh when genital has changed


    local scene = Scene:FindSceneByEntity(character)
    --print("entity is in scene ", scene)
    local sceneType = Sex:DetermineSceneType(scene)
    --print("scene type is ", sceneType)

    if sceneType == "MasturbateMale" or sceneType == "MasturbateFemale" then
    elseif sceneType == "Straight" then -- Handle this in a different way to enable actor swapping even for straight animations
        
        -- In case of actor1 not being male, swap them around to still assign correct animations
        if not Entity:HasPenis(scene.entities[1]) then
            local savedActor = scene.entities[1]
            scene.entities[1] = scene.entities[2]
            scene.entities[2] = savedActor
        end

    -- Might need to switch to free-form animation choosing because Heightmatching already is pretty complicated with 2 entities
    -- elseif sceneType == "FFF" then
    -- elseif sceneType == "FFM" then
    -- elseif sceneType == "MMF" then
    -- elseif sceneType == "MMM" then
    end

    playAnimationAndSound(scene, animSpell)

    -- Prop handling
    if animSpell ~= scene.currentAnimation then
        -- If animation is not the same as before save the new animationData table to the scene to use for prop management, teleporting or rotating
        scene.currentAnimation = animSpell
        scene:DestroyProps() -- Props rely on scene.currentAnimation
        scene:CreateProps()
    end
end


----------------------------------------------------------------------------------------------------
-- 
-- 										   Sex Setup
-- 
----------------------------------------------------------------------------------------------------

--- Handles the StartSexSpellUsed Event by starting new animations based on spell used
---@param caster            string  - The caster UUID
---@param targets           table   - The targets UUIDs
---@param animationData     table   - The animation data to use
function Sex:StartSexSpellUsed(caster, targets, animationData)
    local scene

    if animationData then
        -- _P("----------------------------- [BG3SX][Sex.lua] - Creating new scene -----------------------------")
        -- TODO - sexHavers should be able to be deleted, as the scenes are saved on the client
        -- TODO - check NPC
        local sexHavers = {caster}
        for _,target in pairs(targets) do
            if target ~= caster then -- To not add caster twice if it might also be the target
                table.insert(sexHavers, target)
            end
        end
        for _,involved in pairs(sexHavers) do
            Effect:Fade(involved, 666)
        end
        
        -- Delay the rest as well, since scene initilization is delayed for 1 second to avoid user seeing behind the scenes stuff
        local function haveSex()

            local armorsets = {}
            local equipments = {}
            local slots = {}
        
            -- erections
            for _, character in pairs(sexHavers) do

                local entity = Ext.Entity.Get(character)

                Genital.GiveSexGenital(entity)

                 -- stripping
                if not SexUserVars.GetBlockStripping(entity) then 
                    armorset, equipment, slot = Sex:Strip(character)
                    armorsets[character] = armorset
                    equipments[character] = equipment
                    slots[character] = slot
                end

            end

            Scene:new(sexHavers, equipments, armorsets, slots)
                          
            --Sex:InitSexSpells(scene)
            Sex:PlayAnimation(caster, animationData)
        end


        Ext.Timer.WaitFor(333, function() haveSex() end)
    end
end


--- Adds the main sex spells to an entity
---@param entity    string  - The entities UUID
function Sex:AddMainSexSpells(entity)
    if Entity:IsPlayable(entity) then
        Osi.AddPassive(entity, "BG3SX_BLOCK_STRIPPING")
        for _, spell in pairs(Data.Spells.MainSexSpells) do -- Configurable in Shared/Data/Spells.lua
            Osi.AddSpell(entity, spell)
        end
    end
end
function Sex:RemoveMainSexSpells(entity)
    for _, spell in pairs(Data.Spells.MainSexSpells) do  -- Configurable in Shared/Data/Spells.lua
        Osi.RemoveSpell(entity, spell)
    end
end


-- Adds additional sex spells for an entity
---@param entity    string  - The entity UUID to give additional spells to
local function addAdditionalSexActions(entity)
    local scene = Scene:FindSceneByEntity(entity)
    local spellCount = 1
    for _,spell in pairs(Data.Spells.AdditionalSexActions) do  -- Configurable in Shared/Data/Spells.lua
        -- If iteration lands on SwitchPlaces spell, check which scene type the entity is in and only add it if its not a solo one
        if spell == "BG3SX_SwitchPlaces" then
            local sceneType = Sex:DetermineSceneType(scene)
            if not (sceneType == "MasturbateFemale" or sceneType == "MasturbateMale" or sceneType == "Straight") then
                Ext.Timer.WaitFor(spellCount * 200, function()
                    Osi.AddSpell(entity, spell)
                    spellCount = spellCount + 1
                end)
            end            
        else
            Ext.Timer.WaitFor(spellCount*200, function()
                Osi.AddSpell(entity, spell)
                spellCount = spellCount+1
            end)
        end
    end
end


-- Give the entities the correct spells based on amount of entities and penises in the scene
-- Also add spells that everyone gets like end sex
---@param scene Scene   - The scene the function should get executed for
function Sex:InitSexSpells(scene)
    local sceneType = Sex:DetermineSceneType(scene)
    for _, entity in pairs(scene.entities) do -- For each entity involved
        if Entity:IsPlayable(entity) then -- Check if they are playable to not do this with NPCs
            for _, entry in pairs(Data.SceneTypes) do
                if sceneType == entry.sceneType then
                    Osi.AddSpell(entity, entry.container) -- Add correct spellcontainer based on sceneType
                end
            end
            addAdditionalSexActions(entity)
        end
    end
end



-- TODO - implement NPC logic
function Sex:Strip(character)

    local armorset = {} 
    local equipment = {}
    local slot = {}

    local entity = Ext.Entity.Get(character)
    if not entity then
        Debug.Print("Is not a valid entity ", character)
    end


    if Entity:IsNPC(character) then
    -- NPCs only have slots in their CharacterVisualResourceID
        slot = NPC.StripNPC(entity)
        
    else
        equipment = Entity:UnequipAll(character)
        armorset = Osi.GetArmourSet(character)
    end

    return armorset, equipment, slot

end

----------------------------------------------------------------------------------------------------
-- 
-- 										   Sex Options
-- 
----------------------------------------------------------------------------------------------------

-- Changes the camera height by scaling an entity
-- Camera will zoom out on the entity which will look nicer on scene start
---@param entity string - uuid of the entity 
function Sex:ChangeCameraHeight(uuid)
    local entity = Ext.Entity.Get(uuid)
    local currentEntityScale = Entity:TryGetEntityValue(uuid, nil, {"GameObjectVisual", "Scale"})

    -- Don't use integers - floating point shenanigangs
    if entity.GameObjectVisual then -- Safeguard against someone trying to create a scene with Scenery NPCs
        if currentEntityScale > 0.99 and currentEntityScale < 1.01 then
            entity.GameObjectVisual.Scale = 0.5
        elseif currentEntityScale > 0.49 and currentEntityScale < 0.51 then
            entity.GameObjectVisual.Scale = 0.05
        elseif currentEntityScale > 0.04 and currentEntityScale < 0.06 then
            entity.GameObjectVisual.Scale = 1.0
        end
        entity:Replicate("GameObjectVisual")
    end
    Ext.ModEvents.BG3SX.CameraHeightChange:Throw({uuid}) 
end

