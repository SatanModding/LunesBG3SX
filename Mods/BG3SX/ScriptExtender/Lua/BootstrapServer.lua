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




-- If I don't define this, the console yells at me
ModuleUUID = "df8b9877-5662-4411-9d08-9ee2ec4d8d9e" 


-- USers can set whether they want to "unlock" all animations
-- or only use "genital based" ones
-- This means that 2 characters with penises will have accesss
-- to the "lesbian" animations like "grinding", or "eating pussy" 


Ext.Vars.RegisterModVariable(ModuleUUID, "BG3SX_ShowAllAnimations", {
    Server = true, Client = true, SyncToClient = true
})



local function OnSessionLoaded()


        local vars = Ext.Vars.GetModVariables(ModuleUUID)


        print(vars)



        if not vars.BG3SX_ShowAllAnimations then
        print("BG3SX_ShowAllAnimations mod variable not initialized yet")
        print("setting it to default value = false")
        vars.BG3SX_ShowAllAnimations = "false"
        end

        Ext.Log.Print("BG3SX_ShowAllAnimations")
        Ext.Log.Print(vars.BG3SX_ShowAllAnimations)
        Ext.Log.Print("End BG3SX_ShowAllAnimations")


        Ext.Vars.SyncModVariables(ModuleUUID)

        
end


Ext.Events.SessionLoaded:Subscribe(OnSessionLoaded)
