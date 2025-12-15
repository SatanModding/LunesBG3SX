-- TODO: remove this when UI is implemented



Ext.Osiris.RegisterListener("UsingSpellOnTarget", 6, "after", function(_, target, spell, _, _, _)


    -- if spell == "BG3SX_ManualErections" then
    --     Mods.BG3SX.SexUserVars.SetAutoSexGenital(false,target)
    -- end

    -- if spell == "BG3SX_AutoSexGenital" then
    --     Mods.BG3SX.SexUserVars.SetAutoSexGenital(true,target)
    -- end
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
---@param  entities table       - The entities to check
---@return string sceneType - The scene type based on the number of entities and penises
function Sex:DetermineSceneType(entities)


    --  print("PeePee Server Test")

    -- local function GetConfig()
    --     local modVars = Ext.Vars.GetModVariables(ModuleUUID)
    --     local config = {}
    --     if modVars and modVars.PeePee then
    --         config = modVars.PeePee
    --     end
    --     return config
    -- end

    -- local function UpdateConfig(config)
    --     Ext.Vars.GetModVariables(ModuleUUID).PeePee = config
    --     print('PeePee Configuration updated!')
    --     _D(GetConfig())
    -- end

    -- local function DoSomething()

    --     print("current")
    --     _D(GetConfig()) -- prints "[]" after a save and reload
    --     UpdateConfig("PooPoo") -- is only "PooPoo" until save is saved and loaded
    -- end

    -- DoSomething()



    local involvedEntities = 0
    local penises = 0
    for _,entity in pairs(entities) do
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
        Ext.ModEvents.BG3SX.AnimationChange:Throw({newAnimation})

        -- Only play sound if is enabled for a given animation entry
        if animSpell.Sound == true then
            newSound = Sound:New(actor, animSpell)
            Ext.ModEvents.BG3SX.SoundChange:Throw({newSound})
        end
    end
end


-- TODO: This might need to become its own class
-- Determines which type of scene the entity is part of and assigns the appropriate animations and sounds to the actors involved
---@param character    string  - The entity which used a new animation spell
---@param spell     string   - The chosen animations data table
function Sex:PlayAnimation(character, animData)

    -- TODO - make this dependant on actor instead of entity and refresh when genital has changed


    local scene = Scene.FindSceneByEntity(character)
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

    playAnimationAndSound(scene, animData)

    -- Prop handling
    if animData ~= scene.currentAnimation then
        -- If animation is not the same as before save the new animationData table to the scene to use for prop management, teleporting or rotating
        scene.currentAnimation = animData
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
function Sex:NewSFWScenePreSetup(caster, targets, animationData)
    if animationData then
        local involved = {caster}
        for _,target in pairs(targets) do
            if not Helper.StringContainsOne(caster,target) then -- To not add caster twice if it might also be the target
                table.insert(involved, target)
            end
        end
        -- for _,involved in pairs(involved) do
        --     Effect:Fade(involved, 666)
        -- end

        local scene = Scene:New({Type = "SFW", Entities = involved, Fade = 666}):Init()
    end
end

function Sex:PreNSFWSceneSetup(characters)
    local actualInvolvedCharacters = {}
    if Helper.StringContainsOne(characters[1],characters[2]) then
        table.insert(actualInvolvedCharacters, characters[1])
    else
        table.insert(actualInvolvedCharacters, characters[1])
        table.insert(actualInvolvedCharacters, characters[2])
    end

    local strippedEQ = {}
    -- local equipments = {}
    -- local armorsets = {}
    -- local slots = {}

    -- Erection Handling
    for _, character in pairs(actualInvolvedCharacters) do
        local entity = Ext.Entity.Get(character)
        Genital.GiveSexGenital(entity)

        local stripping = SexUserVars.GetAllowStripping(entity)
        if not (stripping == false) then
            local armorset, equipment, slot = Sex:Strip(character)
            strippedEQ[character] = {Armorset = armorset, Equipment = equipment, Slot = slot}
        end
    end
    return strippedEQ
end

--- Handles the StartSexSpellUsed Event by starting new animations based on spell used
---@param caster            string  - The caster UUID
---@param targets           table   - The targets UUIDs
---@param animationData     table   - The animation data to use
function Sex:StartSexSpellUsed(caster, targets, animationData)
    if animationData then
        local sexHavers = {caster}
        for _,target in pairs(targets) do
            if not Helper.StringContainsOne(caster,target) then -- To not add caster twice if it might also be the target
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

                -- if BG3AFActive then
                --     local function addWaterfallToEntity(entity, tbl)
                --         local animWaterfall = Mods.BG3AF.AnimationWaterfall.Get(entity)
                --         local waterfallEntry = animWaterfall:AddWaterfall(tbl)
                --     end

                --     local tbl = {
                --         Resource = Data.AnimationSets["BG3SX_Body"].Uuid,
                --         DynamicAnimationTag = "9bfa73ed-2573-4f48-adc3-e7e254a3aadb",
                --         Slot = "", -- 0 = Body, 1 = Attachment
                --         OverrideType = 0, -- 0 = Replace, 1 = Additive
                --     }

                --     addWaterfallToEntity(sexHavers[1], tbl)
                --     if #sexHavers > 1 then
                --         addWaterfallToEntity(sexHavers[2], tbl)
                --     end
                -- else
                --     Debug.Print("BG3AF not found")
                -- end

                -- stripping
                local stripping = SexUserVars.GetAllowStripping(entity)
                if not (stripping == false) then
                    local armorset, equipment, slot = Sex:Strip(character)
                    armorsets[character] = armorset
                    equipments[character] = equipment
                    slots[character] = slot
                end
            end

            -- Scene:New(sexHavers, equipments, armorsets, slots)
            Scene:New({Type = "NSFW", Entities = sexHavers, Equipments = equipments, ArmorSets = armorsets, Slots = slots, Fade = 666, Strip = true})
            -- local scene = Scene:New({Entities = sexHavers})
            -- scene.Equipments = equipments
            -- scene.ArmorSets = armorsets
            -- scene.Slots = slots
            -- scene:Init()

            --TODO - remove timer
            --Ext.Timer.WaitFor(2000, function ()
            --end)
        end

        -- Timer to delay scene creation for the fadeout
        Ext.Timer.WaitFor(333, function() haveSex() end)
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
        slot = NPC.StripNPC(entity) -- Call on Server
        Event.SyncNPCStrip:Broadcast(entity.Uuid.EntityUuid) -- Call on Client
        equipment = Entity:UnequipAll(character)
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


-- local function reapplyWaterfall(cmd, uuid)

--     local sx = "bfa9dad2-2a5b-45cc-b770-9537badf9152"
--     Mods.BG3AF.AnimationWaterfall.Get(uuid):AddWaterfall(sx)

    -- Event.ReapplyWaterfall:Broadcast(uuid)

    
-- end



-- local function testCmd(cmd, a1, a2, ...)
--     _P("Cmd: " .. cmd .. ", args: ", a1, ", ", a2);
-- end


-- Ext.RegisterConsoleCommand("test", testCmd);
-- ConsoleCommand.New("Test", testCmd, "Test command to test the console command system")




--ConsoleCommand.New("rw", reapplyWaterfall, "Does the thing")