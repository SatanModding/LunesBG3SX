----------------------------------------------------------------------------------------
--
--                               For handling Scenes
--
----------------------------------------------------------------------------------------

local BG3AF = {}
if BG3AFActive then
    BG3AF = Mods.BG3AF
end

Data.SavedScenes = {}

local initialize

-- CONSTRUCTOR
--------------------------------------------------------------

---@class Scene
---@field New fun(self:Scene, ...:SceneParameters):Scene
---@field Get fun(self:Scene, uuid:string):Scene|nil
---@field FindSceneByEntity fun(entityToSearch:string):Scene|nil
---@field PreNSFWSceneSetup fun(self:Scene)
---@field Init fun(self:Scene)
---@field getStartLocation fun(self:Scene, entity:string):table, table
---@field setStartLocations fun(self:Scene)
---@field saveCampFlags fun(self:Scene)
---@field EntityReset fun(self:Scene)
---@field MoveSceneToLocation fun(self:Scene, newLocation:table)
---@field RotateScene fun(self:Scene, location:table)
---@field StopAnimation fun(self:Scene)
---@field PlayAnimation fun(self:Scene, animationData:table)
---@field TogglePause fun(self:Scene)
---@field ScreenFade fun(self:Scene, duration:number)
---@field CleanupSummons fun(self:Scene)
---@field HideSummons fun(self:Scene)
---@field ShowSummons fun(self:Scene)
---@field SetupAndHideSummons fun(self:Scene)
---@field ScaleEntity fun(self:Scene, entityUuid:string)
---@field CreateProps fun(self:Scene)
---@field DestroyProps fun(self:Scene)
---@field RegisterNewSoundTimer fun(self:Scene, newSoundTimer:integer)
---@field CancelAllSoundTimers fun(self:Scene)
---@field ToggleCampFlags fun(self:Scene, entity:string)
---@field Destroy fun(self:Scene)

---@class SceneParameters
---@field Type            string|nil - Type of the scene, SFW or NSFW
---@field Entities        table|nil  - Table with entity uuids to use for a scene,
---@field SceneType       string|nil  - Type of the scene, based of involved penises - TODO: Rename to MatchupType
---@field RootPosition    table|nil  - Table of x,y,z coordinates
---@field Rotation        table|nil  - Table with x,y,z,w rotation
---@field StartLocations  table|nil  - Saves the start locations (Position/Rotation) of each entity to teleport back to when scene is destroyed
---@field EntityScales    table|nil  - Saves the start entity scales
---@field CurrentAnimation table|nil  - Table of the current animation being played
---@field CurrentSounds   table|nil  - Table of currently playing sounds
---@field TimerHandles    table|nil  - Timer handles in case they have to be cancelled (failsave)
---@field CameraZoom      table|nil  - Unused - Was intended to store previous zoom levels per entity - handled differently now
---@field Props           table|nil  - Table of all props currently in a scene
---@field SwitchPlaces    boolean|nil - Boolean for PlayAnimation to check if actors have been switched - TODO: need a cleaner way to handle this
---@field CampFlags       table|nil  - Table of entities with campflags applied before scene to reapply on Destroy() - Ignore those who didn't - PleaseStay Mod compatibility
---@field Summons         table|nil  - Table of summons saved per involved entity
---@field Equipment       table|nil  - Table of [uuid] of entity and a table of their equipment
---@field Armorset        table|nil  - Table of [uuid] of entity and a table of their armorset
---@field Slots           table|nil  - Format: {uuid = entry.VisualResource, index = i}
---@field UnlockedSwaps   boolean|nil - If the scene has unlocked swaps for actors
---@field CouldJoinCombat table|nil  - Table of entities that could join combat before the scene started
---@field WasOnStage      table|nil  - Table of entities that were on stage before the scene started
---@field Fade            number|nil - Fade effect for the scene
---@field StrippedEQ      table<string,StrippedEQ>|nil  - Table of stripped equipment, armorset and slots per entity, used to restore equipment on Scene:Destroy()

-- Creeated a new Scene Instance
---@param ... SceneParameters
---@return Scene
function Scene:New(...)
    local args = (...)
    local instance      = setmetatable({
        Uuid            = Helper.GenerateUUID(), -- Unique identifier for the scene
        Type            = args.Type or "SFW" or "NSFW", -- Type of the object
        entities        = args.Entities or {},
        SceneType       = Sex:DetermineSceneType(args.Entities) or nil,
        rootPosition    = args.RootPosition or {},
        rotation        = args.Rotation or {},
        startLocations  = args.StartLocations or {}, -- NEVER change this after initialize - Used to teleport everyone back on Scene:Destroy()
        entityScales    = args. EntityScales or {},
        currentAnimation= args.CurrentAnimation or {},
        currentSounds   = args.CurrentSounds or {},
        timerHandles    = args.TimerHandles or {},
        cameraZoom      = args.CameraZoom or {},
        props           = args.Props or {},
        campFlags       = args.CampFlags or {},
        Summons         = args.Summons or {},
        equipment       = args.Equipment or {},
        armorset        = args.Armorset or {},
        slots           = args.Slots or {},
        UnlockedSwaps   = args.UnlockedSwaps or false,
        CouldJoinCombat = args.CouldJoinCombat or {},
        WasOnStage      = args.WasOnStage or {},
        Fade            = args.Fade or nil,
        StrippedEQ      = args.StrippedEQ or {}, -- Table of stripped equipment per entity
    }, Scene)
    return instance
end

----------------------------------------------------------------------------------------------------
-- 
-- 									    Getters and Setters
-- 
----------------------------------------------------------------------------------------------------

-- Sets an entities start location before possibly getting teleported during a scene for an easy reset on Scene:Destroy() with getStartLocation
---@param entity string - UUID of the entity 
local function setStartLocations(scene)
    for _,character in pairs(scene.entities) do

        local entity = Ext.Entity.Get(character)
        --local position = {}
        --position.x, position.y, position.z = Osi.GetPosition(entity)
        --local rotationHelper = Entity:SaveEntityRotation(entity)
        local position = entity.Transform.Transform.Translate
        local rotation = entity.Steering.TargetRotation

        table.insert(scene.startLocations, {entity = character, position = position, rotation = rotation})
    end
    scene.rootPosition = scene.startLocations[1].position -- Set the root position to the first entities position
end



-- TODO: Actually use it - we currently just call the table manually every time
-- Gets an entities start location for a location reset of an entity on Scene:Destroy()
---@param entity    string  - UUID of the entity 
---@return          table   - The entities position
---@return          table   - The entities rotation
local function getStartLocation(scene, entity)
    for _, entry in pairs(scene.startLocations) do
        if entry.entity == entity then
            return entry.position, entry.rotationHelper
        end
    end
end

----------------------------------------------------------------------------------------------------
-- 
-- 										Helper Functions
-- 
----------------------------------------------------------------------------------------------------

-- Goes through every currently running scene until it finds the entityToSearch
---@param entityToSearch string
function Scene.FindSceneByEntity(entityToSearch)
    -- _P(entityToSearch)
    for i, scene in ipairs(Data.SavedScenes) do
        for _, entity in pairs(scene.entities) do
            if Helper.StringContains(entityToSearch, entity) then
                -- _D(scene)
                return scene
            end
        end
    end
    Debug.Print("Entity not found in any existing scenes!")
end

function Scene.Get(uuid)
    for _, scene in ipairs(Data.SavedScenes) do
        if scene.Uuid == uuid then
            return scene
        end
    end
    Debug.Print("Scene with UUID " .. uuid .. " not found in any existing scenes!")
end

-- Campflag Management
-----------------------------------------------------

local function saveCampFlags(self)
    for _,entity in pairs(self.entities) do
        if Osi.GetFlag("161b7223-039d-4ebe-986f-1dcd9a66733f", entity) == 1 then
            table.insert(self.campFlags, entity)
        end
    end
end

function Scene:ToggleCampFlags(entity)
    for _,flagEntity in pairs(self.campFlags) do
        if entity == flagEntity then
            Entity:ToggleCampFlag(entity)
        end
    end
end


-- SceneTimer Management - Currently only SoundTimer
-----------------------------------------------------

function Scene:RegisterNewSoundTimer(newSoundTimer)
    table.insert(self.timerHandles, newSoundTimer)
end

function Scene:CancelAllSoundTimers()
    for i = #self.timerHandles, 1, -1 do
        local handle = self.timerHandles[i]
        table.remove(self.timerHandles, i)
        Ext.Timer.Cancel(handle)
    end
    if #self.timerHandles > 0 then
        _P("[BG3SX][Scene.lua] - Scene:CancelAllSoundTimers() - This shouldn't happen anymore, please contact mod author about timerHandles being buggy again")
    end
end


-- Summons/Follower Management
-----------------------------------------------------

--Checks if the summon to hide is a participating entity in any scene
function Scene.ExistsInScene(uuid)
    for _,scene in pairs(Data.SavedScenes) do
        for _,entityUuid in pairs(scene.entities) do
            if entityUuid == uuid then
                return true
            end
        end
    end
    return false
end

function Scene:HideSummons()
    if self.Summons and Table.TableSize(self.Summons) > 0 then
        for entityUuid,summons in pairs(self.Summons) do
            if summons and Table.TableSize(summons) > 0 then
                for _,summon in pairs(summons) do
                    if Scene.ExistsInScene(entityUuid) then
                        Osi.SetVisible(summon, 0)
                    end
                end
            end
        end
    end
end

function Scene:ShowSummons()
    if self.Summons and Table.TableSize(self.Summons) > 0 then
        -- _P("[BG3SX][Scene.lua] - Scene:ShowSummons() - Showing summons for all involved entities")
        -- _D(self.Summons)
        for entityUuid,summons in pairs(self.Summons) do
            -- _P("[BG3SX][Scene.lua] - Scene:ShowSummons() - 1 - Getting summons for entity " .. entityUuid)
            if summons and Table.TableSize(summons) > 0 then
                -- _P("[BG3SX][Scene.lua] - Scene:ShowSummons() - 2 - Iterating summons for entity " .. entityUuid)
                -- _D(summons)
                for _,summon in pairs(summons) do
                    -- _P("[BG3SX][Scene.lua] - Scene:ShowSummons() - 3 - Showing summon " .. summon .. " for entity " .. entityUuid)
                    Osi.SetVisible(summon, 1)
                end
            end
        end
    end
end

function Scene:CleanupSummons()
    if Table.TableSize(self.Summons) > 0 then
        for entityUuid,summons in pairs(self.Summons) do
            for _,summon in pairs(summons) do
                local startLocation
                for _,locationEntry in pairs(self.startLocations) do
                    -- _P("[BG3SX][Scene.lua] - Scene:CleanupSummons() - Checking if locationEntry.entity " .. locationEntry.entity .. " contains entity " .. entityUuid)
                    if Helper.StringContainsOne(Helper.CleanPrefix(locationEntry.entity), entityUuid) then
                        -- _P("[BG3SX][Scene.lua] - Scene:CleanupSummons() - Found start location for summon " .. summon .. " of entity " .. entityUuid)
                        startLocation = locationEntry
                        -- _D(startLocation)
                        break
                    end
                end
                Osi.SetDetached(summon, 0)
                Entity:ToggleWalkThrough(summon)
                Osi.RemoveBoosts(summon, "ActionResourceBlock(Movement)", 0, "", "")
                Osi.TeleportToPosition(summon, startLocation.position[1], startLocation.position[2], startLocation.position[3], "", 0, 0, 0, 0, 1)
            end
        end
        self:ShowSummons() -- Show summons again after teleporting them back to their start locations
        self.Summons = nil
    end
end

-- Gets all summons of involved entities and sets them up
function Scene:SetupAndHideSummons()
    self.Summons = {}
    local partymembers = Ext.Entity.GetAllEntitiesWithComponent("PartyMember")
    for _,entityUuid in pairs(self.entities) do
        if not self.Summons[entityUuid] then
            self.Summons[entityUuid] = {}
        end
        if partymembers and Table.TableSize(partymembers) > 0 then
            for _,potentialSummon in pairs(partymembers) do
                if potentialSummon.IsSummon then
                    local summon = potentialSummon
                    local summonIsInvolved = false
                    for _, entityUuid in pairs(self.entities) do
                        if Helper.StringContainsOne(Helper.CleanPrefix(summon.Uuid.EntityUuid), entityUuid) then
                            summonIsInvolved = true -- Summon is == an involved entity
                        end
                    end
                    if summonIsInvolved == false then -- Only add summons that are not involved in the scene
                        local summoner = summon.IsSummon.field_20 -- or field_8 - of them might be owner and the other one the summoner
                        if Helper.StringContainsOne(Helper.CleanPrefix(entityUuid), summoner.Uuid.EntityUuid) then
                            Osi.SetDetached(summon.Uuid.EntityUuid, 1)
                            Entity:ToggleWalkThrough(summon.Uuid.EntityUuid)
                            Osi.AddBoosts(summon.Uuid.EntityUuid, "ActionResourceBlock(Movement)", "", "")
                            table.insert(self.Summons[entityUuid], summon.Uuid.EntityUuid)
                        end
                    end
                end
            end
        end
    end
    self:HideSummons()
end

function Scene:AppearanceSetup()
    local strippedEQ = {}

    -- Erection Handling
    for _, character in pairs(self.entities) do
        local entity = Ext.Entity.Get(character)

        if self.Type == "NSFW" then
            Genital.GiveSexGenital(entity)
        end

        local stripping = SexUserVars.GetAllowStripping(entity)
        if not (stripping == false) then
            local armorset, equipment, slot = self:Unequip(character)
            strippedEQ[character] = {Armorset = armorset, Equipment = equipment, Slot = slot}
        end
    end
    self.StrippedEQ = strippedEQ
end

function Scene:Unequip(character)
    local armorset = {}
    local equipment = {}
    local slot = {}

    local entity = Ext.Entity.Get(character)
    if not entity then
        Debug.Print("Is not a valid entity " .. character)
    end

    if self.Type == "SFW" then
        if Entity:IsNPC(character) then
        -- NPCs only have slots in their CharacterVisualResourceID
            -- slot = NPC.StripNPC(entity) -- Call on Server
            -- Event.SyncNPCStrip:Broadcast(entity.Uuid.EntityUuid) -- Call on Client
            equipment = Entity.UnequipAllExcept(character, Data.Equipment.ArmourSlots)
        else
            equipment = Entity.UnequipAllExcept(character, Data.Equipment.ArmourSlots)
            armorset = Osi.GetArmourSet(character)
        end

    elseif self.Type == "NSFW" then
        if Entity:IsNPC(character) then
        -- NPCs only have slots in their CharacterVisualResourceID
            slot = NPC.StripNPC(entity) -- Call on Server
            Event.SyncNPCStrip:Broadcast(entity.Uuid.EntityUuid) -- Call on Client
            equipment = Entity:UnequipAll(character)
        else
            equipment = Entity:UnequipAll(character)
            armorset = Osi.GetArmourSet(character)
        end
    end

    return armorset, equipment, slot
end

-- vvvvvv Keep this for whenever IsSummon is replicatable vvvvvv

-- Whenever we can replicate the owner fields we may be able to reuse this party and just replicate the IsSummon component after swapping out the owner
-- local partymembers = Osi.DB_Players:Get(nil)
-- local everyone = Ext.Entity.GetAllEntitiesWithComponent("PartyMember")
-- _P("-----------------------------------------------------")
-- _D(partymembers)

-- _P("---------------------------")
-- for _, entity in ipairs(everyone) do
--     if entity.IsSummon then
--         _P(entity.Uuid.EntityUuid)
--         _D(entity.IsSummon)
--         _P(entity.IsSummon.Owner_M)
--         local owner = entity.IsSummon.Owner_M
--         _P("owner_m: ", owner.Uuid.EntityUuid)
--         local field20 = entity.IsSummon.field_20
--         _P("field_20: ", field20.Uuid.EntityUuid)
--         local field8 = entity.IsSummon.field_8
--         _P("field_8: ", field8.Uuid.EntityUuid)

--         local newOwner = Ext.Entity.Get(partymembers[1][1])
--         _P("newOwner: ", newOwner.Uuid.EntityUuid)

--         entity.IsSummon.field_20 = newOwner
--         _P("field_20: ", field20.Uuid.EntityUuid)
--         entity:Replicate("IsSummon")
--         _P("field_20: ", field20.Uuid.EntityUuid)
--         Osi.SetVisible(entity.Uuid.EntityUuid, 0)
--     end
-- end
-- _P("-----------------------------------------------------")

-- ^^^^^^ Keep this for whenever IsSummon is replicatable ^^^^^^


-- Prop Management
-----------------------------------------------------
function Scene:CreateProps()
    _P("[BG3SX][Scene.lua] - Scene:CreateProps() - Creating props for current animation")
    if self.currentAnimation.Props then
        _P("[BG3SX][Scene.lua] - Scene:CreateProps() - Props found for current animation: " .. #self.currentAnimation.Props)
        for _,animDataProp in pairs(self.currentAnimation.Props) do
            _P("[BG3SX][Scene.lua] - Scene:CreateProps() - Creating prop " .. animDataProp)
            local sceneProp = Osi.CreateAt(animDataProp, self.rootPosition[1], self.rootPosition[2], self.rootPosition[3], 1, 0, "")
            _P("[BG3SX][Scene.lua] - Scene:CreateProps() - Created prop " .. sceneProp)
            Osi.SetMovable(sceneProp,0)
            table.insert(self.props, sceneProp)
        end
    end
end

function Scene:DestroyProps()
    if #self.props > 0 then
        -- _D(self.props)
        for i,sceneProp in ipairs(self.props) do
            -- _D(sceneProp)
            Osi.RequestDelete(sceneProp) -- Check if we need Osi.RequestDeleteTemporary
            table.remove(self.props, i)
            -- _D(self.props)
        end
    end
end
-- Scale Management
-----------------------------------------------------

-- Scale entity for camera
---@param entityUuid string
function Scene:ScaleEntity(entityUuid)
    local startScale = Entity:TryGetEntityValue(entityUuid, nil, {"GameObjectVisual", "Scale"})
    table.insert(self.entityScales, {entity = entityUuid, scale = startScale})
    Entity:Scale(entityUuid, 0.5)
end

----------------------------------------------------------------------------------------------------
-- 
-- 									 Scene initilization
-- 
----------------------------------------------------------------------------------------------------

-- Initializes the actor
function Scene:Init()
-- initialize = function(scene)
    table.insert(Data.SavedScenes, self)
    Ext.ModEvents.BG3SX.SceneInit:Throw({self})

    --print("all saved scenes")
    --for _, scene in pairs(Data.SavedScenes) do
       -- _D(scene.entities)
    --end

    if self.Type == "SFW" then
        if Table.TableSize(self.entities) == 1 then
            self.SceneType = "Solo"
        elseif Table.TableSize(self.entities) == 2 then
            self.SceneType = "Paired"
        end
    end

    -- print("initializing scene")

    setStartLocations(self) -- Save start location of each entity to later teleport them back
    saveCampFlags(self) -- Saves which entities had campflags applied before
    self:SetupAndHideSummons() -- Hides summons and removes collision - on Scene:Destroy() it also teleports them back to start location
    self:AppearanceSetup()


    -- We do this before in a seperate loop to already apply this to all entities (-- old stuff -> before actors are spawned one by one)
    for _, character in pairs(self.entities) do
        Entity:ClearActionQueue(character)
        Osi.AddBoosts(character, "ActionResourceBlock(Movement)", "", "") -- Blocks movement
        Osi.ApplyStatus(character, "BG3SX_DisableAI", -1, 1, "")
        -- Osi.SetDetached(character, 1) -- Make entity untargetable
        if Osi.CanJoinCombat(character) == 1 then
            table.insert(self.CouldJoinCombat, character) -- Save if entity was allowed to join combat before
        end
        if Osi.IsOnStage(character) == 1 then
            -- table.insert(scene.WasOnStage, character) -- Save if entity was on stage before
        end
        -- Osi.SetOnStage(character, 0) -- to disable AI
        Osi.SetCanJoinCombat(character, 0) -- Disable combat
        Osi.DetachFromPartyGroup(character)        -- Detach from party to stop party members from following
        --self:DetachSummons(entity) -- TODO: Add something to handle summon/follower movement here
        -- Osi.SetVisible(entity, 0)               -- 0 = Invisible
        Entity:ToggleWalkThrough(character)        -- To prevent interactions with other entities even while invisible and untargetable
        self:ToggleCampFlags(character)            -- Toggles camp flags so companions don't return to tents

        if BG3AFActive then
            BG3AF.TemplateAnimationSetOverride.Get(character):AddSets(ModuleUUID, Data.AnimationSets)
        end
    end

        -- TODO - why do we wait?
        local baselineRotation = self.startLocations[1].rotation
        Ext.Timer.WaitFor(200, function ()
            -- Teleport all characters to root position
            for _, character in pairs(self.entities) do
                Event.RequestTeleport:Broadcast({character = character, target = self.rootPosition})
            end
            
            -- Set BOTH characters to be rotated in the SAME world direction
            -- This gives animations a baseline for their Root_M baked in rotation offsets
            for _, character in pairs(self.entities) do
                Event.RequestRotation:Broadcast({character = character, target = baselineRotation})
            end
        end)

        --Osi.TeleportToPosition(entity, self.rootPosition.x, self.rootPosition.y, self.rootPosition.z) -- now handled correctly in actor initialization

        --local startLocation = self.startLocations[1]
        --Entity:RotateEntity(entity, startLocation.rotationHelper)


    -- for _, entity in pairs(self.entities) do
    --     table.insert(self.actors, Actor:new(entity))
    --     self:ScaleEntity(entity) -- After creating the actor to not create one with a smaller scale
    -- end

    if self.Type == "NSFW" then
        if self.SceneType == "MasturbateMale" or self.SceneType == "MasturbateFemale" then
        elseif self.SceneType == "Straight" then -- Handle this in a different way to enable actor swapping even for straight animations

            -- In case of actor1 not being male, swap them around to still assign correct animations initially
            if not Entity:HasPenis(self.entities[1]) then
                local savedActor = self.entities[1]
                self.entities[1] = self.entities[2]
                self.entities[2] = savedActor
            end
        end
    end

    -- _D(self)
    Event.NewScene:Broadcast(self)
    Ext.ModEvents.BG3SX.SceneCreated:Throw({self})
end

-- If no entities are passed, use the scenes entities so it can be used even without a scene
---@param duration number - Duration of the fade effect
---@param entities table|nil - Table of entities to apply the fade effect to, if not passed it will use the scenes entities
function Scene:ScreenFade(duration, entities)
    local entities = entities or self.entities
    for _,character in pairs(entities) do
        if Entity:IsPlayable(character) then
            Effect:Fade(character, duration)
        end
    end    
end

----------------------------------------------------------------------------------------------------
-- 
-- 										During Scene
-- 
----------------------------------------------------------------------------------------------------

-- Teleports any entity/actor/props to a new location
---@param entity        string    - The caster of the spell and entity to check which scene belongs to them
---@param newLocation   table   - The new location
function Scene:MoveSceneToLocation(newLocation)

    local oldLocation = self.rootPosition -- Only used for Event payload
    self.rootPosition = newLocation -- Always update rootPosition of a scene after changing it

    for _, character in ipairs(self.entities) do

        -- Keep this in case we want to re-enable a maximum allowed distance to teleport
        ---------------------------------------------------------------------------------------
        -- Do nothing if the new location is too far from the caster's start position,
        -- so players would not abuse it to get to some "no no" places.
        -- local dx = newLocation.x - actor.position.x -- get the difference per axis
        -- local dy = newLocation.y - actor.position.y
        -- local dz = newLocation.z - actor.position.z
        -- if math.sqrt(dx * dx + dy * dy + dz * dz) >= 4 then -- if difference is greater than 4 units
        --     return
        -- end
        ---------------------------------------------------------------------------------------

        Event.RequestTeleport:Broadcast({character = character, target = newLocation})
    end

        if #self.props > 0 then
            for _, prop in pairs(self.props) do
                Event.RequestTeleport:Broadcast({character = prop, target = newLocation})
            end
        end


    --scene:CancelAllSoundTimers() -- Cancel all currently saved soundTimers to not get overlapping sounds
    --Sex:PlayAnimation(entity, self.currentAnimation) -- Play prior animation again

    Ext.ModEvents.BG3SX.SceneMove:Throw({scene = self, oldLoca = oldLocation, newLoca = newLocation})
end


-- Rotates a scene by creating an invisible helper the actors can steer to
---@param caster any
---@param location any
function Scene:RotateScene(location)
    -- print("called rotate scene")

    for _, character in pairs(self.entities) do
        Event.RequestRotation:Broadcast({character = character, target = location})
    end

    -- TODO - probably not required whenb using Nosi 
    --self:CancelAllSoundTimers() -- Cancel all currently saved soundTimers to not get overlapping sounds
    --Sex:PlayAnimation(character, self.currentAnimation) -- Play prior animation again
end

function Scene:StopAnimation()
    for _, char in pairs (self.entities) do
        Osi.StopAnimation(char,1)
    end
end

function Scene:TogglePause()
    if not self.Paused then
        for _,character in pairs(self.entities) do
            Osi.PlayLoopingAnimation(character, "", "", "", "", "", "", "")
            -- Osi.PlayAnimation(character, "379d4f19-68df-61be-a802-9db20f5aa872", "") -- This animation bank id apparently pauses the animation
        end
        self.Paused = true
    elseif self.Paused == true then
        self:PlayAnimation(self.currentAnimation)
    end
end

function Scene:PlayAnimation(animationData)
    local animDataParent = Data.GetAnimDataParent(animationData)
    if animDataParent then
        for _, char in pairs (self.entities) do
            Animation:New(char, animDataParent[animationData.Mod][animationData.Name])

            -- Only start sound timers if none are running yet
            if animDataParent[animationData.Mod][animationData.Name].Sound == true then
                if #self.timerHandles == 0 then
                    -- No sounds running yet, start them
                    Sound:New(char, animDataParent[animationData.Mod][animationData.Name])
                end
                -- If sounds are already running, they'll automatically pick up the new animation's sounds on next loop
            end
        end

        self.Paused = false

        -- Prop handling
        if animationData ~= self.currentAnimation then
            -- If animation is not the same as before save the new animationData table to the scene to use for prop management, teleporting or rotating
            self.currentAnimation = animationData
            self:DestroyProps() -- Props rely on scene.currentAnimation
            self:CreateProps()
        end
        self.currentAnimation = animDataParent[animationData.Mod][animationData.Name]
    end
end

----------------------------------------------------------------------------------------------------
-- 
-- 										Scene Stop
-- 
----------------------------------------------------------------------------------------------------

-- Handles the generic stuff to reset on an entity on Scene:Destroy()
function Scene:EntityReset()
    for _,character in pairs(self.entities) do
        -- dress them
        -- give out of scene genitals back
        local entity = Ext.Entity.Get(character)
        if not entity then
            -- Debug.Print("is not a valid entity ".. character)
        end

        if self.Type == "NSFW" then
            if Entity:IsNPC(character) then
                _P("Removing genitals from NPC " .. character)
                NPC.RemoveGenitals(entity) -- Remove genitals from NPCs
            else
                local outOfSexGenital = SexUserVars.GetGenital("BG3SX_OutOfSexGenital", entity)
                Genital.OverrideGenital(outOfSexGenital, entity)
            end
        end
        if Entity:IsNPC(character) then
            NPC.Redress(entity, self.StrippedEQ[character].Slot)
        end
        Entity:Redress(character, self.StrippedEQ[character])

        local startLocation
        for _, entry in ipairs(self.startLocations) do
            if entry.entity == character then
                startLocation = entry
            end
        end

        -- print("teleporting ", character , " to the startposition ", startLocation.position[1], startLocation.position[2],startLocation.position[3] )

        Event.RequestTeleport:Broadcast({character = character, target = {startLocation.position[1], startLocation.position[2], startLocation.position[3]}})
        Event.RequestRotation:Broadcast({character = character, target = startLocation.rotation})

        Osi.RemoveBoosts(character, "ActionResourceBlock(Movement)", 0, "", "") -- Unlocks movement
        Osi.RemoveStatus(character, "BG3SX_DisableAI", "") -- Unlocks AI

        self:ToggleCampFlags(character) -- Toggles camp flags so companions return to tents IF they had them before

        -- Re-attach entity to make it selectable again
        Osi.SetDetached(character, 0)
        if Table.Contains(self.CouldJoinCombat, character) then -- Check if entity was allowed combat before
            Osi.SetCanJoinCombat(character, 1) -- Re-enable combat
        end
        if Table.Contains(self.WasOnStage, character) then -- Check if entity was on stage before
            -- Osi.SetOnStage(character, 1) -- Re-enable AI
        end

        local nothing = "88f5df46-921d-4a28-93b6-202df636966c" -- Random UUID - This is nothing, NULL or "" doesn't work, crashes the game.
        Osi.PlayAnimation(character, nothing) -- To cancel out of any ongoing animations -- TODO: Make this into its own function like Animation.Cancel()
        if self.Type == "NSFW" then
            Osi.PlaySound(character, Data.Sounds.Orgasm[math.random(1, #Data.Sounds.Orgasm)])
        end
        
        if BG3AFActive then
            BG3AF.TemplateAnimationSetOverride.Get(character):RemoveSets(ModuleUUID, Data.AnimationSets)
        end
    end
end


-- Destroys a scene instance
function Scene:Destroy()
    self:CancelAllSoundTimers()
    self:DestroyProps()
    self:CleanupSummons()
    self:EntityReset()

    for i,scene in ipairs(Data.SavedScenes) do
        if scene == self then
            table.remove(Data.SavedScenes, i)
        end
    end
    Event.SyncActiveScenes:Broadcast(Data.SavedScenes)

    local uuid = self.Uuid
    self = nil
    Ext.ModEvents.BG3SX.SceneDestroyed:Throw(uuid)
end

-- Terminates all running scenes
function Scene.DestroyAllScenes()
    if Data.SavedScenes and #Data.SavedScenes > 0 then
        for i = #Data.SavedScenes, 1, -1 do
            local scene = Data.SavedScenes[i]
            scene:Destroy()
        end
    end
    -- Event.DestroyAllSceneControls:Broadcast()
end
--ConsoleCommand.New(Scene.DestroyAllScenes, "Terminates all Scenes")
ConsoleCommand.New("DestroyAllScenes", Scene.DestroyAllScenes, "Destroys all ongoing scenes") -- Killswitch
Event.DestroyAllScenes:SetHandler(function ()
    Scene.DestroyAllScenes()
end)


function Scene:SwapPosition()
    if Helper.StringContainsOne(self.entities[1], self.entities[2]) then
        Debug.Print("Swapping positiong during Solo-Scene is not possible.")
        return
    else
        if self.UnlockedSwaps or (Entity:HasPenis(self.entities[1]) == Entity:HasPenis(self.entities[2])) then
            _P("SWAPPI")
            local savedActor = self.entities[1]

            Ext.ModEvents.BG3SX.SceneSwitchPlacesBefore:Throw({self.entities})


            self.entities[1] = self.entities[2]
            self.entities[2] = savedActor

            Ext.ModEvents.BG3SX.SceneSwitchPlacesAfter:Throw({self.entities})

            --self:CancelAllSoundTimers() -- no longer needed
            -- Sounds will automatically adapt on next loop


            self:PlayAnimation(self.currentAnimation)
            -- Sex:PlayAnimation(savedActor, self.currentAnimation)
        end
    end
end

function Scene:ReplicationAnimationResetCheck()
    local count = 0
    if self.ReplicatedWaterfalls then
        for uuid, bool in pairs(self.ReplicatedWaterfalls) do
            if bool then
                count = count + 1
            end
        end
    end
    if count == #self.entities then
        for _,entity in pairs(self.entities) do
            Animation.ResetAnimation(entity)
        end
        self.ReplicatedWaterfalls = nil
    end
end