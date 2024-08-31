------------------------------------
        -- Init Classes --
------------------------------------

-- Pre-Construct our classes
Ext.Require("Server/_constructor.lua")

-- Initialize Data Tables
Ext.Require("Shared/Data/_init.lua")

-- Initialize Utils
Ext.Require("Shared/Utils/_init.lua")

-- Initialize Sex Classes
Ext.Require("Server/Classes/Sex/_init.lua")

-- Initialize General Classes
Ext.Require("Server/Classes/_init.lua")

-- Initiliaze Listeners
Ext.Require("Server/Listeners/_init.lua")

------------------------------------
        -- Mod Events --
------------------------------------
-- These might change with future versions

-- Available Events to listen to:
------------------------------------------------------------------------------------------------------------------------------------------------
-- "Channel" (Event Name)                                   - Payload Info                              - Where it Triggers

Ext.RegisterModEvent("BG3SX", "SexStartSpellUsed")          --{caster, target, spellData}             - SexListeners.lua
Ext.RegisterModEvent("BG3SX", "SexAnimationChange")         --{caster, animationData}                 - SexListeners.lua
Ext.RegisterModEvent("BG3SX", "SceneInit")                  --{newScene}                                - Scene.lua
Ext.RegisterModEvent("BG3SX", "SceneCreated")               --{newScene}                                - Scene.lua
Ext.RegisterModEvent("BG3SX", "ActorInit")                  --{newActor}                                - Actor.lua
Ext.RegisterModEvent("BG3SX", "ActorCreated")               --{newActor}                                - Actor.lua
Ext.RegisterModEvent("BG3SX", "AnimationChange")            --{newAnimation}                            - Animation.lua
Ext.RegisterModEvent("BG3SX", "SoundChange")                --{newSound}                                - Sound.lua
Ext.RegisterModEvent("BG3SX", "SceneMove")                  --{scene, oldLocation, newlocation}       - Scene.lua
Ext.RegisterModEvent("BG3SX", "SceneSwitchPlacesBefore")    --{scene.actors}                            - Scene.lua
Ext.RegisterModEvent("BG3SX", "SceneSwitchPlacesAfter")     --{scene.actors}                            - Scene.lua
Ext.RegisterModEvent("BG3SX", "CameraHeightChange")         --{uuid}                                    - Sex.lua
-- [NYI] Ext.RegisterModEvent("BG3SX", "EntityStripped")             --{entity, strippedEquipment, remainingEquipment}    - Actor.lua
Ext.RegisterModEvent("BG3SX", "ActorDressed")               --{actor, equipmentTable}                 - Actor.lua
Ext.RegisterModEvent("BG3SX", "GenitalChange")              --{entity, newGenital}                    - Genital.lua

-- Clientside NPC Template functions need to be handled via NetMessages, not ModEvents - Please look at Client/NPCSync.lua
-- Ext.RegisterModEvent("BG3SX", "NPCStrip")                   --({naked = naked, resource = resource})    - NPCStripping.lua
-- Ext.RegisterModEvent("BG3SX", "NPCDress")                   --({dressed = dressed, resource = resource})- NPCStripping.lua

-- To subscribe to events:
-- ----------------------------------------------------------------------------------------------------------------------------------------------

-- Ext.ModEvents.BG3SX.Channel:Subscribe(function (payload) ... end)

-- Example:
-- -----------------------------------------------------------------
-- Ext.ModEvents.BG3SX.SceneInit:Subscribe(function (payload)
--     _P("SceneInit received with PayLoad: ")
--     _D(payload)
-- end)

-- Or check ModEventsTester.lua