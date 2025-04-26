---Event Creation
---@param name string
function Event:New(name)
    self[name] = Ext.Net.CreateChannel(ModuleUUID, name)
end

Event:New("CustomEvent")



Event:New("SessionLoaded")



--- General
Event:New("InitUIAfterReset")
Event:New("UIInitialized")
Event:New("RequestUILoadedState")
Event:New("SendUILoadedState")
-- Client -> Server
Event:New("ChangeCharacter")
Event:New("FetchScenes")
Event:New("SendScenes")
-- Server -> Client
Event:New("UpdateScenes")
Event:New("SetSelectedCharacter")

--- Party
-- Client -> Server
Event:New("FetchParty")
Event:New("RequestWhitelistStatus")
-- Server -> Client
Event:New("SendParty")
Event:New("SendWhitelistStatus")

--- Scene specific
-- Client -> Server
Event:New("AskForSex")
Event:New("ChangeAnimation")
Event:New("SwapPosition")
Event:New("RotateScene")
Event:New("ChangeCameraHeight")
Event:New("MoveScene")
Event:New("StopSex")
Event:New("RequestTeleport")
Event:New("RequestRotation")
Event:New("TogglePause")
Event:New("RequestSyncActiveScenes")
-- Server -> Client
Event:New("NewScene")
Event:New("UpdateSceneControlPicker")
Event:New("DestroyAllSceneControls")
Event:New("SyncActiveScenes")
Event:New("SceneControlInstanceDestroyed")


--- Genitals
Event:New("GenitalsLoaded")
-- Client -> Server
Event:New("FetchGenitals")
Event:New("SetActiveGenital")
Event:New("SetInactiveGenital")
Event:New("SetupInvisUserVars")
Event:New("ToggleInvisibility")
Event:New("SetInvisible")
-- Server -> Client
Event:New("SendGenitals")

--- Settings
-- Client -> Server
Event:New("FetchAnimations")
Event:New("FetchAllAnimations")
Event:New("FetchFilteredAnimations")
-- Event:New("AutoErectionsOn")
-- Event:New("AutoErectionsOff")
-- Server -> Client
Event:New("SendAllAnimations")
Event:New("SendFilteredAnimations")

-- Event:New("SendAnimations")

--- Whitelist Tab
-- Client -> Server
Event:New("FetchUserTags")
Event:New("FetchWhitelist")
-- Server -> Client
Event:New("SendUserTags")
Event:New("SendWhitelist")

--- Whitelist Tab
-- Client -> Server
Event:New("RequestStripNPC")
Event:New("RequestDressNPC")
Event:New("RequestGiveGenitalsNPC")
Event:New("RequestRemoveGenitalsNPC")
Event:New("FetchWhitelistedNPCs")
--  Server -> Client
Event:New("SendWhitelistedNPCs")
Event:New("SyncNPCStrip")
Event:New("SyncNPCDress")

--- NPCSync

-- Server -> Client


-- example usaCge

-- Client -> Server
-- Event.FetchAllAnimations:SendToServer({ID = UI.ID})
-- Event.SwapPosition:SendToServer({ID = UI.ID, Scene = scene, Position = pos})
--     -- Do something on Server
--     SwapPosition(payload.Scene, payload.Position)


-- -- Server -> Client
-- local allAnimations = {}
-- Event.SendAllAnimations:SendToClient(allAnimations, payload.ID)



Event:New("AddedNPCToTab")
Event:New("RemovedNPCFromTab")
Event:New("FinishedBuildingNPCUI")

Event:New("RestoreNPCTab")

function Event.GetAll()
    local allEvents = {}
    for name, event in pairs(Event) do
        if not (name == "New" or name == "GetAll") then
            allEvents[name] = event
        end
    end
    return allEvents
end