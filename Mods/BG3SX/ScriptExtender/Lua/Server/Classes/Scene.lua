----------------------------------------------------------------------------------------
--
--                               For handling Scenes
--
----------------------------------------------------------------------------------------

Data.SavedScenes = {}

local initialize

-- CONSTRUCTOR
--------------------------------------------------------------

-- Todo: Check if it requires cleanup of unused parameters
---@class Scene
---@param entities          table   - Table with entity uuids to use for a scene
---@param rootPosition      table   - Table of x,y,z coordinates
---@param rotation          table   - Table with x,y,z,w 
---@param startLocations    table   - Saves the start locations (Position/Rotation) of each entity to teleport back to when scene is destroyed
---@param entityScales      table   - Saves the start entity scales
---@param currentAnimation  table   - Table of the current animation being played
---@param currentSounds     table   - Table of currently playing sounds
---@param timerHandles      table   - Timer handles in case they have to be cancelled (failsave)
---@param cameraZoom        table   - Unused - Was intended to store previous zoom levels per entity - handled differently now
---@param props             table   - Table of all props currently in a scene
---@param switchPlaces      boolean - Boolean for PlayAnimation to check if actors have been switched - TODO: need a cleaner way to handle this
---@param campFlags         table   - Table of entities with campflags applied before scene to reapply on Destroy() - Ignore those who didn't - PleaseStay Mod compatibility
---@paran summons           table   - Table of summons saved per involved entity
---@param equipment         table   - Table of [uuid] of entity and a table of their equipment
---@param armorset          table   - Table of [uuid] of entity and a table of their armorset
---@param slots             table   - Format: {uuid = entry.VisualResource, index = i} 
function Scene:new(entities, equipment, armorset, slots)
    local instance      = setmetatable({
        entities        = entities,
        rootPosition    = {},
        rotation        = {},
        startLocations  = {}, -- NEVER change this after initialize - Used to teleport everyone back on Scene:Destroy()
        entityScales    = {},
        currentAnimation= {},
        currentSounds   = {},
        timerHandles    = {},
        cameraZoom      = {},
        props           = {},
        campFlags       = {},
        summons         = {},
        equipment       = equipment,
        armorset        = armorset,
        slots           = slots,
        UnlockedSwaps   = false,
        CouldJoinCombat = {},
        WasOnStage      = {},
    }, Scene)


    -- Somehow can't set rootPosition/rotation within the metatable construction, it poops itself trying to do this - rootPosition.x, rootPosition.y, rootPosition.z = Osi.GetPosition(entities[1])
    
    --local position = entities[1].Transfrom.Transform.Translate
    --instance.rootPosition.x, instance.rootPosition.y, instance.rootPosition.z = position[1], position[2], position[3]
    --local rotation = entities[1].Transfrom.Transform.RotationQuat
    --.rotation.x, instance.rotation.y, instance.rotation.z, instance.rotation.w = rotation[1],rotation[2],rotation[3],rotation[4]

    instance.SceneType = Sex:DetermineSceneType(instance)

    initialize(instance)

    return instance
end


-- Something crashes when starting a scene

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
---@param entityToSearch uuid
function Scene:FindSceneByEntity(entityToSearch)
    -- _P(entityToSearch)
    for i, scene in ipairs(Data.SavedScenes) do
        for _, entity in pairs(scene.entities) do
            if Helper.StringContains(entityToSearch, entity) then
                -- _D(scene)
                return scene
            end
        end
    end
    -- _P("[BG3SX][Scene.lua] - Scene:FindSceneByEntity - Entity not found in any existing scenes! This shouldn't happen anymore. Contact mod author about what you did.")
end

-- Returns all entities (parents) from a scene
---@param sceneToSearch Scene
function Scene:EntitiesByScene(sceneToSearch)
    return sceneToSearch.entities
    -- _P("[BG3SX][Scene.lua] - Scene:FindSceneByEntity - Entity not found in any existing scenes! This shouldn't happen anymore. Contact mod author about what you did.")
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
        for _,entity in pairs(scene.entities) do
            if entity == uuid then
                return false
            end
        end
    end
    return true
end

function Scene:HideSummons()
    for _,entry in pairs(self.summons) do
        if Scene.ExistsInScene(entry.summon.Uuid.EntityUuid) then

        end
    end 
end

-- TODO: See if we can squish it a bit
-- Toggles visibility of all summons of entities involved in a scene
function Scene:ToggleSummonVisibility()
    if #self.summons > 0 then
        -- _P("Setting summon entries visible")
        for _,entry in pairs(self.summons) do
            local entity = entry.entity
            local summon = entry.summon
            local startLocation
            for _,locationEntry in pairs(self.startLocations) do
                -- _D(self.startLocations)
                -- _P(locationEntry.entity)
                -- _P(entity.Uuid.EntityUuid)
                local locationEntity = Ext.Entity.Get(locationEntry.entity)

                if locationEntity.Uuid.EntityUuid == entity.Uuid.EntityUuid then
                    -- _P("iteration entity == entity")
                    startLocation = locationEntry
                    -- _D(startLocation)
                end
            end
            Osi.SetDetached(summon.Uuid.EntityUuid, 0)
            Osi.SetVisible(summon.Uuid.EntityUuid, 1)
            Entity:ToggleWalkThrough(summon.Uuid.EntityUuid)
            Osi.RemoveBoosts(summon.Uuid.EntityUuid, "ActionResourceBlock(Movement)", 0, "", "")
            Osi.TeleportToPosition(summon.Uuid.EntityUuid, startLocation.position.x, startLocation.position.y, startLocation.position.z, "", 0, 0, 0, 0, 1)
        end
        self.summons = {}
    else
        -- _P("Setting summons invisible and adding them to scene.summons")
        for _,entry in pairs(self.entities) do
            local entity = Ext.Entity.Get(entry)
            local partymembers = Ext.Entity.GetAllEntitiesWithComponent("PartyMember")
            for _,potentialSummon in pairs(partymembers) do
                if potentialSummon.IsSummon then
                    local summon = potentialSummon
                    local summoner = summon.IsSummon.field_20 -- or field_8 - of them might be owner and the other one the summoner
                    -- _P("Entity: ", entity, " with uuid: ", entity.Uuid.EntityUuid)
                    -- _P("Summon: ", summon, " with uuid: ", summon.Uuid.EntityUuid)
                    -- _P("Summoner: ", summoner, " with uuid: ", summoner.Uuid.EntityUuid)
                    if summoner.Uuid.EntityUuid == entity.Uuid.EntityUuid then
                        -- _P("Making ", summon.Uuid.EntityUuid, " invisible")
                        Osi.SetDetached(summon.Uuid.EntityUuid, 1)
                        Osi.SetVisible(summon.Uuid.EntityUuid, 0)
                        Entity:ToggleWalkThrough(summon.Uuid.EntityUuid)
                        Osi.AddBoosts(summon.Uuid.EntityUuid, "ActionResourceBlock(Movement)", "", "")
                        table.insert(self.summons, {entity = entity, summon = summon})
                    end
                end
            end
        end
    end
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
    if self.currentAnimation.Props then
        for _,animDataProp in pairs(self.currentAnimation.Props) do
            local sceneProp = Osi.CreateAt(animDataProp, self.rootPosition.x, self.rootPosition.y, self.rootPosition.z, 1, 0, "")
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
---@param entity uuid
function Scene:ScaleEntity(entity)
    local startScale = Entity:TryGetEntityValue(entity, nil, {"GameObjectVisual", "Scale"})
    table.insert(self.entityScales, {entity = entity, scale = startScale})
    Entity:Scale(entity, 0.5)
end

----------------------------------------------------------------------------------------------------
-- 
-- 									 Scene initilization
-- 
----------------------------------------------------------------------------------------------------

-- Initializes the actor
---@param self instance - The scene instance
initialize = function(scene)
    table.insert(Data.SavedScenes, scene)
    Ext.ModEvents.BG3SX.SceneInit:Throw({scene})

    --print("all saved scenes")
    --for _, scene in pairs(Data.SavedScenes) do
       -- _D(scene.entities)
    --end
  


    -- print("initializing scene")

    setStartLocations(scene) -- Save start location of each entity to later teleport them back
    saveCampFlags(scene) -- Saves which entities had campflags applied before
    scene:ToggleSummonVisibility() -- Toggles summon visibility and collision - on Scene:Destroy() it also teleports them back to start location


    -- We do this before in a seperate loop to already apply this to all entities before actors are spawned one by one
    for _, character in pairs(scene.entities) do
        Osi.AddBoosts(character, "ActionResourceBlock(Movement)", "", "") -- Blocks movement
        Osi.ApplyStatus(character, "BG3SX_DisableAI", -1, 1, "")
        -- Osi.SetDetached(character, 1) -- Make entity untargetable
        if Osi.CanJoinCombat(character) == 1 then
            table.insert(scene.CouldJoinCombat, character) -- Save if entity was allowed to join combat before
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
        scene:ToggleCampFlags(character)            -- Toggles camp flags so companions don't return to tents
    
        --Data.AnimationSets.AddSetToEntity(entity, Data.AnimationSets["BG3SX_Body"])
        --Data.AnimationSets.AddSetToEntity(entity, Data.AnimationSets["BG3SX_Face"])
    end

        -- TODO - why do we wait?
        Ext.Timer.WaitFor(200, function ()
            -- print("requesting teleport")
            for _, character in pairs(scene.entities) do
                Event.RequestTeleport:Broadcast({character= character, target = scene.entities[1]})
                Event.RequestRotation:Broadcast({character = character, target = scene.entities[1]})
            end
        end)
        
        --Osi.TeleportToPosition(entity, self.rootPosition.x, self.rootPosition.y, self.rootPosition.z) -- now handled correctly in actor initialization
        
        --local startLocation = self.startLocations[1]
        --Entity:RotateEntity(entity, startLocation.rotationHelper)
       

    -- for _, entity in pairs(self.entities) do
    --     table.insert(self.actors, Actor:new(entity))
    --     self:ScaleEntity(entity) -- After creating the actor to not create one with a smaller scale
    -- end

    if scene.SceneType == "MasturbateMale" or scene.SceneType == "MasturbateFemale" then
    elseif scene.SceneType == "Straight" then -- Handle this in a different way to enable actor swapping even for straight animations
        
        -- In case of actor1 not being male, swap them around to still assign correct animations initially
        if not Entity:HasPenis(scene.entities[1]) then
            local savedActor = scene.entities[1]
            scene.entities[1] = scene.entities[2]
            scene.entities[2] = savedActor
        end
    end

    Event.NewScene:Broadcast(scene)
    Ext.ModEvents.BG3SX.SceneCreated:Throw({scene})
end

---@param object GUIDSTRING
---@param status string
---@param causee GUIDSTRING
---@param storyActionID integer
function OnStatusApplied(object, status, causee, storyActionID)
    if status == "BG3SX_DisableAI" then
        _P("Applied status " .. status .. " to " .. object)
    end
end
Ext.Osiris.RegisterListener("StatusApplied", 4, "after", OnStatusApplied)


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
    -- Debug.DumpS(animDataParent)
    if animDataParent then
        for _, char in pairs (self.entities) do
            Animation:New(char, animDataParent[animationData.Mod][animationData.Name])

            -- Only play sound if is enabled for a given animation entry
            if animDataParent[animationData.Mod][animationData.Name].Sound == true then
                Sound:New(char, animDataParent[animationData.Mod][animationData.Name])
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
local function sceneEntityReset(character)
    -- dress them
    -- give out of scene genitals back
    local entity = Ext.Entity.Get(character)
    if not entity then
        -- Debug.Print("is not a valid entity ".. character)
    end

    -- Debug.Print("Scene reset for character " .. character)
    local outOfSexGenital = SexUserVars.GetGenital("BG3SX_OutOfSexGenital", entity)
    local scene = Scene:FindSceneByEntity(character)
    local startLocation

    
    Entity:Redress(character, scene.armorset[character], scene.equipment[character], scene.slots[character])
    
    --print("Out of sex genital is ", outOfSexGenital)
    Genital.OverrideGenital(outOfSexGenital, entity)

    -- Getting old position
    -- print("all startLoctions")
    -- _D(scene.startLocations)

    for _, entry in ipairs(scene.startLocations) do
        if entry.entity == character then
            startLocation = entry
        end
    end

    -- print("teleporting ", character , " to the startposition ", startLocation.position[1], startLocation.position[2],startLocation.position[3] )

    Event.RequestTeleport:Broadcast({character = character, target = {startLocation.position[1], startLocation.position[2], startLocation.position[3]}})
    Event.RequestRotation:Broadcast({character = character, target = startLocation.rotation})

    Osi.RemoveBoosts(character, "ActionResourceBlock(Movement)", 0, "", "") -- Unlocks movement
    Osi.RemoveStatus(character, "BG3SX_DisableAI", "") -- Unlocks AI

    scene:ToggleCampFlags(character) -- Toggles camp flags so companions return to tents IF they had them before
    
    -- Re-attach entity to make it selectable again
    Osi.SetDetached(character, 0)
    if Table.Contains(scene.CouldJoinCombat, character) then -- Check if entity was allowed combat before
        Osi.SetCanJoinCombat(character, 1) -- Re-enable combat
    end
    if Table.Contains(scene.WasOnStage, character) then -- Check if entity was on stage before
        -- Osi.SetOnStage(character, 1) -- Re-enable AI
    end

    -- local animationWaterfall = Mods.BG3AF.AnimationWaterfall.Get(character)
    -- animationWaterfall:RemoveWaterfallElement(Data.AnimationSets["BG3SX_Body"].Uuid)
end


-- Destroys a scene instance
function Scene:Destroy()
    self:CancelAllSoundTimers()
    self:DestroyProps()
    self:ToggleSummonVisibility()
    
    -- self:StopAnimation() -- maybe use this new function instead of playing a "nothing" animation
    for _, entity in pairs(self.entities) do
    
        sceneEntityReset(entity)
        
        local nothing = "88f5df46-921d-4a28-93b6-202df636966c" -- Random UUID - This is nothing, NULL or "" doesn't work, crashes the game.
        Osi.PlayAnimation(entity, nothing) -- To cancel out of any ongoing animations
        Osi.PlaySound(entity, Data.Sounds.Orgasm[math.random(1, #Data.Sounds.Orgasm)]) -- TODO - change this to a generic sound for when we use this for non-sex instead

        if Entity:IsNPC(entity) then
            NPC.RemoveGenitals(entity)
        end
    end
    
    Event.SyncActiveScenes:Broadcast(self)
    Ext.ModEvents.BG3SX.SceneDestroyed:Throw({self})

    for i,scene in ipairs(Data.SavedScenes) do
        if scene == self then
            table.remove(Data.SavedScenes, i)
        end
    end
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
            
            self:CancelAllSoundTimers() -- Cancel all currently saved soundTimers to not get overlapping sounds
            
            
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