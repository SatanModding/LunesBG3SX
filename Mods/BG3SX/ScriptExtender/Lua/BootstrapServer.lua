-- If I don't define this, the console yells at me
ModuleUUID = "df8b9877-5662-4411-9d08-9ee2ec4d8d9e"

BG3AFActive = Mods and Mods.BG3AF

------------------------------------
        -- Init Classes --
------------------------------------

-- Pre-Construct our classes
Ext.Require("Shared/_constructor.lua")

-- Initialize Utils
Ext.Require("Shared/_initUtils.lua")

-- Initialize Data Tables
Ext.Require("Shared/_initData.lua")

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

Ext.RegisterModEvent("BG3SX", "AddAnimation")               --(modUUID, animationData)                  - AnimationData.lua
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


-- Users can set whether they want to "unlock" all animations
-- or only use "genital based" ones
-- This means that 2 characters with penises will have accesss
-- to the "lesbian" animations like "grinding", or "eating pussy" 


local settings = {
    Server = true,
    Client = true,
    SyncToClient = true,
    SyncToServer = true,
    SyncOnWrite = true,
    WriteableOnClient = true,
    WriteableOnServer = true
}


Ext.Vars.RegisterModVariable(ModuleUUID, "BG3SX_AddedNPCs", settings)

Ext.Vars.RegisterModVariable(ModuleUUID, "BG3SX_ShowAllAnimations", {
    Server = true, Client = true, SyncToClient = true
})




local function OnSessionLoaded()




        local vars = Ext.Vars.GetModVariables(ModuleUUID)


        -- print(vars)



        if not vars.BG3SX_ShowAllAnimations then
                -- print("BG3SX_ShowAllAnimations mod variable not initialized yet")
                -- print("setting it to default value = false")
                vars.BG3SX_ShowAllAnimations = false
        end

        -- Ext.Log.Print("BG3SX_ShowAllAnimations")
        -- Ext.Log.Print(vars.BG3SX_ShowAllAnimations)
        -- Ext.Log.Print("End BG3SX_ShowAllAnimations")

        -- Ext.Vars.SyncModVariables(ModuleUUID)
        Ext.Vars.SyncModVariables() -- SyncModVariables is called without parameters


end


Ext.Events.SessionLoaded:Subscribe(OnSessionLoaded)





-- the original function from Norb wrongly parses commented out lines.
-- LaughingLeader posted this fix 
-- https://discord.com/channels/98922182746329088/771869529528991744/1324091645024796755



local modifierLists = {
        "Armor",
        "Character",
        "CriticalHitTypeData",
        "InterruptData",
        "Object",
        "PassiveData",
        "SpellData",
        "Weapon",
        "StatusData"
}


local functors = {
        "ToggleOnFunctors",
        "ToggleOffFunctors",
        "StatsFunctors",
        "StatsFunctorContext" ,
        "FailureFunctors",
        "PropertiesFunctors",
        "SuccessFunctors",
        "WeaponFunctors",
        "HitFunctors",
        "Failure",
        "Properties",
        "Success",
        "OriginSpellFail",
        "OriginSpellProperties",
        "OriginSpellSuccess",
        "SpellFail",
        "SpellProperties",
        "SpellSuccess",
        "AuraStatuses",
        "Functor",
        "TickFunctors",
        "ThrowableSpellFail",
        "ThrowableSpellProperties",
        "ThrowableSpellSuccess",
        "OnApplyFail",
        "OnApplyFunctors",
        "OnApplySuccess",
        "OnRemoveFail",
        "OnRemoveFunctors",
        "OnRemoveSuccess",
        "OnRollsFailed",
        "OnSuccess",
        "OnTickFail",
        "OnTickSuccess"
}

---@param object StatsObject
local function purgeStat(object)

        -- create basic stats of each type with default values
        for _, modifierList in pairs(modifierLists) do
                if not Ext.Stats.Get(modifierList) then
                        Ext.Stats.Create(modifierList, modifierList)
                end
        end

         -- sets most properties to a default value (None, "", {}, etc.)
         object:CopyFrom(object.ModifierList)

         -- properties of a stats cannot be gracefully accessed.
         -- collect all of them first
         local allProperties = {}
         for key,_ in pairs(object) do
                 allProperties[key] = true
         end

          -- functors don't inherit from the CopyFrom and have to be set manually
          for _, functor in pairs(functors) do
                 if allProperties[functor] then
                        object:SetRawAttribute(functor, "")
                 end
         end

end


local SERVER = Ext.IsServer()

local function LoadStatsFile(path, debug)
	local file = Ext.IO.LoadFile(path, "data")
	local object = nil
	local entry = nil


	for line in string.gmatch(file, "([^\r\n]+)\r*\n") do
		if line:sub(1, 1) == "/" then
			goto continue
		end
		local key, value = string.match(line, "%s*data%s+\"([^\"]+)\"%s+\"([^\"]*)\"")
		if key ~= nil then
			if object ~= nil then
				if debug then print("\027[0;90m  Set: " .. key .. " = " .. value) end
				object:SetRawAttribute(key, value)
			end
		else
			local type = string.match(line, "%s*type%s+\"([^\"]+)\"")
			if type ~= nil then
				if object == nil and entry ~= nil then
					if debug then print("\027[0;33mCreate new entry: " .. entry .. ", type " .. type) end
					object = Ext.Stats.Create(entry, type)
				end
			else
				entry = string.match(line, "%s*new%s+entry%s+\"([^\"]+)\"")
				if entry ~= nil then
					if object ~= nil and SERVER then
						Ext.Stats.Sync(object.Name)
					end

					object = Ext.Stats.Get(entry, -1, false)

					if object ~= nil then
                                                purgeStat(object)
						if debug then print("\027[0;37mUpdate existing entry: " .. entry) end
					end
				else
					local using = string.match(line, "%s*using%s+\"([^\"]+)\"")
					if using ~= nil then
						if object ~= nil then
							if debug then print("\027[0;90m  Inherit from: " .. using) end
							object:CopyFrom(using)
						end
					else
						if debug then Ext.Utils.PrintWarning("Unrecognized line: " .. line) end
					end
				end
			end
		end
		::continue::
	end

	if object ~= nil and SERVER then
		Ext.Stats.Sync(object.Name)
	end
end

local filenames = {
        "Passives"
}

local function OnReset()

        for _, file in pairs(filenames) do
        LoadStatsFile("Public/BG3SX/Stats/Generated/Data/"..file..".txt", true)
        end

        for _, stats in pairs(Ext.Stats.GetStats()) do
                Ext.Stats.Sync(stats)
        end
end


Ext.Events.ResetCompleted:Subscribe(OnReset)

