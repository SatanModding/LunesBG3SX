----------------------------------------------------------------------------------------
--
--                      For handling the main functionalities
--
----------------------------------------------------------------------------------------


local function initializeParty()
    local party = Osi.DB_PartyMembers:Get(nil)
    -- _P("---------------------OnSessionLoaded Whitelist Check---------------------")
    for i = #party, 1, -1 do
        if Entity:IsWhitelisted(party[i][1]) then
            Sex:AddMainSexSpells(party[i][1])

            local entity = Ext.Entity.Get(party[i][1])
            if not entity then
                Debug.Print("is not a entity " .. party[i][1])
            else
                print("adding genital for ", party[i][1])
                Genital.AddGenitalIfHasNone(entity)
                Genital.AssignDefaultIfHasNotYet(entity)
            end

            
        end
    end
end

-- Runs every time a save is loaded --
function OnSessionLoaded()
    ------------------------------------------------------------------------------------------------------------------------------------------
                                                 ---- Setup Functions ----
    ------------------------------------------------------------------------------------------------------------------------------------------

    Genital.Initialize() -- Initializes genitals, check Genitals.lua

    -- strips NPCs that have been stripped before the game was ended
    

    Ext.Osiris.RegisterListener("LevelGameplayStarted", 2, "after", function(_, _)
        initializeParty()
        NPC.RestoreNudity()
    end)

	Ext.Osiris.RegisterListener("DB_PartOfTheTeam", 1, "afterDelete", function (character)
        initializeParty()
    end)

    -- TODO: Check if CharacterCreationDummy might cause issues with "Make NPC into Partymember" mods
    Ext.Osiris.RegisterListener("CharacterJoinedParty", 1, "after", function(character)
        -- _P("---------------------CharacterJoinedParty Whitelist Check---------------------")
        if string.find(character, "CharacterCreationDummy") == nil then
            initializeParty()
        end
    end)
end

-- Subscribes to the SessionLoaded event and executes our OnSessionLoaded function
Ext.Events.SessionLoaded:Subscribe(OnSessionLoaded)

-- Makes it so the game never saves with an active scene to avoid errors/crashes
Ext.Events.GameStateChanged:Subscribe(function(e)
    -- if e.FromState and e.ToState then
    -- _P("From " .. tostring(e.FromState) .. " to " .. tostring(e.ToState)) -- Debug
    -- end
    if (e.FromState == "Running" and e.ToState == "Save")
    or (e.FromState == "Running" and e.ToState == "UnloadLevel") then -- Terminate also while loading so it doesn't carry over naked npc's
        Scene.DestroyAllScenes()
    end
end)

-- Ext.Entity.Subscribe("GameObjectVisual", function(entity, _, _)
--     local GOV = entity.GameObjectVisual
--     _D(Ext.Loca.GetTranslatedString(Ext.Entity.Get(Ext.Entity.HandleToUuid(entity)).DisplayName.NameKey.Handle.Handle))
--     _P(GOV.Type) -- This is for testing
-- end)