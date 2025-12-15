----------------------------------------------------------------------------------------
--
--                      For handling the main functionalities
--
----------------------------------------------------------------------------------------
-- local BG3AF
-- if BG3AFActive then
--     BG3AF = Mods.BG3AF.API
-- end

local function initializeParty()
    local party = Osi.DB_PartyMembers:Get(nil)
    -- _P("---------------------OnSessionLoaded Whitelist Check---------------------")
    for i = #party, 1, -1 do
        local character = party[i][1]
        if Entity:IsWhitelisted(character) then
            local entity = Ext.Entity.Get(character)
            if not entity then
                Debug.Print("is not a entity " .. character)
            else
                -- print("adding genital for ", character)
                Genital.AddGenitalIfHasNone(entity)
                Genital.AssignDefaultIfHasNotYet(entity)

                -- if BG3AFActive then
                --     BG3AF.TemplateAnimationSetOverride.Get(character):AddSets(ModuleUUID, Data.AnimationSets)
                -- end
            end
        end

        -- We are not using spells anymore
        -- Remove them
        --Debug.Print("Removing spells for ".. party[i][1])
        Osi.RemoveSpell(party[i][1],"BG3SX_MainContainer", 1)
        Osi.RemoveSpell(party[i][1],"BG3SX_ChangeGenitals", 1)
        Osi.RemoveSpell(party[i][1],"BG3SX_Options", 1)
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
        -- print("ATTENTION ATTENTION ATTTENTION")
        -- print("Sending Event session loaded to all clients")
        Event.SessionLoaded:Broadcast("") -- fetches NPCs once
        initializeParty()
        NPC.RestoreNudity()
    end)

    local oldparty

    Ext.Osiris.RegisterListener("DB_PartOfTheTeam", 1, "beforeDelete", function (character)
        oldparty = Osi.DB_PartyMembers:Get(nil)
    end)
    Ext.Osiris.RegisterListener("CharacterJoinedParty", 1, "before", function (character)
        oldparty = Osi.DB_PartyMembers:Get(nil)
    end)
    Ext.Osiris.RegisterListener("CharacterLeftParty", 1, "before", function (character)
        oldparty = Osi.DB_PartyMembers:Get(nil)
    end)

	Ext.Osiris.RegisterListener("DB_PartOfTheTeam", 1, "afterDelete", function (character)
        initializeParty()
        local party = Osi.DB_PartyMembers:Get(nil)
        -- Debug.Print("DB_PartOfTheTeam send")
        for _,member in pairs(party) do
            if Table.Contains(oldparty, member) then
                local entity = Ext.Entity.Get(member)
                if entity.ClientControl then
                    Event.SendParty:SendToClient(party, member)
                end
            end
        end
        oldparty = party
    end)

    -- TODO: Check if CharacterCreationDummy might cause issues with "Make NPC into Partymember" mods
    Ext.Osiris.RegisterListener("CharacterJoinedParty", 1, "after", function(character)
        -- _P("---------------------CharacterJoinedParty Whitelist Check---------------------")
        if string.find(character, "CharacterCreationDummy") == nil then
            initializeParty()
        end

        local party = Osi.DB_PartyMembers:Get(nil)
        -- Debug.Print("CharacterJoinedParty send")
        for _,member in pairs(party) do
            local character = member[1]
            --if Table.Contains(oldparty, member) then (commenting this oldparty condition out as it seems to prevent a proper party update
                local entity = Ext.Entity.Get(character)
                if entity.ClientControl then
                    Event.SendParty:SendToClient(party, character)
                end
            --end
            -- if BG3AFActive then
            --     BG3AF.TemplateAnimationSetOverride.Get(character):AddSets(ModuleUUID, Data.AnimationSets)
            -- end
        end
        -- oldparty = party
    end)

    Ext.Osiris.RegisterListener("CharacterLeftParty", 1, "after", function(character)
        local party = Osi.DB_PartyMembers:Get(nil)
        -- Debug.Print("CharacterLeftParty send")
        for _,member in pairs(party) do
            --if Table.Contains(oldparty, member) then (commented out - same reason as above)
                local entity = Ext.Entity.Get(member[1])
                if entity.ClientControl then
                    Event.SendParty:SendToClient(party, member[1])
                end
            --end
        end
        --oldparty = party
    end)

    Ext.Events.ResetCompleted:Subscribe(function(e)
        local party = Osi.DB_PartyMembers:Get(nil)
        local host = Osi.GetHostCharacter()
        for _,member in pairs(party) do
            if not member == host then
                local entity = Ext.Entity.Get(member)
                if entity.ClientControl then
                    Event.InitUIAfterReset:SendToClient("", member)
                end
            end
        end
    end)
end

-- Subscribes to the SessionLoaded event and executes our OnSessionLoaded function
Ext.Events.SessionLoaded:Subscribe(OnSessionLoaded)


-- local oldparty = Osi.DB_PartyMembers:Get(nil)
-- local function afterResetPartySync()
--     initializeParty()
--     local party = Osi.DB_PartyMembers:Get(nil)
--     -- Debug.Print("afterResetPartySync send")
--     for _,member in pairs(party) do
--         if Table.Contains(oldparty, member) then
--             local entity = Ext.Entity.Get(member)
--             if entity.ClientControl then
--                 Event.SendParty:SendToClient(party, member)
--             end
--         end
--     end
--     oldparty = party
-- end

-- Ext.Events.ResetCompleted:Subscribe(function(e)
--     afterResetPartySync()
-- end)

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