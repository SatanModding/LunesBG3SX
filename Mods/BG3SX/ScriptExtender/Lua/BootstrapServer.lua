------------------------------------
        -- Init Classes --
------------------------------------


-- Pre-Construct our classes
Ext.Require("Shared/_constructor.lua")

-- Initialize Data Tables
Ext.Require("Shared/_initData.lua")

-- Initialize Utils
Ext.Require("Shared/_initUtils.lua")

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

Ext.RegisterModEvent("BG3SX", "StartSexSpellUsed")          --{caster, target, spellData}               - SexListeners.lua
Ext.RegisterModEvent("BG3SX", "SexAnimationChange")         --{caster, animData}                        - SexListeners.lua
Ext.RegisterModEvent("BG3SX", "SceneInit")                  --{scene}                                   - Scene.lua
Ext.RegisterModEvent("BG3SX", "SceneCreated")               --{scene}                                   - Scene.lua
Ext.RegisterModEvent("BG3SX", "SceneDestroyed")             --{scene}                                   - Scene.lua
Ext.RegisterModEvent("BG3SX", "SceneMove")                  --{scene, oldLocation, newlocation}         - Scene.lua
Ext.RegisterModEvent("BG3SX", "ActorInit")                  --{actor}                                   - Actor.lua
Ext.RegisterModEvent("BG3SX", "ActorCreated")               --{actor}                                   - Actor.lua
Ext.RegisterModEvent("BG3SX", "AnimationChange")            --{newAnimation}                            - Animation.lua
Ext.RegisterModEvent("BG3SX", "SoundChange")                --{newSound}                                - Sound.lua
Ext.RegisterModEvent("BG3SX", "SceneSwitchPlacesBefore")    --{scene.actors}                            - Scene.lua
Ext.RegisterModEvent("BG3SX", "SceneSwitchPlacesAfter")     --{scene.actors}                            - Scene.lua
Ext.RegisterModEvent("BG3SX", "CameraHeightChange")         --{uuid}                                    - Sex.lua
Ext.RegisterModEvent("BG3SX", "ActorDressed")               --{uuid, equipment}                         - Actor.lua
Ext.RegisterModEvent("BG3SX", "GenitalChange")              --{uuid, newGenital}                        - Genital.lua

-- Clientside NPC Template functions need to be handled via NetMessages, not ModEvents - Please look at Client/NPCSync.lua
-- Ext.RegisterModEvent("BG3SX", "NPCStrip")                   --({naked = naked, resource = resource})    - NPCStripping.lua
-- Ext.RegisterModEvent("BG3SX", "NPCDress")                   --({dressed = dressed, resource = resource})- NPCStripping.lua

-- To subscribe to events:
------------------------------------------------------------------------------------------------------------------------------------------------

-- Ext.ModEvents.BG3SX.Channel:Subscribe(function (payload) ... end)

-- Example:
-------------------------------------------------------------------
-- Ext.ModEvents.BG3SX.ActorDressed:Subscribe(function (e)
--     _P("ActorDressed received with PayLoad: ")
--     _D(e) -- Dumps the entire payload
-- end)

-- Or check ModEventsTester.lua





-- Muffin stats loader


-- local modPath = 'Public/RunesOfFaerun/Stats/Generated/Data/'
-- local filesToReload = {
--     'Character.txt',
--     'Object.txt',
--     'Passive.txt',
--     'Projectile.txt',
--     'Shout.txt',
--     'Status.txt',
--     'Target.txt',
-- }

-- local function OnReset()
--     if filesToReload and #filesToReload then
--         for _, filename in pairs(filesToReload) do
--             if filename then
--                 local filePath = string.format('%s%s', modPath, filename)
--                 if string.len(filename) > 0 then
--                     Debug(string.format('RELOADING %s', filePath))
--                     ---@diagnostic disable-next-line: undefined-field
--                     Ext.Stats.LoadStatsFile(filePath, false)
--                 else
--                     Critical(string.format('Invalid file: %s', filePath))
--                 end
--             end
--         end
--     end
-- end

-- Ext.Events.ResetCompleted:Subscribe(OnReset)



Ext.Timer.WaitFor(500, function ()
        print("test channel dumpy")
        _D(TEST_CHANNEL)

        TEST_CHANNEL:SetHandler(function (msg) 
                print("message received ", msg) 
        
        end)

        
end)


